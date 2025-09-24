#include "networkservice.h"
#include "../ManualAppCorePlugin/settingsmanager.h"
#include "fileservice.h"
#include "reportmanager.h"
#include "utils.h"
#include <QCoreApplication>
#include <QHttpMultiPart>
#include <QJsonDocument>
#include <QNetworkRequest>
#include <QUrlQuery>

NetworkService::NetworkService(FileService *fileService,
                               ReportManager *reportManager, QObject *parent)
    : QObject(parent), m_manager(new QNetworkAccessManager(this)),
      m_currentReply(nullptr), m_fileService(fileService),
      m_reportManager(reportManager) {
  DEBUG_COLORED("NetworkService", "Constructor", "Initialized", COLOR_BLUE,
                COLOR_BLUE);
}

NetworkService::~NetworkService() {
  cleanupCurrentReply();
  m_manager->deleteLater();
}
void NetworkService::setReportManager(ReportManager *reportManager) {
  if (reportManager == nullptr) {
    DEBUG_ERROR_COLORED("NetworkService", "setReportManager",
                        "ReportManager is null!", COLOR_BLUE, COLOR_BLUE);
    return;
  }
  m_reportManager = reportManager;
}

void NetworkService::getJsonFromDjango(
    const QUrl &url, std::function<void(const QJsonObject &)> onSuccess,
    std::function<void(const QString &)> onError) {
  DEBUG_COLORED("NetworkService", "getJsonFromDjango",
                "Uploading jsons with reports", COLOR_BLUE, COLOR_BLUE);
  QNetworkRequest request(url);
  request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

  QNetworkReply *reply = m_manager->get(request);

  connect(reply, &QNetworkReply::finished, [=]() {
    if (reply->error() == QNetworkReply::NoError) {
      QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
      onSuccess(doc.object());
    } else {
      onError(reply->errorString());
      DEBUG_ERROR_COLORED("NetworkService", "getJsonFromDjango",
                          "get request error", COLOR_BLUE, COLOR_BLUE);
    }
    reply->deleteLater();
  });
}

void NetworkService::cleanupCurrentReply() {
  if (m_currentReply) {
    m_currentReply->disconnect();
    m_currentReply->abort();
    m_currentReply->deleteLater();
    m_currentReply = nullptr;
  }
}

void NetworkService::cancelUpload() {
  DEBUG_COLORED("NetworkService", "cancelUpload", "Canceling current upload",
                COLOR_BLUE, COLOR_BLUE);
  cleanupCurrentReply();
}

void NetworkService::uploadFile(const QUrl &apiUrl, const QString &filePath) {
  DEBUG_COLORED(
      "NetworkService", "uploadFile",
      QString("Uploading file: %1 to %2").arg(filePath).arg(apiUrl.toString()),
      COLOR_BLUE, COLOR_BLUE);

  cleanupCurrentReply();

  QFile *file = new QFile(filePath, this);
  if (!file->open(QIODevice::ReadOnly)) {
    QString error = tr("Failed to open file: %1").arg(file->errorString());
    DEBUG_ERROR_COLORED("NetworkService", "uploadFile", error, COLOR_BLUE,
                        COLOR_BLUE);
    emit errorOccurred(error);
    file->deleteLater();
    return;
  }

  QHttpMultiPart *multi = new QHttpMultiPart(QHttpMultiPart::FormDataType);
  QHttpPart filePart;
  QString fname = QFileInfo(filePath).fileName();
  filePart.setHeader(
      QNetworkRequest::ContentDispositionHeader,
      QVariant(
          QString("form-data; name=\"file\"; filename=\"%1\"").arg(fname)));
  filePart.setBodyDevice(file);
  file->setParent(multi); // multi will take ownership of file
  multi->append(filePart);

  QNetworkRequest request(apiUrl);

  m_currentReply = m_manager->post(request, multi);
  file->setParent(m_currentReply);

  connect(m_currentReply, &QNetworkReply::uploadProgress, this,
          &NetworkService::handleUploadProgress);
  connect(m_currentReply, &QNetworkReply::finished, this, [=]() {
    int status =
        m_currentReply->attribute(QNetworkRequest::HttpStatusCodeAttribute)
            .toInt();
    QByteArray serverResponse = m_currentReply->readAll();
    handleUploadFinished();
  });
}

void NetworkService::uploadJsonToDjango(const QUrl &apiUrl,
                                        const QJsonObject &jsonObject) {
  DEBUG_COLORED("NetworkService", "uploadJsonToDjango",
                QString("Uploading JSON to: %1").arg(apiUrl.toString()),
                COLOR_BLUE, COLOR_BLUE);

  cleanupCurrentReply();

  QJsonDocument jsonDoc(jsonObject);
  QByteArray jsonData = jsonDoc.toJson();

  if (jsonData.isEmpty()) {
    QString error = tr("JSON data is empty");
    DEBUG_ERROR_COLORED("NetworkService", "uploadJsonToDjango", error,
                        COLOR_BLUE, COLOR_BLUE);
    emit errorOccurred(error);
    return;
  }

  QNetworkRequest request(apiUrl);
  request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
  m_currentReply = m_manager->post(request, jsonData);

  connect(m_currentReply, &QNetworkReply::uploadProgress, this,
          &NetworkService::handleUploadProgress);
  connect(m_currentReply, &QNetworkReply::finished, this, [=]() {
    int status =
        m_currentReply->attribute(QNetworkRequest::HttpStatusCodeAttribute)
            .toInt();
    QByteArray serverResponse = m_currentReply->readAll();
    handleUploadFinished();
  });
}

void NetworkService::uploadReport(const QUrl &apiBaseUrl,
                                  const QString &reportPath, QString uploadTime,
                                  QString numberTO) {
  DEBUG_COLORED("NetworkService", "uploadReport",
                QString("Uploading report from: %1").arg(reportPath),
                COLOR_BLUE, COLOR_BLUE);

  if (m_isUploadingReport) {
    DEBUG_COLORED("NetworkService", "uploadReport",
                  "Upload already in progress, skipping", COLOR_BLUE,
                  COLOR_BLUE);
    return;
  }

  cleanupCurrentReply();
  QCoreApplication::processEvents();

  QDir reportDir(reportPath);
  if (!reportDir.exists()) {
    QString err = "Report directory does not exist";
    emit errorOccurred(tr(err.toUtf8().constData()));
    DEBUG_ERROR_COLORED("NetworkService", "uploadReport", err, COLOR_BLUE,
                        COLOR_BLUE);
    return;
  }

  QString reportId = reportDir.dirName();
  if (reportId.isEmpty()) {
    QString err = "Invalid report directory name";
    emit errorOccurred(tr(err.toUtf8().constData()));
    DEBUG_ERROR_COLORED("NetworkService", "uploadReport", err, COLOR_BLUE,
                        COLOR_BLUE);
    return;
  }

  QString jsonPath = reportDir.filePath("report.json");
  if (!QFile::exists(jsonPath)) {
    QString err = "report.json not found";
    emit errorOccurred(tr(err.toUtf8().constData()));
    DEBUG_ERROR_COLORED("NetworkService", "uploadReport", err, COLOR_BLUE,
                        COLOR_BLUE);
    return;
  }

  m_currentApiUrl = apiBaseUrl;
  m_currentReportPath = reportPath;
  m_currentUploadTime =
      uploadTime.isEmpty() ? m_reportManager->startTime() : uploadTime;
  m_currentNumberTO =
      numberTO.isEmpty() ? m_reportManager->currentNumberTO() : numberTO;
  m_currentSerialNumber = SettingsManager().serialNumber();
  m_currentUploadStep = 0;
  m_isUploadingReport = true;

  uploadReportJsonData();

}

void NetworkService::uploadReportJsonData() {
  m_currentUploadStep = 1;
  DEBUG_COLORED("NetworkService", "uploadReportJsonData",
                "Step 1: Uploading JSON data", COLOR_BLUE, COLOR_BLUE);

  QDir reportDir(m_currentReportPath);
  QString jsonPath = reportDir.filePath("report.json");

  QFile jsonFile(jsonPath);
  if (!jsonFile.open(QIODevice::ReadOnly)) {
    handleUploadError(
        QString("Failed to open report.json: %1").arg(jsonFile.errorString()));
    return;
  }

  QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonFile.readAll());
  jsonFile.close();

  if (jsonDoc.isNull()) {
    handleUploadError("Failed to parse report.json");
    return;
  }

  QJsonObject reportData = jsonDoc.object();

  QJsonObject metadata;
  metadata["serial_number"] = m_currentSerialNumber;
  metadata["upload_time"] = m_currentUploadTime;
  metadata["number_to"] = m_currentNumberTO;

  if (reportData.contains("metadata")) {
    QJsonObject existingMetadata = reportData["metadata"].toObject();
    for (auto it = metadata.begin(); it != metadata.end(); ++it) {
      existingMetadata[it.key()] = it.value();
    }
    reportData["metadata"] = existingMetadata;
  } else {
    reportData["metadata"] = metadata;
  }

  reportData["report_id"] = reportDir.dirName();

  QString path = m_currentApiUrl.path();
  if (!path.endsWith('/'))
    path += '/';

  QUrl jsonUrl = m_currentApiUrl;
  jsonUrl.setPath(path);

  disconnect(this, &NetworkService::uploadFinished, this, &NetworkService::handleJsonDataUploadFinished);

  connect(this, &NetworkService::uploadFinished, this,
        &NetworkService::handleJsonDataUploadFinished, Qt::UniqueConnection);

  uploadJsonToDjango(jsonUrl, reportData);
}
void NetworkService::handleJsonDataUploadFinished(bool success, const QString &error) {
    disconnect(this, &NetworkService::uploadFinished, this, 
               &NetworkService::handleJsonDataUploadFinished);

    if (!success) {
        handleUploadError(error);
        return;
    }

    uploadReportJsonFile();
}
void NetworkService::uploadReportJsonFile() {
    m_currentUploadStep = 2;
    DEBUG_COLORED("NetworkService", "uploadReportJsonFile", 
                 "Step 2: Uploading JSON file", COLOR_BLUE, COLOR_BLUE);

    QDir reportDir(m_currentReportPath);
    QString jsonPath = reportDir.filePath("report.json");
    
    if (!QFile::exists(jsonPath)) {
        // Пропускаем этот шаг и переходим к следующему
        uploadReportPdfFile();
        return;
    }

    QUrlQuery query;
    query.addQueryItem("serial_number", m_currentSerialNumber);
    query.addQueryItem("upload_time", m_currentUploadTime);
    query.addQueryItem("number_to", m_currentNumberTO);

    QString path = m_currentApiUrl.path();
    if (!path.endsWith('/')) path += '/';
    
    QUrl jsonUrl = m_currentApiUrl;
    jsonUrl.setPath(path + m_currentSerialNumber + "/json/");
    jsonUrl.setQuery(query);

    // Подключаем обработчик для этого шага
    connect(this, &NetworkService::uploadFinished, this, 
            &NetworkService::handleJsonFileUploadFinished);

    uploadFile(jsonUrl, jsonPath);
}
void NetworkService::handleJsonFileUploadFinished(bool success, const QString &error) {
    disconnect(this, &NetworkService::uploadFinished, this, 
               &NetworkService::handleJsonFileUploadFinished);

    if (!success) {
        handleUploadError(error);
        return;
    }

    uploadReportPdfFile();
}
void NetworkService::uploadReportPdfFile() {
    m_currentUploadStep = 3;
    DEBUG_COLORED("NetworkService", "uploadReportPdfFile", 
                 "Step 3: Uploading PDF file", COLOR_BLUE, COLOR_BLUE);

    QDir reportDir(m_currentReportPath);
    QString pdfPath = reportDir.filePath("report.pdf");
    
    if (!QFile::exists(pdfPath)) {
        // Пропускаем этот шаг и переходим к следующему
        uploadReportBeforeFiles();
        return;
    }

    QUrlQuery query;
    query.addQueryItem("serial_number", m_currentSerialNumber);
    query.addQueryItem("upload_time", m_currentUploadTime);
    query.addQueryItem("number_to", m_currentNumberTO);

    QString path = m_currentApiUrl.path();
    if (!path.endsWith('/')) path += '/';
    
    QUrl pdfUrl = m_currentApiUrl;
    pdfUrl.setPath(path + m_currentSerialNumber + "/pdf/");
    pdfUrl.setQuery(query);

    connect(this, &NetworkService::uploadFinished, this, 
            &NetworkService::handlePdfFileUploadFinished);

    uploadFile(pdfUrl, pdfPath);
}
void NetworkService::handlePdfFileUploadFinished(bool success, const QString &error) {
    disconnect(this, &NetworkService::uploadFinished, this, 
               &NetworkService::handlePdfFileUploadFinished);

    if (!success) {
        handleUploadError(error);
        return;
    }

    // Переходим к загрузке before files
    uploadReportBeforeFiles();
}

void NetworkService::uploadReportBeforeFiles() {
    m_currentUploadStep = 4;
    DEBUG_COLORED("NetworkService", "uploadReportBeforeFiles", 
                 "Step 4: Uploading before files", COLOR_BLUE, COLOR_BLUE);

    QDir reportDir(m_currentReportPath);
    QDir beforeDir(reportDir.filePath("before_to"));
    QString beforePath = beforeDir.filePath("rail_record.zip");
    
    if (!QFile::exists(beforePath)) {
        // Пропускаем этот шаг и переходим к следующему
        uploadReportAfterFiles();
        return;
    }

    QUrlQuery query;
    query.addQueryItem("serial_number", m_currentSerialNumber);
    query.addQueryItem("upload_time", m_currentUploadTime);
    query.addQueryItem("number_to", m_currentNumberTO);

    QString path = m_currentApiUrl.path();
    if (!path.endsWith('/')) path += '/';
    
    QUrl railUrl = m_currentApiUrl;
    railUrl.setPath(path + m_currentSerialNumber + "/before/");
    railUrl.setQuery(query);

    connect(this, &NetworkService::uploadFinished, this, 
            &NetworkService::handleBeforeFilesUploadFinished);

    uploadFile(railUrl, beforePath);
}

void NetworkService::handleBeforeFilesUploadFinished(bool success, const QString &error) {
    disconnect(this, &NetworkService::uploadFinished, this, 
               &NetworkService::handleBeforeFilesUploadFinished);

    if (!success) {
        handleUploadError(error);
        return;
    }

    // Переходим к загрузке after files
    uploadReportAfterFiles();
}
void NetworkService::uploadReportAfterFiles() {
    m_currentUploadStep = 5;
    DEBUG_COLORED("NetworkService", "uploadReportAfterFiles", 
                 "Step 5: Uploading after files", COLOR_BLUE, COLOR_BLUE);

    QDir reportDir(m_currentReportPath);
    QDir afterDir(reportDir.filePath("after_to"));
    QString afterPath = afterDir.filePath("rail_record.zip");
    
    if (!QFile::exists(afterPath)) {
        // Завершаем загрузку
        completeUpload();
        return;
    }

    QUrlQuery query;
    query.addQueryItem("serial_number", m_currentSerialNumber);
    query.addQueryItem("upload_time", m_currentUploadTime);
    query.addQueryItem("number_to", m_currentNumberTO);

    QString path = m_currentApiUrl.path();
    if (!path.endsWith('/')) path += '/';
    
    QUrl railUrl = m_currentApiUrl;
    railUrl.setPath(path + m_currentSerialNumber + "/after/");
    railUrl.setQuery(query);

    connect(this, &NetworkService::uploadFinished, this, 
            &NetworkService::handleAfterFilesUploadFinished);

    uploadFile(railUrl, afterPath);
}
void NetworkService::handleAfterFilesUploadFinished(bool success, const QString &error) {
    disconnect(this, &NetworkService::uploadFinished, this, 
               &NetworkService::handleAfterFilesUploadFinished);

    if (!success) {
        handleUploadError(error);
        return;
    }

    // Завершаем загрузку
    completeUpload();
}
void NetworkService::completeUpload() {
    DEBUG_COLORED("NetworkService", "completeUpload", 
                 "Upload completed successfully", COLOR_BLUE, COLOR_BLUE);
    
    m_isUploadingReport = false;
    m_currentUploadStep = 0;
    
    emit uploadFinished(true, "");
}

void NetworkService::handleUploadError(const QString &error) {
    DEBUG_ERROR_COLORED("NetworkService", "handleUploadError", 
                       QString("Upload error at step %1: %2").arg(m_currentUploadStep).arg(error), 
                       COLOR_BLUE, COLOR_BLUE);
    
    m_isUploadingReport = false;
    m_currentUploadStep = 0;
    
    emit errorOccurred(error);
    emit uploadFinished(false, error);
}

void NetworkService::handleUploadProgress(qint64 bytesSent, qint64 bytesTotal) {
  emit progressChanged(bytesSent, bytesTotal);
}

void NetworkService::handleUploadFinished() {
  if (!m_currentReply) {
    DEBUG_ERROR_COLORED("NetworkService", "handleUploadFinished",
                        "No current reply in handleUploadFinished", COLOR_BLUE,
                        COLOR_BLUE);
    return;
  }

  bool success = false;
  QString error;

  if (m_currentReply->error() == QNetworkReply::NoError) {
    int status =
        m_currentReply->attribute(QNetworkRequest::HttpStatusCodeAttribute)
            .toInt();
    success = (status >= 200 && status < 300);

    if (!success) {
      error = tr("Server error: HTTP %1").arg(status);
      DEBUG_ERROR_COLORED("NetworkService", "handleUploadFinished",
                          QString("Server error: %1 %2")
                              .arg(status)
                              .arg(QString(m_currentReply->readAll())),
                          COLOR_BLUE, COLOR_BLUE);
    }
  } else if (m_currentReply->error() != QNetworkReply::OperationCanceledError) {
    error = tr("Network error: %1").arg(m_currentReply->errorString());
    DEBUG_ERROR_COLORED(
        "NetworkService", "handleUploadFinished",
        QString("Network error: %1").arg(m_currentReply->errorString()),
        COLOR_BLUE, COLOR_BLUE);
  }

  QNetworkReply *reply = m_currentReply;
  m_currentReply = nullptr;
  reply->deleteLater();

  if (!error.isEmpty()) {
    emit errorOccurred(error);
  } else {
    DEBUG_COLORED("NetworkService", "handleUploadFinished",
                  QString("Uploading finished successfully"), COLOR_BLUE,
                  COLOR_BLUE);
    emit uploadFinished(success, error);
  }
}

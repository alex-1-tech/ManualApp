#include "networkservice.h"

#include <QCoreApplication>
#include <QDir>
#include <QEventLoop>
#include <QHttpMultiPart>
#include <QJsonDocument>
#include <QNetworkProxy>
#include <QNetworkRequest>
#include <QTimer>
#include <QUrlQuery>

#include "fileservice.h"
#include "loger.h"
#include "reportmanager.h"
#include "settingsmanager.h"


NetworkService::NetworkService(FileService* fileService, ReportManager* reportManager, QObject* parent)
    : QObject(parent)
    , m_manager(new QNetworkAccessManager(this))
    , m_currentReply(nullptr)
    , m_fileService(fileService)
    , m_reportManager(reportManager)
{
  DEBUG_COLORED("NetworkService", "Constructor", "Initialized", COLOR_BLUE, COLOR_BLUE);
  m_manager->setProxy(QNetworkProxy::NoProxy);
}

NetworkService::~NetworkService()
{
  DEBUG_COLORED("NetworkService", "Destructor", "Destroying NetworkService", COLOR_BLUE, COLOR_BLUE);
  shutdown();
}
void NetworkService::shutdown()
{
  DEBUG_COLORED("NetworkService", "shutdown", "Aborting all network activity", COLOR_BLUE, COLOR_BLUE);

  if (m_currentReply) {
    m_currentReply->disconnect();
    m_currentReply->abort();
    m_currentReply->deleteLater();
    m_currentReply = nullptr;
  }

  const auto replies = m_manager->findChildren<QNetworkReply*>();
  for (QNetworkReply* reply : replies) {
    reply->abort();
    reply->deleteLater();
  }

  m_manager->clearAccessCache();
}

void NetworkService::setReportManager(ReportManager* reportManager)
{
  if (reportManager == nullptr) {
    DEBUG_ERROR_COLORED("NetworkService", "setReportManager", "ReportManager is null!", COLOR_BLUE,
                        COLOR_BLUE);
    return;
  }
  m_reportManager = reportManager;
}

void NetworkService::getJsonFromDjango(const QUrl& url, std::function<void(const QJsonObject&)> onSuccess,
                                       std::function<void(const QString&)> onError)
{
  DEBUG_COLORED("NetworkService", "getJsonFromDjango", QString("Getting JSON from: %1").arg(url.toString()),
                COLOR_BLUE, COLOR_BLUE);

  QNetworkRequest request(url);
  request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

  QNetworkReply* reply = m_manager->get(request);

  connect(reply, &QNetworkReply::finished, [=]() {
    if (reply->error() == QNetworkReply::NoError) {
      QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
      onSuccess(doc.object());
    } else {
      onError(reply->errorString());
      DEBUG_ERROR_COLORED("NetworkService", "getJsonFromDjango",
                          QString("GET request error: %1").arg(reply->errorString()), COLOR_BLUE, COLOR_BLUE);
    }
    reply->deleteLater();
  });
}

void NetworkService::cleanupCurrentReply()
{
  if (m_currentReply) {
    m_currentReply->disconnect();
    m_currentReply->abort();
    m_currentReply->deleteLater();
    m_currentReply = nullptr;
  }
}

bool NetworkService::waitForReplyFinished(QNetworkReply* reply, int timeoutMs)
{
  QEventLoop loop;
  QTimer timeoutTimer;

  timeoutTimer.setSingleShot(true);
  QObject::connect(&timeoutTimer, &QTimer::timeout, &loop, &QEventLoop::quit);
  QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);

  timeoutTimer.start(timeoutMs);
  loop.exec();

  if (!timeoutTimer.isActive()) {
    DEBUG_ERROR_COLORED("NetworkService", "waitForReplyFinished", "Request timeout", COLOR_BLUE, COLOR_BLUE);
    return false;
  }

  timeoutTimer.stop();
  return true;
}

QUrl NetworkService::buildUploadUrl(const QUrl& apiBaseUrl, const QString& endpoint,
                                    const QString& serialNumber, const QString& uploadTime,
                                    const QString& numberTO, const QString& model)
{
  QUrlQuery query;
  query.addQueryItem("serial_number", serialNumber);
  query.addQueryItem("upload_time", uploadTime);
  query.addQueryItem("number_to", numberTO);
  query.addQueryItem("equipment_type", model);

  QString path = apiBaseUrl.path();
  if (!path.endsWith('/')) {
    path += '/';
  }

  QUrl url = apiBaseUrl;
  url.setPath(path + serialNumber + endpoint);
  url.setQuery(query);

  return url;
}

bool NetworkService::uploadFileSynchronous(const QUrl& apiUrl, const QString& filePath)
{
  DEBUG_COLORED("NetworkService", "uploadFileSynchronous",
                QString("Uploading file: %1 to %2").arg(filePath).arg(apiUrl.toString()), COLOR_BLUE,
                COLOR_BLUE);

  // Check if file exists
  if (!QFile::exists(filePath)) {
    DEBUG_ERROR_COLORED("NetworkService", "uploadFileSynchronous",
                        QString("File does not exist: %1").arg(filePath), COLOR_BLUE, COLOR_BLUE);
    return false;
  }

  // Check file size
  QFileInfo fileInfo(filePath);
  if (fileInfo.size() == 0) {
    DEBUG_ERROR_COLORED("NetworkService", "uploadFileSynchronous", QString("File is empty: %1").arg(filePath),
                        COLOR_BLUE, COLOR_BLUE);
    return false;
  }

  QFile* file = new QFile(filePath);
  if (!file->open(QIODevice::ReadOnly)) {
    DEBUG_ERROR_COLORED("NetworkService", "uploadFileSynchronous",
                        QString("Failed to open file: %1").arg(file->errorString()), COLOR_BLUE, COLOR_BLUE);
    file->deleteLater();
    return false;
  }

  // Create multipart form data
  QHttpMultiPart* multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

  QHttpPart filePart;
  QString fileName = QFileInfo(filePath).fileName();
  filePart.setHeader(QNetworkRequest::ContentDispositionHeader,
                     QVariant(QString("form-data; name=\"file\"; filename=\"%1\"").arg(fileName)));
  filePart.setBodyDevice(file);
  file->setParent(multiPart); // multiPart will take ownership of file
  multiPart->append(filePart);

  QNetworkRequest request(apiUrl);

  // Execute request synchronously
  QNetworkReply* reply = m_manager->post(request, multiPart);
  multiPart->setParent(reply); // reply will take ownership of multiPart

  bool success = waitForReplyFinished(reply);

  if (success && reply->error() == QNetworkReply::NoError) {
    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    if (statusCode >= 200 && statusCode < 300) {
      DEBUG_COLORED("NetworkService", "uploadFileSynchronous",
                    QString("File upload successful (HTTP %1)").arg(statusCode), COLOR_BLUE, COLOR_BLUE);
      reply->deleteLater();
      return true;
    } else {
      DEBUG_ERROR_COLORED("NetworkService", "uploadFileSynchronous",
                          QString("Server error: HTTP %1").arg(statusCode), COLOR_BLUE, COLOR_BLUE);
    }
  } else {
    DEBUG_ERROR_COLORED("NetworkService", "uploadFileSynchronous",
                        QString("Network error: %1").arg(reply->errorString()), COLOR_BLUE, COLOR_BLUE);
  }

  reply->deleteLater();
  return false;
}

bool NetworkService::uploadJsonToDjangoSynchronous(const QUrl& apiUrl, const QJsonObject& jsonObject)
{
  DEBUG_COLORED("NetworkService", "uploadJsonToDjangoSynchronous",
                QString("Uploading JSON to: %1").arg(apiUrl.toString()), COLOR_BLUE, COLOR_BLUE);

  QJsonDocument jsonDoc(jsonObject);
  QByteArray jsonData = jsonDoc.toJson();

  if (jsonData.isEmpty()) {
    DEBUG_ERROR_COLORED("NetworkService", "uploadJsonToDjangoSynchronous", "JSON data is empty", COLOR_BLUE,
                        COLOR_BLUE);
    return false;
  }

  QNetworkRequest request(apiUrl);
  request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
  request.setRawHeader("Accept", "application/json");
  request.setHeader(QNetworkRequest::ContentLengthHeader, QVariant(jsonData.size()));
  request.setRawHeader("User-Agent", "Qt/5.15");
  request.setRawHeader("Connection", "keep-alive");

  // Execute request synchronously
  QNetworkReply* reply = m_manager->post(request, jsonData);
  bool success = waitForReplyFinished(reply);

  if (success && reply->error() == QNetworkReply::NoError) {
    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    if (statusCode >= 200 && statusCode < 300) {
      DEBUG_COLORED("NetworkService", "uploadJsonToDjangoSynchronous",
                    QString("JSON upload successful (HTTP %1)").arg(statusCode), COLOR_BLUE, COLOR_BLUE);
      reply->deleteLater();
      return true;
    } else {
      DEBUG_ERROR_COLORED("NetworkService", "uploadJsonToDjangoSynchronous",
                          QString("Server error: HTTP %1").arg(statusCode), COLOR_BLUE, COLOR_BLUE);
    }
  } else {
    DEBUG_ERROR_COLORED("NetworkService", "uploadJsonToDjangoSynchronous",
                        QString("Network error: %1").arg(reply->errorString()), COLOR_BLUE, COLOR_BLUE);
  }

  reply->deleteLater();
  return false;
}

void NetworkService::postJson(const QNetworkRequest& request, const QByteArray& json,
                              std::function<void(bool, QByteArray, QString)> callback)
{
  DEBUG_COLORED("NetworkService", "postJson", QString("POST JSON to %1").arg(request.url().toString()),
                COLOR_BLUE, COLOR_BLUE);

  if (json.isEmpty()) {
    DEBUG_ERROR_COLORED("NetworkService", "postJson", "JSON payload is empty", COLOR_BLUE, COLOR_BLUE);
    callback(false, {}, "JSON payload is empty");
    return;
  }

  cleanupCurrentReply();

  QNetworkRequest req = request;
  req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
  req.setRawHeader("Accept", "application/json");
  req.setRawHeader("User-Agent", "Qt/5.15");

  m_currentReply = m_manager->post(req, json);

  connect(m_currentReply, &QNetworkReply::finished, this, [this, callback]() {
    QNetworkReply* reply = m_currentReply;
    m_currentReply = nullptr;

    QByteArray responseData = reply->readAll();
    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

    QString errorMsg = QString("Network error: %1 (HTTP %2)").arg(reply->errorString()).arg(statusCode);

    if (!responseData.isEmpty()) {
      QJsonDocument doc = QJsonDocument::fromJson(responseData);
      if (!doc.isNull() && doc.isObject()) {
        QJsonObject obj = doc.object();
        if (obj.contains("error")) {
          errorMsg += " | Server error: " + obj["error"].toString();
        }
      } else {
        errorMsg += " | Response: " + QString(responseData);
      }
    }

    DEBUG_ERROR_COLORED("NetworkService", "postJson", errorMsg, COLOR_BLUE, COLOR_BLUE);
    callback(false, responseData, errorMsg);
  });
}


bool NetworkService::uploadReportSynchronous(const QUrl& apiBaseUrl, const QString& reportPath,
                                             QString uploadTime, QString numberTO)
{
  DEBUG_COLORED("NetworkService", "uploadReportSynchronous",
                QString("Uploading report from: %1").arg(reportPath), COLOR_BLUE, COLOR_BLUE);

  QDir reportDir(reportPath);
  if (!reportDir.exists()) {
    DEBUG_ERROR_COLORED("NetworkService", "uploadReportSynchronous",
                        QString("Report directory does not exist: %1").arg(reportPath), COLOR_BLUE,
                        COLOR_BLUE);
    return false;
  }

  QString reportId = reportDir.dirName();
  if (reportId.isEmpty()) {
    DEBUG_ERROR_COLORED("NetworkService", "uploadReportSynchronous", "Invalid report directory name",
                        COLOR_BLUE, COLOR_BLUE);
    return false;
  }

  // Get required data
  QString serialNumber = SettingsManager().serialNumber();
  QString model = SettingsManager().currentModel();

  if (uploadTime.isEmpty() && m_reportManager) {
    uploadTime = m_reportManager->startTime();
  }
  if (numberTO.isEmpty() && m_reportManager) {
    numberTO = m_reportManager->currentNumberTO();
  }

  if (serialNumber.isEmpty() || model.isEmpty()) {
    DEBUG_ERROR_COLORED("NetworkService", "uploadReportSynchronous", "Serial number or model is empty",
                        COLOR_BLUE, COLOR_BLUE);
    return false;
  }

  // Step 1: Upload JSON data
  DEBUG_COLORED("NetworkService", "uploadReportSynchronous", "Step 1: Uploading JSON data", COLOR_BLUE,
                COLOR_BLUE);

  QString jsonPath = reportDir.filePath("report.json");
  if (!QFile::exists(jsonPath)) {
    DEBUG_ERROR_COLORED("NetworkService", "uploadReportSynchronous",
                        QString("report.json not found: %1").arg(jsonPath), COLOR_BLUE, COLOR_BLUE);
    return false;
  }

  QFile jsonFile(jsonPath);
  if (!jsonFile.open(QIODevice::ReadOnly)) {
    DEBUG_ERROR_COLORED("NetworkService", "uploadReportSynchronous",
                        QString("Failed to open report.json: %1").arg(jsonFile.errorString()), COLOR_BLUE,
                        COLOR_BLUE);
    return false;
  }

  QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonFile.readAll());
  jsonFile.close();

  if (jsonDoc.isNull()) {
    DEBUG_ERROR_COLORED("NetworkService", "uploadReportSynchronous", "Failed to parse report.json",
                        COLOR_BLUE, COLOR_BLUE);
    return false;
  }

  QJsonObject reportData = jsonDoc.object();

  // Add metadata
  QJsonObject metadata;
  metadata["serial_number"] = serialNumber;
  metadata["upload_time"] = uploadTime;
  metadata["number_to"] = numberTO;
  metadata["equipment_type"] = model;

  if (reportData.contains("metadata")) {
    QJsonObject existingMetadata = reportData["metadata"].toObject();
    for (auto it = metadata.begin(); it != metadata.end(); ++it) {
      existingMetadata[it.key()] = it.value();
    }
    reportData["metadata"] = existingMetadata;
  } else {
    reportData["metadata"] = metadata;
  }

  reportData["report_id"] = reportId;

  // Build API URL for JSON data
  QString path = apiBaseUrl.path();
  if (!path.endsWith('/')) {
    path += '/';
  }
  QUrl jsonUrl = apiBaseUrl;
  jsonUrl.setPath(path);

  // Upload JSON data
  if (!uploadJsonToDjangoSynchronous(jsonUrl, reportData)) {
    DEBUG_ERROR_COLORED("NetworkService", "uploadReportSynchronous", "Failed to upload JSON data", COLOR_BLUE,
                        COLOR_BLUE);
    return false;
  }

  // Step 2: Upload JSON file
  DEBUG_COLORED("NetworkService", "uploadReportSynchronous", "Step 2: Uploading JSON file", COLOR_BLUE,
                COLOR_BLUE);

  QFileInfo jsonFileInfo(jsonPath);
  if (jsonFileInfo.size() > 0) {
    QUrl jsonFileUrl = buildUploadUrl(apiBaseUrl, "/json/", serialNumber, uploadTime, numberTO, model);
    if (!uploadFileSynchronous(jsonFileUrl, jsonPath)) {
      DEBUG_ERROR_COLORED("NetworkService", "uploadReportSynchronous",
                          "Failed to upload JSON file, but continuing...", COLOR_BLUE, COLOR_BLUE);
      // Continue even if file upload fails
    }
  } else {
    DEBUG_COLORED("NetworkService", "uploadReportSynchronous", "JSON file is empty, skipping", COLOR_BLUE,
                  COLOR_BLUE);
  }

  // Step 3: Upload PDF file
  DEBUG_COLORED("NetworkService", "uploadReportSynchronous", "Step 3: Uploading PDF file", COLOR_BLUE,
                COLOR_BLUE);

  QString pdfPath = reportDir.filePath("report.pdf");
  if (QFile::exists(pdfPath)) {
    QFileInfo pdfFileInfo(pdfPath);
    if (pdfFileInfo.size() > 0) {
      QUrl pdfFileUrl = buildUploadUrl(apiBaseUrl, "/pdf/", serialNumber, uploadTime, numberTO, model);
      if (!uploadFileSynchronous(pdfFileUrl, pdfPath)) {
        DEBUG_ERROR_COLORED("NetworkService", "uploadReportSynchronous",
                            "Failed to upload PDF file, but continuing...", COLOR_BLUE, COLOR_BLUE);
        // Continue even if file upload fails
      }
    } else {
      DEBUG_COLORED("NetworkService", "uploadReportSynchronous", "PDF file is empty, skipping", COLOR_BLUE,
                    COLOR_BLUE);
    }
  } else {
    DEBUG_COLORED("NetworkService", "uploadReportSynchronous", "PDF file not found, skipping", COLOR_BLUE,
                  COLOR_BLUE);
  }

  // Step 4: Upload before files
  DEBUG_COLORED("NetworkService", "uploadReportSynchronous", "Step 4: Uploading before files", COLOR_BLUE,
                COLOR_BLUE);

  QDir beforeDir(reportDir.filePath("before_to"));
  QString beforePath = beforeDir.filePath("rail_record.zip");
  if (QFile::exists(beforePath)) {
    QFileInfo beforeFileInfo(beforePath);
    if (beforeFileInfo.size() > 0) {
      QUrl beforeFileUrl = buildUploadUrl(apiBaseUrl, "/before/", serialNumber, uploadTime, numberTO, model);
      if (!uploadFileSynchronous(beforeFileUrl, beforePath)) {
        DEBUG_ERROR_COLORED("NetworkService", "uploadReportSynchronous",
                            "Failed to upload before files, but continuing...", COLOR_BLUE, COLOR_BLUE);
        // Continue even if file upload fails
      }
    } else {
      DEBUG_COLORED("NetworkService", "uploadReportSynchronous", "Before files archive is empty, skipping",
                    COLOR_BLUE, COLOR_BLUE);
    }
  } else {
    DEBUG_COLORED("NetworkService", "uploadReportSynchronous", "Before files not found, skipping", COLOR_BLUE,
                  COLOR_BLUE);
  }

  // Step 5: Upload after files
  DEBUG_COLORED("NetworkService", "uploadReportSynchronous", "Step 5: Uploading after files", COLOR_BLUE,
                COLOR_BLUE);

  QDir afterDir(reportDir.filePath("after_to"));
  QString afterPath = afterDir.filePath("rail_record.zip");
  if (QFile::exists(afterPath)) {
    QFileInfo afterFileInfo(afterPath);
    if (afterFileInfo.size() > 0) {
      QUrl afterFileUrl = buildUploadUrl(apiBaseUrl, "/after/", serialNumber, uploadTime, numberTO, model);
      if (!uploadFileSynchronous(afterFileUrl, afterPath)) {
        DEBUG_ERROR_COLORED("NetworkService", "uploadReportSynchronous",
                            "Failed to upload after files, but continuing...", COLOR_BLUE, COLOR_BLUE);
        // Continue even if file upload fails
      }
    } else {
      DEBUG_COLORED("NetworkService", "uploadReportSynchronous", "After files archive is empty, skipping",
                    COLOR_BLUE, COLOR_BLUE);
    }
  } else {
    DEBUG_COLORED("NetworkService", "uploadReportSynchronous", "After files not found, skipping", COLOR_BLUE,
                  COLOR_BLUE);
  }

  DEBUG_COLORED("NetworkService", "uploadReportSynchronous", "Report upload completed successfully",
                COLOR_BLUE, COLOR_BLUE);
  return true;
}

// Asynchronous methods (for compatibility)

void NetworkService::uploadFile(const QUrl& apiUrl, const QString& filePath)
{
  // For compatibility - use synchronous version internally
  bool success = uploadFileSynchronous(apiUrl, filePath);
  emit uploadFinished(success, success ? "" : "Upload failed");
}

void NetworkService::uploadJsonToDjango(const QUrl& apiUrl, const QJsonObject& jsonObject)
{
  // For compatibility - use synchronous version internally
  bool success = uploadJsonToDjangoSynchronous(apiUrl, jsonObject);
  emit uploadFinished(success, success ? "" : "Upload failed");
}

void NetworkService::uploadReport(const QUrl& apiBaseUrl, const QString& reportPath, QString uploadTime,
                                  QString numberTO)
{
  // For compatibility - use synchronous version internally
  bool success = uploadReportSynchronous(apiBaseUrl, reportPath, uploadTime, numberTO);
  emit uploadFinished(success, success ? "" : "Upload failed");
}

void NetworkService::cancelUpload()
{
  DEBUG_COLORED("NetworkService", "cancelUpload", "Canceling current upload", COLOR_BLUE, COLOR_BLUE);
  cleanupCurrentReply();
}

void NetworkService::handleUploadProgress(qint64 bytesSent, qint64 bytesTotal)
{
  emit progressChanged(bytesSent, bytesTotal);
}

void NetworkService::handleUploadFinished()
{
  if (!m_currentReply) {
    DEBUG_ERROR_COLORED("NetworkService", "handleUploadFinished", "No current reply in handleUploadFinished",
                        COLOR_BLUE, COLOR_BLUE);
    return;
  }

  bool success = false;
  QString error;

  if (m_currentReply->error() == QNetworkReply::NoError) {
    int status = m_currentReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    success = (status >= 200 && status < 300);

    if (!success) {
      error = QString("Server error: HTTP %1").arg(status);
      DEBUG_ERROR_COLORED("NetworkService", "handleUploadFinished",
                          QString("Server error: %1 %2").arg(status).arg(QString(m_currentReply->readAll())),
                          COLOR_BLUE, COLOR_BLUE);
    }
  } else if (m_currentReply->error() != QNetworkReply::OperationCanceledError) {
    error = QString("Network error: %1").arg(m_currentReply->errorString());
    DEBUG_ERROR_COLORED("NetworkService", "handleUploadFinished",
                        QString("Network error: %1").arg(m_currentReply->errorString()), COLOR_BLUE,
                        COLOR_BLUE);
  }

  QNetworkReply* reply = m_currentReply;
  m_currentReply = nullptr;
  reply->deleteLater();

  if (!error.isEmpty()) {
    emit errorOccurred(error);
  }
  emit uploadFinished(success, error);
}

void NetworkService::handleUploadFinishedWithResponse()
{
  if (!m_currentReply) {
    emit errorOccurred("No reply available");
    return;
  }

  int statusCode = m_currentReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
  QByteArray responseData = m_currentReply->readAll();
  QString responseString = QString::fromUtf8(responseData);

  if (m_currentReply->error() != QNetworkReply::NoError) {
    QString errorMsg = QString("Network error: %1 (HTTP %2)\nServer response: %3")
                           .arg(m_currentReply->errorString())
                           .arg(statusCode)
                           .arg(responseString);

    DEBUG_ERROR_COLORED("NetworkService", "handleUploadFinishedWithResponse", errorMsg, COLOR_BLUE,
                        COLOR_BLUE);
    emit errorOccurred(errorMsg);
  } else {
    if (statusCode >= 200 && statusCode < 300) {
      DEBUG_COLORED("NetworkService", "handleUploadFinishedWithResponse",
                    QString("Upload successful (HTTP %1)").arg(statusCode), COLOR_BLUE, COLOR_BLUE);
      emit uploadFinished(true, responseString);
    } else {
      QString errorMsg = QString("Server error: HTTP %1\nResponse: %2").arg(statusCode).arg(responseString);
      DEBUG_ERROR_COLORED("NetworkService", "handleUploadFinishedWithResponse", errorMsg, COLOR_BLUE,
                          COLOR_BLUE);
      emit errorOccurred(errorMsg);
    }
  }

  m_currentReply->deleteLater();
  m_currentReply = nullptr;
}

void NetworkService::downloadFile(const QUrl& url, const QString& filePath)
{
  DEBUG_COLORED("NetworkService", "downloadFile",
                QString("Downloading from %1 to %2").arg(url.toString()).arg(filePath), COLOR_BLUE,
                COLOR_BLUE);

  QNetworkRequest request(url);
  QNetworkReply* reply = m_manager->get(request);
  m_currentReply = reply;

  // Create file to save download
  QFile* file = new QFile(filePath);
  if (!file->open(QIODevice::WriteOnly)) {
    DEBUG_ERROR_COLORED("NetworkService", "downloadFile",
                        QString("Failed to open file for writing: %1").arg(file->errorString()), COLOR_BLUE,
                        COLOR_BLUE);
    file->deleteLater();
    emit uploadFinished(false, QString("Failed to create file: %1").arg(file->errorString()));
    return;
  }

  // Connect signals
  connect(reply, &QNetworkReply::downloadProgress, this, &NetworkService::handleUploadProgress);
  connect(reply, &QNetworkReply::readyRead, [this, reply, file]() {
    if (file && file->isOpen()) {
      file->write(reply->readAll());
    }
  });
  connect(reply, &QNetworkReply::finished, [this, reply, file]() {
    file->close();
    file->deleteLater();

    if (reply->error() == QNetworkReply::NoError) {
      DEBUG_COLORED("NetworkService", "downloadFile", "Download completed successfully", COLOR_BLUE,
                    COLOR_BLUE);
      emit uploadFinished(true, "");
    } else {
      DEBUG_ERROR_COLORED("NetworkService", "downloadFile",
                          QString("Download failed: %1").arg(reply->errorString()), COLOR_BLUE, COLOR_BLUE);
      // Delete partially downloaded file
      QFile::remove(file->fileName());
      emit uploadFinished(false, reply->errorString());
    }

    reply->deleteLater();
    m_currentReply = nullptr;
  });
}
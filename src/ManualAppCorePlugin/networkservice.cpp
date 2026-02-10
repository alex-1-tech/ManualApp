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
#include "network/httpclient.h"
#include "network/synchttpclient.h"
#include "reportmanager.h"
#include "settingsmanager.h"


NetworkService::NetworkService(FileService* fileService, ReportManager* reportManager, QObject* parent)
    : QObject(parent)
    , m_fileService(fileService)
    , m_reportManager(reportManager)
{
  DEBUG_COLORED("NetworkService", "Constructor", "Initialized", COLOR_BLUE, COLOR_BLUE);
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

  auto client = new HttpClient();

  connect(client, &HttpClient::progress, this, &NetworkService::onProgress);

  connect(client, &HttpClient::finished, this,
          [client, onSuccess, onError](const HttpClient::HttpResponse& response) {
            if (response.success) {
              QJsonDocument doc = QJsonDocument::fromJson(response.body);
              onSuccess(doc.object());
            } else {
              onError(response.errorMessage);
            }

            client->deleteLater();
          });

  client->get(url);
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
  SyncHttpClient client(30000);

  auto response = client.postFile(apiUrl, filePath);

  if (!response.success) {
    DEBUG_ERROR_COLORED("NetworkService", "uploadFileSynchronous", response.errorMessage, COLOR_BLUE,
                        COLOR_BLUE);
    return false;
  }
  return true;
}

void NetworkService::uploadJsonToDjango(const QUrl& apiUrl, const QJsonObject& jsonObject)
{
  DEBUG_COLORED("NetworkService", "uploadJsonToDjango",
                QString("Uploading JSON to: %1").arg(apiUrl.toString()), COLOR_BLUE, COLOR_BLUE);

  m_isUploadingReport = true;

  auto* client = new HttpClient();

  connect(client, &HttpClient::finished, this, [this, client](const HttpClient::HttpResponse& response) {
    m_isUploadingReport = false;
    emit uploadFinished(response.success, response.errorMessage);
    client->deleteLater();
  });

  client->postJson(apiUrl, jsonObject);
}
void NetworkService::downloadFile(const QUrl& url, const QString& filePath)
{
  DEBUG_COLORED("NetworkService", "downloadFile",
                QString("Downloading from: %1 to %2").arg(url.toString()).arg(filePath), COLOR_BLUE,
                COLOR_BLUE);

  auto* client = new HttpClient();

  connect(client, &HttpClient::progress, this, &NetworkService::onProgress);

  connect(client, &HttpClient::finished, this,
          [this, client, filePath](const HttpClient::HttpResponse& response) {
            if (response.success) {
              QFile file(filePath);
              if (file.open(QIODevice::WriteOnly)) {
                file.write(response.body);
                file.close();
                emit downloadFinished(true, filePath, "");
              } else {
                emit downloadFinished(false, filePath, "Failed to open file for writing");
              }
            } else {
              emit downloadFinished(false, filePath, response.errorMessage);
            }
            client->deleteLater();
          });

  client->get(url);
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

  auto* client = new HttpClient();

  connect(client, &HttpClient::finished, this, [client, callback](const HttpClient::HttpResponse& response) {
    callback(response.success, response.body, response.errorMessage);
    client->deleteLater();
  });

  QJsonDocument doc = QJsonDocument::fromJson(json);
  if (doc.isNull()) {
    callback(false, {}, "Invalid JSON");
    client->deleteLater();
    return;
  }

  client->postJson(request.url(), doc.object());
}


bool NetworkService::uploadReportSynchronous(const QUrl& apiBaseUrl, const QString& reportPath,
                                             QString uploadTime, QString numberTO)
{
  DEBUG_COLORED("NetworkService", "uploadReportSynchronous",
                QString("Uploading report from: %1").arg(reportPath), COLOR_BLUE, COLOR_BLUE);

  QDir reportDir(reportPath);
  if (!reportDir.exists()) return false;

  const QString reportId = reportDir.dirName();
  if (reportId.isEmpty()) return false;

  SettingsManager settings;
  const QString serialNumber = settings.serialNumber();
  const QString model = settings.currentModel();

  if (uploadTime.isEmpty() && m_reportManager) uploadTime = m_reportManager->startTime();

  if (numberTO.isEmpty() && m_reportManager) numberTO = m_reportManager->currentNumberTO();

  if (serialNumber.isEmpty() || model.isEmpty()) return false;

  SyncHttpClient client(30000);

  const QString jsonPath = reportDir.filePath("report.json");
  if (!QFile::exists(jsonPath)) return false;

  QFile jsonFile(jsonPath);
  if (!jsonFile.open(QIODevice::ReadOnly)) return false;

  QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonFile.readAll());
  jsonFile.close();

  if (jsonDoc.isNull()) return false;

  QJsonObject reportData = jsonDoc.object();

  QJsonObject metadata{{"serial_number", serialNumber},
                       {"upload_time", uploadTime},
                       {"number_to", numberTO},
                       {"equipment_type", model}};

  reportData["metadata"] = metadata;
  reportData["report_id"] = reportId;

  QUrl jsonUrl = apiBaseUrl;
  auto jsonResponse = client.postJson(jsonUrl, reportData);
  if (!jsonResponse.success) return false;


  auto uploadOptionalFile = [&](const QString& localPath, const QString& endpoint) -> bool {
    if (!QFile::exists(localPath)) return true;

    QFileInfo info(localPath);
    if (info.size() == 0) return true;

    QUrl fileUrl = buildUploadUrl(apiBaseUrl, endpoint, serialNumber, uploadTime, numberTO, model);

    auto response = client.postFile(fileUrl, localPath);

    if (!response.success) {
      DEBUG_ERROR_COLORED("NetworkService", "uploadReportSynchronous",
                          QString("Failed to upload %1: %2").arg(localPath).arg(response.errorMessage),
                          COLOR_BLUE, COLOR_BLUE);
      return false;
    }

    return true;
  };


  uploadOptionalFile(jsonPath, "/json/");
  uploadOptionalFile(reportDir.filePath("report.pdf"), "/pdf/");
  uploadOptionalFile(reportDir.filePath("before_to/rail_record.zip"), "/before/");
  uploadOptionalFile(reportDir.filePath("after_to/rail_record.zip"), "/after/");

  DEBUG_COLORED("NetworkService", "uploadReportSynchronous", "Report upload completed", COLOR_BLUE,
                COLOR_BLUE);

  return true;
}


void NetworkService::uploadFile(const QUrl& apiUrl, const QString& filePath)
{
  DEBUG_COLORED("NetworkService", "uploadFile",
                QString("Uploading file: %1 to %2").arg(filePath).arg(apiUrl.toString()), COLOR_BLUE,
                COLOR_BLUE);

  m_isUploadingReport = true;

  auto* client = new HttpClient();

  connect(client, &HttpClient::progress, this, &NetworkService::onProgress);

  connect(client, &HttpClient::finished, this, [this, client](const HttpClient::HttpResponse& response) {
    m_isUploadingReport = false;
    emit uploadFinished(response.success, response.errorMessage);
    client->deleteLater();
  });

  client->postFile(apiUrl, filePath);
}

void NetworkService::uploadReport(const QUrl& apiBaseUrl, const QString& reportPath, QString uploadTime,
                                  QString numberTO)
{
  // For compatibility - use synchronous version internally
  bool success = uploadReportSynchronous(apiBaseUrl, reportPath, uploadTime, numberTO);
  emit uploadFinished(success, success ? "" : "Upload failed");
}


void NetworkService::onProgress(qint64 sent, qint64 total)
{
  emit progressChanged(sent, total);
}
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

#include "file/loger.h"
#include "network/httpclient.h"
#include "network/synchttpclient.h"


NetworkService::NetworkService(QObject* parent)
    : QObject(parent)
{
  DEBUG_COLORED("NetworkService", "Constructor", "Initialized", COLOR_BLUE, COLOR_BLUE);
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

  connect(client, &HttpClient::finished, this, [this, client](const HttpClient::HttpResponse& response) {
    emit uploadFinished(response.success, response.errorMessage);
    client->deleteLater();
  });

  client->download(url, filePath);
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


void NetworkService::onProgress(qint64 sent, qint64 total)
{
  emit progressChanged(sent, total);
}
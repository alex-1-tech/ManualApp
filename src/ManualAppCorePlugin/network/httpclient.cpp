#include "httpclient.h"

#include <QFile>
#include <QFileInfo>
#include <QHttpMultiPart>
#include <QJsonDocument>
#include <QNetworkProxy>
#include <QUrlQuery>

HttpClient::HttpClient(QObject* parent)
    : QObject(parent)
{
  m_manager.setProxy(QNetworkProxy::NoProxy);
}

void HttpClient::get(const QUrl& url)
{
  QNetworkRequest request(url);
  QNetworkReply* reply = m_manager.get(request);
  handleReply(reply);
}

void HttpClient::postJson(const QUrl& url, const QJsonObject& jsonObject)
{
  QJsonDocument jsonDoc(jsonObject);
  QByteArray jsonData = jsonDoc.toJson();

  QNetworkRequest request(url);
  request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
  request.setRawHeader("Accept", "application/json");
  request.setHeader(QNetworkRequest::ContentLengthHeader, QVariant(jsonData.size()));
  request.setRawHeader("User-Agent", "Qt/5.15");
  request.setRawHeader("Connection", "keep-alive");


  QNetworkReply* reply = m_manager.post(request, jsonDoc.toJson());

  handleReply(reply);
}

void HttpClient::postFile(const QUrl& url, const QString& filePath)
{
  if (!QFile::exists(filePath)) {
    HttpResponse response;
    response.success = false;
    response.errorMessage = QString("File does not exist: %1").arg(filePath);
    emit finished(response);
    return;
  }

  QFileInfo fileInfo(filePath);
  if (fileInfo.size() == 0) {
    HttpResponse response;
    response.success = false;
    response.errorMessage = QString("File is empty:: %1").arg(filePath);
    emit finished(response);
    return;
  }

  QFile* file = new QFile(filePath);
  if (!file->open(QIODevice::ReadOnly)) {
    HttpResponse response;
    response.success = false;
    response.errorMessage = "Failed to open file";
    emit finished(response);
    delete file;
    return;
  }

  QHttpMultiPart* multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

  QHttpPart filePart;
  QString fileName = QFileInfo(filePath).fileName();
  filePart.setHeader(QNetworkRequest::ContentDispositionHeader,
                     QString("form-data; name=\"file\"; filename=\"%1\"").arg(fileName));
  filePart.setBodyDevice(file);

  file->setParent(multiPart);
  multiPart->append(filePart);

  QNetworkRequest request(url);
  QNetworkReply* reply = m_manager.post(request, multiPart);

  multiPart->setParent(reply);

  connect(reply, &QNetworkReply::uploadProgress, this, &HttpClient::progress);

  handleReply(reply);
}

void HttpClient::handleReply(QNetworkReply* reply)
{
  connect(reply, &QNetworkReply::finished, this, [this, reply]() {
    HttpResponse response;
    response.statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

    response.body = reply->readAll();

    if (reply->error() == QNetworkReply::NoError && response.statusCode >= 200 && response.statusCode < 300) {
      response.success = true;
    } else {
      response.success = false;

      if (!response.body.isEmpty()) response.errorMessage = parseDjangoError(response.body);

      if (response.errorMessage.isEmpty()) response.errorMessage = reply->errorString();
    }

    emit finished(response);

    reply->deleteLater();
  });
}

QString HttpClient::parseDjangoError(const QByteArray& data) const
{
  QJsonDocument doc = QJsonDocument::fromJson(data);
  if (!doc.isObject()) return {};

  QJsonObject obj = doc.object();

  if (obj.contains("error")) return obj["error"].toString();
  if (obj.contains("detail")) return obj["detail"].toString();
  if (obj.contains("message")) return obj["message"].toString();

  return QString::fromUtf8(data).left(500);
}

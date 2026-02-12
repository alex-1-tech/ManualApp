#include "httpclient.h"

#include <QFile>
#include <QFileInfo>
#include <QHttpMultiPart>
#include <QJsonDocument>
#include <QNetworkProxy>
#include <QUrlQuery>

#include "djangoerrorparser.h"

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

  connect(reply, &QNetworkReply::errorOccurred, this, [this, reply](QNetworkReply::NetworkError code) {
    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QByteArray responseData = reply->readAll();
    QString djangoError = DjangoErrorParser::parse(responseData);

    qDebug() << "Network error occurred:" << code << reply->errorString();
    qDebug() << "HTTP Status:" << statusCode;
    if (!djangoError.isEmpty()) {
      qDebug() << "Django error:" << djangoError;
    }

    HttpResponse response;
    response.success = false;
    response.statusCode = statusCode;
    response.errorMessage = !djangoError.isEmpty() ? djangoError : reply->errorString();
    response.body = responseData;

    emit finished(response);
    reply->deleteLater();
  });

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
    response.errorMessage = QString("File is empty: %1").arg(filePath);
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
  connect(reply, &QNetworkReply::errorOccurred, this,
          [this, reply](QNetworkReply::NetworkError code) { handleNetworkError(reply, code); });

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
      response.errorMessage = QString();
    } else {
      response.success = false;

      // Парсим ошибку Django
      response.errorMessage = DjangoErrorParser::parse(response.body);

      // Если не удалось распарсить ошибку Django, используем стандартное сообщение
      if (response.errorMessage.isEmpty()) {
        response.errorMessage = reply->errorString();
      }

      // Выводим детальную информацию об ошибке
      qDebug() << "=== HTTP Error ===";
      qDebug() << "Status code:" << response.statusCode;
      qDebug() << "Network error:" << reply->errorString();
      qDebug() << "Django error:" << response.errorMessage;

      // Для статусов 400-500 выводим дополнительную информацию
      if (response.statusCode >= 400 && response.statusCode <= 599) {
        qDebug() << "HTTP error range:" << response.statusCode / 100 << "xx";

        // Детализация по кодам
        if (response.statusCode == 400)
          qDebug() << "Bad Request";
        else if (response.statusCode == 401)
          qDebug() << "Unauthorized";
        else if (response.statusCode == 403)
          qDebug() << "Forbidden";
        else if (response.statusCode == 404)
          qDebug() << "Not Found";
        else if (response.statusCode == 422)
          qDebug() << "Unprocessable Entity";
        else if (response.statusCode == 429)
          qDebug() << "Too Many Requests";
        else if (response.statusCode >= 500)
          qDebug() << "Server Error";
      }
      qDebug() << "===================";
    }

    emit finished(response);
    reply->deleteLater();
  });
}

void HttpClient::handleNetworkError(QNetworkReply* reply, QNetworkReply::NetworkError code)
{
  int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
  QByteArray responseData = reply->readAll();
  QString djangoError = DjangoErrorParser::parse(responseData);

  qDebug() << "=== Network Error ===";
  qDebug() << "Error code:" << code;
  qDebug() << "HTTP Status:" << statusCode;
  qDebug() << "Network message:" << reply->errorString();
  if (!djangoError.isEmpty()) {
    qDebug() << "Django error:" << djangoError;
  }
  qDebug() << "=====================";

  HttpResponse response;
  response.success = false;
  response.statusCode = statusCode;
  response.errorMessage = !djangoError.isEmpty() ? djangoError : reply->errorString();
  response.body = responseData;

  emit finished(response);
}

// Удаляем старый parseDjangoError, так как используем DjangoErrorParser
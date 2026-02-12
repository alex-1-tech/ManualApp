#pragma once

#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>

class HttpClient : public QObject
{
  Q_OBJECT
public:
  struct HttpResponse {
    bool success = false;
    int statusCode = 0;
    QByteArray body;
    QString errorMessage;
  };

  explicit HttpClient(QObject* parent = nullptr);

  void get(const QUrl& url);
  void postJson(const QUrl& url, const QJsonObject& json);
  void postFile(const QUrl& url, const QString& filePath);
  void download(const QUrl& url, const QString& filePath);
signals:
  void finished(const HttpClient::HttpResponse& response);
  void progress(qint64 sent, qint64 total);

private:
  void handleReply(QNetworkReply* reply);
  void handleNetworkError(QNetworkReply* reply, QNetworkReply::NetworkError code);

private:
  QNetworkAccessManager m_manager;
};

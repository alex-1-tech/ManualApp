#pragma once

#include <QDebug>
#include <QEventLoop>
#include <QFile>
#include <QHttpMultiPart>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>
#include <QUrl>
#include <QUrlQuery>

class FileService;

class NetworkService : public QObject
{
  Q_OBJECT

public:
  // Construction/Destruction
  explicit NetworkService(QObject* parent = nullptr);
  ~NetworkService() = default;
  // Synchronous upload methods
  bool uploadFileSynchronous(const QUrl& apiUrl, const QString& filePath);
  bool uploadJsonToDjangoSynchronous(const QUrl& apiUrl, const QJsonObject& jsonObject);

  // Asynchronous methods (kept for compatibility)
  void getJsonFromDjango(const QUrl& url, std::function<void(const QJsonObject&)> onSuccess,
                         std::function<void(const QString&)> onError);
  void uploadFile(const QUrl& apiUrl, const QString& filePath);
  void uploadJsonToDjango(const QUrl& apiUrl, const QJsonObject& jsonObject);
  void downloadFile(const QUrl& url, const QString& filePath);

  // Control methods
  void cancelUpload();

  // Post methods
  void postJson(const QNetworkRequest& request, const QByteArray& json,
                std::function<void(bool success, QByteArray response, QString error)> callback);


signals:
  // Upload status signals
  void uploadFinished(bool success, const QString& error);
  void progressChanged(qint64 bytesSent, qint64 bytesTotal);
  void errorOccurred(const QString& error);
private slots:
  void onProgress(qint64 sent, qint64 total);

private:
  // Private helper methods
  QUrl buildUploadUrl(const QUrl& apiBaseUrl, const QString& endpoint, const QString& serialNumber,
                      const QString& uploadTime, const QString& numberTO, const QString& model);

private:
  // Upload state
  bool m_isUploadingReport = false;

  // Service dependencies
  FileService* m_fileService;
};
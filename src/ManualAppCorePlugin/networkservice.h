#pragma once

#include <QDebug>
#include <QFile>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>
#include <QUrl>

class FileService;
class ReportManager;

class NetworkService : public QObject {
  Q_OBJECT

public:
  // Construction/Destruction
  explicit NetworkService(FileService *fileService,
                          ReportManager *reportManager,
                          QObject *parent = nullptr);
  ~NetworkService();

  // Status methods
  bool isUploadingReport() const { return m_isUploadingReport; }

  // Upload methods - Generic
  void uploadFile(const QUrl &apiUrl, const QString &filePath);
  void uploadJsonToDjango(const QUrl &apiUrl, const QJsonObject &jsonObject);
  void getJsonFromDjango(const QUrl &url,
                         std::function<void(const QJsonObject &)> onSuccess,
                         std::function<void(const QString &)> onError);

  // Upload methods - Report specific
  void uploadReport(const QUrl &apiBaseUrl, const QString &reportPath,
                    QString uploadTime = "", QString numberTO = "");
  void uploadReportJsonFile();
  void uploadReportPdfFile();
  void uploadReportBeforeFiles();
  void uploadReportAfterFiles();
  void uploadReportJsonData();

  // Control methods
  void cancelUpload();
  void completeUpload();
  void handleUploadError(const QString &error);
  void setReportManager(ReportManager *reportManager);

signals:
  // Upload status signals
  void uploadFinished(bool success, const QString &error);
  void progressChanged(qint64 bytesSent, qint64 bytesTotal);
  void errorOccurred(const QString &error);

private slots:
  // Progress handlers
  void handleUploadProgress(qint64 bytesSent, qint64 bytesTotal);
  void handleUploadFinished();
  void handleUploadFinishedWithResponse();

  // Completion handlers for different upload types
  void handleJsonDataUploadFinished(bool success, const QString &error);
  void handleJsonFileUploadFinished(bool success, const QString &error);
  void handlePdfFileUploadFinished(bool success, const QString &error);
  void handleBeforeFilesUploadFinished(bool success, const QString &error);
  void handleAfterFilesUploadFinished(bool success, const QString &error);
  
private:
  // Private helper methods
  void cleanupCurrentReply();

private:
  // Upload state
  bool m_isUploadingReport = false;
  int m_currentUploadStep = 0;

  // Current upload context
  QUrl m_currentApiUrl;
  QString m_currentReportPath;
  QString m_currentUploadTime;
  QString m_currentNumberTO;
  QString m_currentSerialNumber;
  QString m_currentModel;

  // Network components
  QNetworkAccessManager *m_manager;
  QNetworkReply *m_currentReply;

  // Service dependencies
  FileService *m_fileService;
  ReportManager *m_reportManager;
};
#pragma once

#include <QDebug>
#include <QFile>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>
#include <QUrl>
#include <QEventLoop>
#include <QHttpMultiPart>
#include <QUrlQuery>

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

    // Synchronous upload methods
    bool uploadReportSynchronous(const QUrl &apiBaseUrl, const QString &reportPath,
                               QString uploadTime = "", QString numberTO = "");
    bool uploadFileSynchronous(const QUrl &apiUrl, const QString &filePath);
    bool uploadJsonToDjangoSynchronous(const QUrl &apiUrl, const QJsonObject &jsonObject);
    
    // Asynchronous methods (kept for compatibility)
    void getJsonFromDjango(const QUrl &url,
                          std::function<void(const QJsonObject &)> onSuccess,
                          std::function<void(const QString &)> onError);
    void uploadFile(const QUrl &apiUrl, const QString &filePath);
    void uploadJsonToDjango(const QUrl &apiUrl, const QJsonObject &jsonObject);
    void uploadReport(const QUrl &apiBaseUrl, const QString &reportPath,
                     QString uploadTime = "", QString numberTO = "");
    void downloadFile(const QUrl &url, const QString &filePath);

    // Control methods
    void cancelUpload();
    void setReportManager(ReportManager *reportManager);

signals:
    // Upload status signals
    void uploadFinished(bool success, const QString &error);
    void progressChanged(qint64 bytesSent, qint64 bytesTotal);
    void errorOccurred(const QString &error);

private slots:
    // Progress handlers for async operations
    void handleUploadProgress(qint64 bytesSent, qint64 bytesTotal);
    void handleUploadFinished();
    void handleUploadFinishedWithResponse();

private:
    // Private helper methods
    void cleanupCurrentReply();
    bool waitForReplyFinished(QNetworkReply *reply, int timeoutMs = 30000);
    QUrl buildUploadUrl(const QUrl &apiBaseUrl, const QString &endpoint, 
                       const QString &serialNumber, const QString &uploadTime, 
                       const QString &numberTO, const QString &model);

private:
    // Upload state
    bool m_isUploadingReport = false;

    // Network components
    QNetworkAccessManager *m_manager;
    QNetworkReply *m_currentReply;

    // Service dependencies
    FileService *m_fileService;
    ReportManager *m_reportManager;
};
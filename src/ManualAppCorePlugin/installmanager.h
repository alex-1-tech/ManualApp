#pragma once

#include <QObject>
#include <QProcess>
#include <QTimer>
#include <QFile>
#include <QQmlEngine>
#include <qqmlintegration.h>
#include "networkservice.h"
#include "fileservice.h"
#include "reportmanager.h"

class InstallManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)
    Q_PROPERTY(bool isInstalling READ isInstalling NOTIFY isInstallingChanged)
    Q_PROPERTY(QString installerPath READ installerPath NOTIFY installerPathChanged)
    Q_PROPERTY(bool isDownloading READ isDownloading NOTIFY isDownloadingChanged)
    Q_PROPERTY(double downloadProgress READ downloadProgress NOTIFY downloadProgressChanged)

public:
    explicit InstallManager(QObject *parent = nullptr);
    ~InstallManager();

    QString statusMessage() const { return m_statusMessage; }
    bool isInstalling() const { return m_isInstalling; }
    QString installerPath() const { return m_installerPath; }
    bool isDownloading() const { return m_isDownloading; }
    double downloadProgress() const { return m_downloadProgress; }

    Q_INVOKABLE bool installerExists(const QString &model) const;
    Q_INVOKABLE void downloadInstaller(const QString &model);
    Q_INVOKABLE void runInstaller(const QString &model);

signals:
    void statusMessageChanged();
    void isInstallingChanged();
    void installerPathChanged();
    void installationStarted();
    void installationFinished(bool success);
    void errorOccurred(const QString &error);
    void isDownloadingChanged();
    void downloadProgressChanged();
    void downloadFinished(bool success);

private slots:
    void onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void onProcessErrorOccurred(QProcess::ProcessError error);
    void onTimeout();
    void onDownloadProgress(qint64 bytesSent, qint64 bytesTotal);

private:
    void cleanupProcess();
    void setStatusMessage(const QString &message);
    void setIsInstalling(bool installing);
    void setInstallerPath(const QString &path);
    void setIsDownloading(bool downloading);
    void setDownloadProgress(double progress);
    
    QString buildInstallerPath(const QString &model) const;
    QString buildDownloadUrl(const QString &model) const;
    void initializeNetworkService();

    QString m_statusMessage;
    bool m_isInstalling;
    QString m_installerPath;
    bool m_isDownloading;
    double m_downloadProgress;

    QProcess *m_process;
    QTimer *m_timeoutTimer;
    NetworkService *m_networkService;
    FileService *m_fileService;
    ReportManager *m_reportManager;
};
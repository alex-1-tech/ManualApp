#pragma once

#include <qqmlintegration.h>

#include <QFile>
#include <QObject>
#include <QProcess>
#include <QQmlEngine>
#include <QTimer>

#include "networkservice.h"
#include "reportmanager.h"

class InstallManager : public QObject
{
  Q_OBJECT

  Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)
  Q_PROPERTY(bool isInstalling READ isInstalling NOTIFY isInstallingChanged)
  Q_PROPERTY(QString installerPath READ installerPath NOTIFY installerPathChanged)
  Q_PROPERTY(bool isDownloading READ isDownloading NOTIFY isDownloadingChanged)
  Q_PROPERTY(double downloadProgress READ downloadProgress NOTIFY downloadProgressChanged)
public:
  explicit InstallManager(QObject* parent = nullptr, ReportManager* reportManager = nullptr);
  ~InstallManager();

  QString statusMessage() const { return m_statusMessage; }
  bool isInstalling() const { return m_isInstalling; }
  QString installerPath() const { return m_installerPath; }
  bool isDownloading() const { return m_isDownloading; }
  double downloadProgress() const { return m_downloadProgress; }

  Q_INVOKABLE bool installerExists(const QString& model) const;
  Q_INVOKABLE void downloadInstaller(const QString& model, const QString& baseUrl,
                                     const QString& railTypeMode);
  Q_INVOKABLE void runInstaller(const QString& model);
  Q_INVOKABLE void activate(const QString& model, const QString& hostHWID, const QString& deviceHWID,
                            const QString& mode, const QString& url, const QString& licensePassword);
  Q_INVOKABLE QString buildInstallerPath(const QString& model) const;
  Q_INVOKABLE QString getLastUpdateDate(const QString& baseUrl, const QString& model,
                                        const QString& railTypeMode);

signals:
  void statusMessageChanged();
  void isInstallingChanged();
  void installerPathChanged();
  void installationStarted();
  void installationFinished(bool success);
  void errorOccurred(const QString& error);
  void isDownloadingChanged();
  void isLicenseActivateChanged();
  void downloadProgressChanged();
  void downloadFinished(bool success);
  void activationSucceeded();
  void activationFailed(const QString& error);
private slots:
  void onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
  void onProcessErrorOccurred(QProcess::ProcessError error);
  void onTimeout();
  void onDownloadProgress(qint64 bytesSent, qint64 bytesTotal);

private:
  void handleActivationResponse(const QByteArray& response);
  bool saveLicenseToDisk(const QJsonObject& license);

  void cleanupProcess();
  void setStatusMessage(const QString& message);
  void setIsInstalling(bool installing);
  void setInstallerPath(const QString& path);
  void setIsDownloading(bool downloading);
  void setDownloadProgress(double progress);


  QString buildDownloadUrl(const QString& model, const QString& baseUrl, const QString& railTypeMode,
                           const QString& apiUrl) const;
  void initializeNetworkService();

  QString m_statusMessage;
  bool m_isInstalling;
  QString m_installerPath;
  bool m_isDownloading;
  double m_downloadProgress;

  QProcess* m_process;
  QTimer* m_timeoutTimer;
  ReportManager* m_reportManager;
};
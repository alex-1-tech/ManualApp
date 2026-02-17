#include "installmanager.h"

#include <QCoreApplication>
#include <QDir>
#include <QNetworkRequest>

#include "datamanager.h"
#include "fileservice.h"
#include "loger.h"
#include "reportmanager.h"

InstallManager::InstallManager(QObject* parent, ReportManager* reportManager)
    : QObject(parent)
    , m_statusMessage("Ready to download and install")
    , m_isInstalling(false)
    , m_isDownloading(false)
    , m_downloadProgress(0.0)
    , m_process(nullptr)
    , m_timeoutTimer(nullptr)
    , m_reportManager(nullptr)
{
  DEBUG_COLORED("InstallManager", "Constructor", "InstallManager initialized", COLOR_CYAN, COLOR_CYAN);
  m_reportManager = reportManager;
  initializeNetworkService();
}

InstallManager::~InstallManager()
{
  cleanupProcess();
}

void InstallManager::initializeNetworkService()
{
  // Connect download progress and completion signals
  connect(m_reportManager->networkService(), &NetworkService::progressChanged, this,
          &InstallManager::onDownloadProgress);
  connect(m_reportManager->networkService(), &NetworkService::uploadFinished, this,
          [this](bool success, const QString& error) {
            if (success) {
              DEBUG_COLORED("InstallManager", "downloadFinished", "Download completed", COLOR_CYAN,
                            COLOR_CYAN);
              setStatusMessage("Download completed successfully!");
            } else {
              DEBUG_ERROR_COLORED("InstallManager", "downloadFinished",
                                  QString("Download failed: %1").arg(error), COLOR_CYAN, COLOR_CYAN);
              setStatusMessage(QString("Download failed: %1").arg(error));
            }
            setIsDownloading(false);
            emit downloadFinished(success);
          });
}

QString InstallManager::buildInstallerPath(const QString& model) const
{
  // Use application data directory instead of temp
  QString appDataDir = m_reportManager->fileService()->getAppDataPath();
  QString installerName;

  if (model.toLower() == "kalmar32") {
    installerName = "/Kalmar.exe";
  } else if (model.toLower() == "phasar32") {
    installerName = "/Phasar.exe";
  } else if (model.toLower() == "manual_app") {
    installerName = "/ManualApp.exe";
  } else {
    DEBUG_ERROR_COLORED("InstallManager", "buildInstallerPath", QString("Unknown model: %1").arg(model),
                        COLOR_CYAN, COLOR_CYAN);
    return QString();
  }

  return appDataDir + installerName;
}

QString InstallManager::buildDownloadUrl(const QString& model, const QString& baseUrl,
                                         const QString& railTypeMode) const
{
  if (model.toLower() == "kalmar32") {
    QUrl url(baseUrl + "/api/apps/download/kalmar32/");
    QUrlQuery query;
    if (!railTypeMode.isEmpty()) {
      query.addQueryItem("rail_type", railTypeMode.toUpper().trimmed());
    }
    url.setQuery(query);
    return url.toString();
  } else if (model.toLower() == "phasar32") {
    return baseUrl + "/api/apps/download/phasar32/";
  } else if (model.toLower() == "manual_app") {
    return baseUrl + "/api/apps/download/manual_app/";
  } else {
    DEBUG_ERROR_COLORED("InstallManager", "buildDownloadUrl", QString("Unknown model: %1").arg(model),
                        COLOR_CYAN, COLOR_CYAN);
    return QString();
  }
}

bool InstallManager::installerExists(const QString& model) const
{
  QString path = buildInstallerPath(model);

  if (path.isEmpty()) {
    return false;
  }

  bool exists = QFile::exists(path);
  DEBUG_COLORED("InstallManager", "installerExists",
                QString("Installer %1 exists: %2").arg(path).arg(exists ? "true" : "false"), COLOR_CYAN,
                COLOR_CYAN);
  return exists;
}

void InstallManager::downloadInstaller(const QString& model, const QString& baseUrl,
                                       const QString& railTypeMode)
{
  DEBUG_COLORED("InstallManager", "downloadInstaller", QString("Starting download for model: %1").arg(model),
                COLOR_CYAN, COLOR_CYAN);

  if (m_isDownloading) {
    DEBUG_COLORED("InstallManager", "downloadInstaller", "Download already in progress", COLOR_CYAN,
                  COLOR_CYAN);
    return;
  }

  QString url = buildDownloadUrl(model, baseUrl, railTypeMode);
  QString path = buildInstallerPath(model);

  if (url.isEmpty() || path.isEmpty()) {
    setStatusMessage("Error: Unknown device model");
    return;
  }

  QDir appDataDir(m_reportManager->fileService()->getAppDataPath());
  if (!appDataDir.exists()) {
    appDataDir.mkpath(".");
  }

  setIsDownloading(true);
  setDownloadProgress(0.0);
  setStatusMessage("Starting download...");


  m_reportManager->networkService()->downloadFile(QUrl(url), path);
}

void InstallManager::onDownloadProgress(qint64 bytesSent, qint64 bytesTotal)
{
  if (bytesTotal > 0) {
    double progress = (static_cast<double>(bytesSent) / bytesTotal) * 100.0;
    setDownloadProgress(progress);
    setStatusMessage(QString("Downloading: %1% (%2/%3 KB)")
                         .arg(static_cast<int>(progress))
                         .arg(bytesSent / 1024)
                         .arg(bytesTotal / 1024));
  }
}

void InstallManager::runInstaller(const QString& model)
{
  DEBUG_COLORED("InstallManager", "runInstaller", QString("Starting installer for model: %1").arg(model),
                COLOR_CYAN, COLOR_CYAN);

  if (m_isInstalling) {
    DEBUG_COLORED("InstallManager", "runInstaller", "Installation already in progress", COLOR_CYAN,
                  COLOR_CYAN);
    return;
  }

  // Use downloaded installer path
  QString path = buildInstallerPath(model);
  if (path.isEmpty()) {
    setStatusMessage("Error: Unknown device model");
    return;
  }

  // Check if installer exists
  if (!QFile::exists(path)) {
    DEBUG_ERROR_COLORED("InstallManager", "runInstaller", QString("Installer not found: %1").arg(path),
                        COLOR_CYAN, COLOR_CYAN);
    setStatusMessage("Installer not found. Please download first.");
    emit errorOccurred(QString("Installer not found: %1").arg(path));
    return;
  }

  setInstallerPath(path);
  setIsInstalling(true);
  setStatusMessage("Starting installation...");

  try {
    cleanupProcess();

    m_process = new QProcess(this);
    m_timeoutTimer = new QTimer(this);

    // Connect signals
    connect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), this,
            &InstallManager::onProcessFinished);
    connect(m_process, &QProcess::errorOccurred, this, &InstallManager::onProcessErrorOccurred);
    connect(m_timeoutTimer, &QTimer::timeout, this, &InstallManager::onTimeout);

    QFileInfo fileInfo(path);
    m_process->setWorkingDirectory(fileInfo.path());

    setStatusMessage("Running installer...");

    // Simply start the installer
    m_process->start(path, QStringList());
    bool started = m_process->waitForStarted(5000);

    if (started) {
      DEBUG_COLORED("InstallManager", "runInstaller", "Installer started successfully", COLOR_CYAN,
                    COLOR_CYAN);
      setStatusMessage("Installer started! Please follow the installation steps.");
      emit installationStarted();

      // Start timeout timer
      m_timeoutTimer->start(30000);
    } else {
      DEBUG_ERROR_COLORED("InstallManager", "runInstaller", "Failed to start installer process", COLOR_CYAN,
                          COLOR_CYAN);
      setStatusMessage("Failed to start installer. Please run manually.");
      emit errorOccurred("Failed to start installer process");
      cleanupProcess();
      setIsInstalling(false);
    }

  } catch (const std::exception& e) {
    DEBUG_ERROR_COLORED("InstallManager", "runInstaller", QString("Exception: %1").arg(e.what()), COLOR_CYAN,
                        COLOR_CYAN);
    setStatusMessage(QString("Error starting installer: %1").arg(e.what()));
    emit errorOccurred(QString("Exception: %1").arg(e.what()));
    cleanupProcess();
    setIsInstalling(false);
  }
}

void InstallManager::onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
  DEBUG_COLORED("InstallManager", "onProcessFinished",
                QString("Process finished with exit code: %1, status: %2").arg(exitCode).arg(exitStatus),
                COLOR_CYAN, COLOR_CYAN);

  if (m_timeoutTimer && m_timeoutTimer->isActive()) {
    m_timeoutTimer->stop();
  }

  bool success = (exitStatus == QProcess::NormalExit && exitCode == 0);

  if (success) {
    setStatusMessage("Installation completed successfully!");
    DEBUG_COLORED("InstallManager", "onProcessFinished", "Installation completed successfully", COLOR_CYAN,
                  COLOR_CYAN);
  } else {
    setStatusMessage(QString("Installation finished with exit code: %1").arg(exitCode));
    DEBUG_ERROR_COLORED("InstallManager", "onProcessFinished",
                        QString("Installation failed with exit code: %1").arg(exitCode), COLOR_CYAN,
                        COLOR_CYAN);
  }

  emit installationFinished(success);
  cleanupProcess();
  setIsInstalling(false);
}

void InstallManager::onProcessErrorOccurred(QProcess::ProcessError error)
{
  DEBUG_ERROR_COLORED("InstallManager", "onProcessErrorOccurred", QString("Process error: %1").arg(error),
                      COLOR_CYAN, COLOR_CYAN);

  if (m_timeoutTimer && m_timeoutTimer->isActive()) {
    m_timeoutTimer->stop();
  }

  QString errorMessage;
  switch (error) {
    case QProcess::FailedToStart:
      errorMessage = "Installer failed to start. File may be missing or permissions insufficient.";
      break;
    case QProcess::Crashed: errorMessage = "Installer crashed during execution."; break;
    case QProcess::Timedout: errorMessage = "Installer timed out."; break;
    case QProcess::WriteError: errorMessage = "Write error occurred with installer."; break;
    case QProcess::ReadError: errorMessage = "Read error occurred with installer."; break;
    default: errorMessage = "Unknown error occurred with installer."; break;
  }

  setStatusMessage(errorMessage);
  emit errorOccurred(errorMessage);
  cleanupProcess();
  setIsInstalling(false);
}

void InstallManager::onTimeout()
{
  DEBUG_COLORED("InstallManager", "onTimeout", "Process timeout reached", COLOR_CYAN, COLOR_CYAN);

  if (m_process && m_process->state() == QProcess::Running) {
    DEBUG_COLORED("InstallManager", "onTimeout", "Terminating hung process", COLOR_CYAN, COLOR_CYAN);
    m_process->terminate();

    // Wait for termination
    if (!m_process->waitForFinished(5000)) {
      DEBUG_ERROR_COLORED("InstallManager", "onTimeout", "Process did not terminate, killing", COLOR_CYAN,
                          COLOR_CYAN);
      m_process->kill();
    }
  }

  setStatusMessage("Installation timeout. Please check if installer started properly.");
  emit errorOccurred("Installation timeout");
  cleanupProcess();
  setIsInstalling(false);
}

void InstallManager::cleanupProcess()
{
  if (m_process) {
    if (m_process->state() == QProcess::Running) {
      m_process->terminate();
      m_process->waitForFinished(1000);
    }
    m_process->deleteLater();
    m_process = nullptr;
  }

  if (m_timeoutTimer) {
    if (m_timeoutTimer->isActive()) {
      m_timeoutTimer->stop();
    }
    m_timeoutTimer->deleteLater();
    m_timeoutTimer = nullptr;
  }
}

void InstallManager::setStatusMessage(const QString& message)
{
  if (m_statusMessage != message) {
    m_statusMessage = message;
    emit statusMessageChanged();
  }
}

void InstallManager::setIsInstalling(bool installing)
{
  if (m_isInstalling != installing) {
    m_isInstalling = installing;
    emit isInstallingChanged();
  }
}

void InstallManager::setIsLicenseActivate(bool activating)
{
  if (m_isLicenseActivate != activating) {
    m_isLicenseActivate = activating;
    emit isLicenseActivateChanged();
  }
}

void InstallManager::setInstallerPath(const QString& path)
{
  if (m_installerPath != path) {
    m_installerPath = path;
    emit installerPathChanged();
  }
}

void InstallManager::setIsDownloading(bool downloading)
{
  if (m_isDownloading != downloading) {
    m_isDownloading = downloading;
    emit isDownloadingChanged();
  }
}

void InstallManager::setDownloadProgress(double progress)
{
  if (!qFuzzyCompare(m_downloadProgress, progress)) {
    m_downloadProgress = progress;
    emit downloadProgressChanged();
  }
}

QString getVersionFromRegistry(const QString& model)
{
  QString keyPath;

  if (model.toLower() == "phasar32") {
    keyPath = "HKEY_LOCAL_MACHINE\\Software\\Technovotum\\Phasar";
  } else if (model.toLower() == "kalmar32") {
    keyPath = "HKEY_LOCAL_MACHINE\\Software\\Technovotum\\Kalmar";
    return "";
  } else {
    return "";
  }

  QSettings registry(keyPath, QSettings::NativeFormat);
  return registry.value("LicenseVer", "").toString();
}

void InstallManager::activate(const QString& model, const QString& hostHWID, const QString& deviceHWID,
                              const QString& mode, const QString& url, const QString& licensePassword)
{
  if (hostHWID.isEmpty() && deviceHWID.isEmpty()) {
    emit activationFailed("HWID is empty");
    return;
  }

  setStatusMessage("Activating license...");
  QJsonObject features;
  features["saved_data"] = true;
  features["device_modes"] = true;
  if (mode == "analysis") features["saved_data"] = false;

  QJsonObject payload;
  payload["ver"] = getVersionFromRegistry(model);
  if (model == "phasar32")
    payload["product"] = "Phasar";
  else if (model == "kalmar32")
    payload["product"] = "Kalmar";

  payload["company_name"] = "technovotum";

  if (!hostHWID.isEmpty()) {
    payload["host_hwid"] = hostHWID;
  }

  if (!deviceHWID.isEmpty()) {
    payload["device_hwid"] = deviceHWID;
  }

  payload["exp"] = "2100-01-01";
  payload["features"] = features;
  payload["license_password"] = licensePassword;

  QNetworkRequest request(url);
  request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

  m_reportManager->networkService()->postJson(
      request, QJsonDocument(payload).toJson(),
      [this](bool success, const QByteArray& response, const QString& error) {
        if (!success) {
          emit activationFailed(error);
          setStatusMessage("Activation failed");
          return;
        }

        handleActivationResponse(response);
      });
}


void InstallManager::handleActivationResponse(const QByteArray& response)
{
  QJsonParseError err{};
  QJsonDocument doc = QJsonDocument::fromJson(response, &err);

  if (err.error != QJsonParseError::NoError || !doc.isObject()) {
    emit activationFailed("Invalid server response");
    return;
  }

  QJsonObject root = doc.object();

  if (root["status"].toString() != "ok") {
    emit activationFailed(root["error"].toString("Activation error"));
    return;
  }

  QJsonObject license = root["license"].toObject();
  if (license.isEmpty()) {
    emit activationFailed("License missing in response");
    return;
  }

  m_reportManager->settingsManager()->saveLicense(license);
  if (!m_reportManager->settingsManager()->hasLicense()) {
    emit activationFailed("Failed to save license to settings");
    return;
  }

  emit activationSucceeded();
  setStatusMessage("License activated successfully");
}

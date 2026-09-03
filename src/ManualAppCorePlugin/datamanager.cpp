#include "datamanager.h"

#include <QCoreApplication>
#include <QDebug>
#include <QDir>
#include <QJsonArray>
#include <QJsonObject>
#include <QTimer>

#include "file/fileservice.h"
#include "file/loger.h"
#include "networkservice.h"
#include "software/licensehandler.h"


DataManager::DataManager(QObject* parent)
    : QObject(parent)
{
  m_fileService = std::make_unique<FileService>(this);
  m_networkService = std::make_unique<NetworkService>(this);
  m_licenseHandler = std::make_unique<LicenseHandler>(this);

  DEBUG_COLORED("DataManager", "Constructor", "DataManager initialized", COLOR_CYAN, COLOR_CYAN);
}
DataManager::~DataManager()
{
  DEBUG_COLORED("DataManager", "Destructor", "Destroying DataManager", COLOR_CYAN, COLOR_CYAN);
  shutdown();
}
void DataManager::shutdown()
{
  DEBUG_COLORED("DataManager", "shutdown", "Stopping all operations", COLOR_CYAN, COLOR_CYAN);
}


QString DataManager::createSettingsJsonFile(const QString& filePath)
{
  DEBUG_COLORED("DataManager", "createSettingsJsonFile",
                QString("Creating settings JSON at: %1").arg(filePath), COLOR_CYAN, COLOR_CYAN);
  if (!m_settingsManager) {
    setError("SettingsManager не инициализирован");
    return QString();
  }
  return m_fileService->saveJsonToFile(filePath, m_settingsManager->toJsonForDjango()) ? filePath : QString();
}
bool DataManager::isValidApiUrl(const QUrl& apiUrl)
{
  return !apiUrl.isValid() || apiUrl.scheme().isEmpty();
}
bool DataManager::deleteSettingsJsonFile(const QString& filePath)
{
  DEBUG_COLORED("DataManager", "deleteSettingsJsonFile", QString("Deleting file: %1").arg(filePath),
                COLOR_CYAN, COLOR_CYAN);
  return m_fileService->deleteFile(filePath);
}


void DataManager::setSettingsManager(SettingsManager* manager)
{
  if (m_settingsManager != manager) {
    m_settingsManager = manager;
    emit settingsManagerChanged();
  }
}

void DataManager::setCurrentSettings(const QUrl& apiUrl)
{
  DEBUG_COLORED("DataManager", "setCurrentSettings",
                QString("Download settings from %1").arg(apiUrl.toString()), COLOR_CYAN, COLOR_CYAN);

  if (isValidApiUrl(apiUrl)) {
    setError("Invalid API URL: must include http:// or https://");
    return;
  }

  setLoading(true);
  setError("");

  m_networkService->getJsonFromDjango(
      apiUrl,
      [this](const QJsonObject& json) {
        if (json.isEmpty()) {
          setError("Received empty settings JSON.");
          setLoading(false);
          return;
        }

        QJsonObject settingsObj = json;
        if (json.contains("settings") && json["settings"].isObject()) {
          settingsObj = json["settings"].toObject();
        }
        m_settingsManager->fromJson(settingsObj);

        DEBUG_COLORED("DataManager", "setCurrentSettings", "Settings successfully downloaded and applied",
                      COLOR_CYAN, COLOR_CYAN);

        setLoading(false);
      },
      [this](const QString& error) {
        DEBUG_ERROR_COLORED("DataManager", "setCurrentSettings",
                            QString("Failed to download settings: %1").arg(error), COLOR_CYAN, COLOR_CYAN);
        setError(error);
        setLoading(false);
      });
}

void DataManager::fetchVersions()
{
  if (m_fetchingVersions) {
    qDebug() << "fetchVersions already in progress";
    return;
  }

  QString url = ConfigManager::instance().djangoBaseUrl() + "/api/versions/";
  DEBUG_COLORED("DataManager", "fetchVersions", "Fetching versions from: " + url, COLOR_CYAN, COLOR_CYAN);

  m_fetchingVersions = true;

  m_networkService->getJsonFromDjango(
      QUrl(url),
      [this](const QJsonObject& json) {
        DEBUG_COLORED("DataManager", "fetchVersions", "Versions downloaded successfully", COLOR_CYAN,
                      COLOR_CYAN);

        QString filePath = m_fileService->getFullFilePath("versions.json");
        if (m_fileService->saveJsonToFile(filePath, json)) {
          DEBUG_COLORED("DataManager", "fetchVersions", "Saved versions to: " + filePath, COLOR_CYAN,
                        COLOR_CYAN);
        } else {
          DEBUG_ERROR_COLORED("DataManager", "fetchVersions", "Failed to save versions file", COLOR_CYAN,
                              COLOR_CYAN);
        }

        m_fetchingVersions = false;
        emit versionsFetched(true, "");
      },
      [this](const QString& error) {
        DEBUG_ERROR_COLORED("DataManager", "fetchVersions", "Download failed: " + error, COLOR_CYAN,
                            COLOR_CYAN);

        QString filePath = m_fileService->getFullFilePath("versions.json");
        QJsonObject localJson;

        m_fetchingVersions = false;
        emit versionsFetched(false, error);
      });
}

// datamanager.cpp
void DataManager::fetchSchemes()
{
  QString url = djangoBaseUrl() + "/api/schemes/all/";
  DEBUG_COLORED("DataManager", "fetchSchemes", "Fetching schemes from: " + url, COLOR_CYAN, COLOR_CYAN);

  m_networkService->getJsonFromDjango(
      QUrl(url),
      [this](const QJsonObject& json) {
        DEBUG_COLORED("DataManager", "fetchSchemes", "Schemes downloaded successfully", COLOR_CYAN,
                      COLOR_CYAN);

        // Ожидаем структуру: { "modelName": [ { "version": 1, ... }, ... ], ... }
        QJsonObject root = json;

        bool anySaved = false;
        for (auto it = root.begin(); it != root.end(); ++it) {
          QString modelName = it.key();
          QJsonValue schemesVal = it.value();
          if (!schemesVal.isArray()) continue;

          QJsonArray schemes = schemesVal.toArray();
          if (schemes.isEmpty()) continue;

          QString modelDir = m_fileService->getAppDataPath() + "/" + modelName;
          QDir dir(modelDir);
          if (!dir.exists()) {
            if (!dir.mkpath(".")) {
              DEBUG_ERROR_COLORED("DataManager", "fetchSchemes", "Failed to create directory: " + modelDir,
                                  COLOR_CYAN, COLOR_CYAN);
              continue;
            }
          }

          for (const QJsonValue& schemeVal : schemes) {
            if (!schemeVal.isObject()) continue;
            QJsonObject schemeObj = schemeVal.toObject();

            int version = schemeObj.value("version").toInt(-1);

            if (version < 1) {
              DEBUG_ERROR_COLORED("DataManager", "fetchSchemes", "Scheme without valid version, skipped",
                                  COLOR_CYAN, COLOR_CYAN);
              continue;
            }

            QString fileName = "v" + QString::number(version) + ".json";
            QString fullPath = modelDir + "/" + fileName;

            if (m_fileService->saveJsonToFile(fullPath, schemeObj)) {
              anySaved = true;
              DEBUG_COLORED("DataManager", "fetchSchemes", "Saved scheme: " + fullPath, COLOR_CYAN,
                            COLOR_CYAN);
            } else {
              DEBUG_ERROR_COLORED("DataManager", "fetchSchemes", "Failed to save scheme: " + fullPath,
                                  COLOR_CYAN, COLOR_CYAN);
            }
          }
        }

        emit schemesFetched(anySaved, anySaved ? "" : "No schemes were saved");
      },
      [this](const QString& error) {
        DEBUG_ERROR_COLORED("DataManager", "fetchSchemes", "Download failed: " + error, COLOR_CYAN,
                            COLOR_CYAN);
        emit schemesFetched(false, error);
      });
}

void DataManager::uploadSettingsToDjango(const QUrl& apiUrl)
{
  DEBUG_COLORED("DataManager", "uploadSettingsToDjango",
                QString("Uploading settings to %1").arg(apiUrl.toString()), COLOR_CYAN, COLOR_CYAN);

  if (isValidApiUrl(apiUrl)) {
    setError("Invalid API URL: must include http:// or https://");
    emit settingsUploadFinished(false);
    return;
  }

  if (!m_settingsManager) {
    setError("SettingsManager не инициализирован");
    emit settingsUploadFinished(false);
    return;
  }

  QJsonObject json = m_settingsManager->toJsonForDjango();
  if (json.isEmpty()) {
    setError("Failed to load JSON settings.");
    emit settingsUploadFinished(false);
    return;
  }

  setLoading(true);

  connect(m_networkService.get(), &NetworkService::uploadFinished, this, [this]() {
    setLoading(false);
    emit settingsUploadFinished(true);
  });
  connect(m_networkService.get(), &NetworkService::errorOccurred, this, [this](const QString& err) {
    setLoading(false);
    setError(err);
    emit settingsUploadFinished(false);
  });

  m_networkService->uploadJsonToDjango(apiUrl, json);
}


void DataManager::syncSettingsWithServer()
{
  DEBUG_COLORED("DataManager", "syncSettingsWithServer", "Starting settings sync", COLOR_CYAN, COLOR_CYAN);

  QString serialNumber = m_settingsManager->serialNumber();
  if (serialNumber.isEmpty()) {
    DEBUG_ERROR_COLORED("DataManager", "syncSettingsWithServer",
                        "Serial number is empty, cannot sync settings", COLOR_CYAN, COLOR_CYAN);
    setError("Serial number is not available");
    return;
  }

  QString model = m_settingsManager->currentModel();
  if (model.isEmpty()) {
    DEBUG_ERROR_COLORED("DataManager", "syncSettingsWithServer", "Model is not specified", COLOR_CYAN,
                        COLOR_CYAN);
    setError("Model is not specified");
    return;
  }

  QUrl apiUrl(QString(djangoBaseUrl() + "/api/" + model + "/%1/get_settings").arg(serialNumber));

  DEBUG_COLORED("DataManager", "syncSettingsWithServer",
                QString("Downloading settings from: %1").arg(apiUrl.toString()), COLOR_CYAN, COLOR_CYAN);

  if (isValidApiUrl(apiUrl)) {
    setError("Invalid API URL for settings sync");
    return;
  }

  setLoading(true);
  setError("");

  m_networkService->getJsonFromDjango(
      apiUrl,
      [this](const QJsonObject& json) {
        if (json.isEmpty()) {
          setError("Received empty settings JSON from server");
          setLoading(false);
          return;
        }

        // Extract settings object from response
        QJsonObject settingsObj = json;
        if (json.contains("settings") && json["settings"].isObject()) {
          settingsObj = json["settings"].toObject();
        }

        // Apply settings to SettingsManager
        m_settingsManager->fromJson(settingsObj);

        DEBUG_COLORED("DataManager", "syncSettingsWithServer",
                      "Settings successfully synchronized from server", COLOR_CYAN, COLOR_CYAN);

        setLoading(false);
        emit settingsSyncFinished(true);
      },
      [this](const QString& error) {
        DEBUG_ERROR_COLORED("DataManager", "syncSettingsWithServer",
                            QString("Failed to sync settings: %1").arg(error), COLOR_CYAN, COLOR_CYAN);
        setError(QString("Settings sync failed: %1").arg(error));
        setLoading(false);
        emit settingsSyncFinished(false);
      });
}


void DataManager::setLoading(bool loading)
{
  if (m_loading != loading) {
    m_loading = loading;
    emit loadingChanged();
  }
}

void DataManager::setError(const QString& error)
{
  m_error = error;
  emit errorOccurred(error);
}
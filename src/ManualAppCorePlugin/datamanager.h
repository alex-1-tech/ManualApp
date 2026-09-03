#pragma once

#include <qcontainerfwd.h>
#include <qtmetamacros.h>

#include <QCoreApplication>
#include <QObject>
#include <QQmlEngine>
#include <QQueue>
#include <memory>

#include "file/configmanager.h"
#include "file/fileservice.h"
#include "networkservice.h"
#include "settings/settingsmanager.h"
#include "software/licensehandler.h"

class NetworkService;
class FileService;
class InstallManager;

class DataManager : public QObject
{
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

  // Property declarations
  Q_PROPERTY(bool isLoading READ isLoading NOTIFY loadingChanged)
  Q_PROPERTY(bool loading READ isLoading NOTIFY loadingChanged)
  Q_PROPERTY(QString error READ error NOTIFY errorOccurred)
  Q_PROPERTY(SettingsManager* settingsManager READ settingsManager WRITE setSettingsManager NOTIFY
                 settingsManagerChanged)

public:
  // Construction/Destruction
  explicit DataManager(QObject* parent = nullptr);
  ~DataManager() override;
  void shutdown();

  Q_INVOKABLE void syncSettingsWithServer();

  // Q_INVOKABLE methods - Settings Operations
  Q_INVOKABLE QString createSettingsJsonFile(const QString& filePath);
  Q_INVOKABLE bool deleteSettingsJsonFile(const QString& filePath);
  Q_INVOKABLE void uploadSettingsToDjango(const QUrl& apiUrl);
  Q_INVOKABLE void setCurrentSettings(const QUrl& apiUrl);
  Q_INVOKABLE void fetchVersions();
  Q_INVOKABLE void fetchSchemes();

  // Q_INVOKABLE methods - Config Operations
  Q_INVOKABLE QString djangoBaseUrl() const { return ConfigManager::instance().djangoBaseUrl(); };
  Q_INVOKABLE QString appVersion() const { return ConfigManager::instance().appVersion(); };

  // Property getters
  bool isLoading() const { return m_loading; }
  QString error() const { return m_error; }
  Q_INVOKABLE FileService* fileService() const { return m_fileService.get(); }
  Q_INVOKABLE NetworkService* networkService() const { return m_networkService.get(); }
  Q_INVOKABLE LicenseHandler* licenseHandler() const { return m_licenseHandler.get(); };
  Q_INVOKABLE SettingsManager* settingsManager() const { return m_settingsManager; }
  Q_INVOKABLE void setSettingsManager(SettingsManager* manager);
  bool isValidApiUrl(const QUrl& apiUrl);

  // Dir getters
  Q_INVOKABLE QString applicationDirPath() { return QCoreApplication::applicationDirPath(); }
signals:

  // Property change signals
  void settingsManagerChanged();
  void loadingChanged();
  void errorOccurred(const QString& error);
  void settingsSyncFinished(bool success);
  void settingsUploadFinished(bool success);
  void versionsFetched(bool success, const QString& error = QString());
  void schemesFetched(bool success, const QString& error = QString());

private:
  // Private setters
  void setLoading(bool loading);
  void setError(const QString& error);


private:
  // State management
  bool m_loading = false;
  bool m_fetchingVersions = false;
  QString m_error;

  // Core components
  std::unique_ptr<LicenseHandler> m_licenseHandler;
  std::unique_ptr<NetworkService> m_networkService;
  std::unique_ptr<FileService> m_fileService;
  SettingsManager* m_settingsManager = nullptr;
};
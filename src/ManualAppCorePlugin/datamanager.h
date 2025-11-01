#pragma once

#include "configmanager.h"
#include "reportmanager.h"
#include "stepmodel.h"
#include <QObject>
#include <QQmlEngine>
#include <QQueue>
#include <qcontainerfwd.h>
#include <qtmetamacros.h>

class NetworkService;
class FileService;

class DataManager : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

  // Property declarations
  Q_PROPERTY(QString title READ title NOTIFY titleChanged)
  Q_PROPERTY(bool isLoading READ isLoading NOTIFY loadingChanged)
  Q_PROPERTY(QString error READ error NOTIFY errorOccurred)
  Q_PROPERTY(StepModel *stepsModel READ stepsModel CONSTANT)
  Q_PROPERTY(SettingsManager *settingsManager READ settingsManager WRITE
                 setSettingsManager NOTIFY settingsManagerChanged)
  Q_PROPERTY(QString startTime READ startTime WRITE setStartTime NOTIFY
                 startTimeChanged)
  Q_PROPERTY(ReportManager *reportManager READ reportManager CONSTANT)

public:
  // Construction/Destruction
  explicit DataManager(QObject *parent = nullptr);
  ~DataManager() = default;

  // Q_INVOKABLE methods - File Operations
  Q_INVOKABLE bool load(const QString &filePath);
  Q_INVOKABLE void saveJson(const QString &path);
  Q_INVOKABLE void exportPdf(const QString &path);
  Q_INVOKABLE void save(bool first_save);
  Q_INVOKABLE void revoke();

  // Q_INVOKABLE methods - Report Operations
  Q_INVOKABLE bool uploadReport(const QString &sourceFolderPath, bool after);
  Q_INVOKABLE void uploadReportToDjango(const QUrl &apiUrl);
  Q_INVOKABLE void syncReportsWithServer();

  // Q_INVOKABLE methods - Settings Operations
  Q_INVOKABLE QString createSettingsJsonFile(const QString &filePath);
  Q_INVOKABLE bool deleteSettingsJsonFile(const QString &filePath);
  Q_INVOKABLE void uploadSettingsToDjango(const QUrl &apiUrl);
  Q_INVOKABLE void setCurrentSettings(const QUrl &apiUrl);

  // Q_INVOKABLE methods - Step Management
  Q_INVOKABLE void setStepStatus(int index, Step::CompletionStatus status);
  Q_INVOKABLE void setDefectDetails(int index, const QString &description,
                                    const QString &repairMethod,
                                    Step::DefectDetails::FixStatus fixStatus);
  // Q_INVOKABLE methods - Config Operations
  Q_INVOKABLE QString djangoBaseUrl() const {
    return ConfigManager::instance().djangoBaseUrl();
  };
  Q_INVOKABLE QString appVersion() const {
    return ConfigManager::instance().appVersion();
  };
  // Q_INVOKABLE methods - TO Operations
  Q_INVOKABLE void setCurrentNumberTO(const QString &numberTO);
  Q_INVOKABLE QString currentNumberTO();
  Q_INVOKABLE QVariantMap performedTOs() const {
    return m_reportManager->performedTOs();
  };
  Q_INVOKABLE QVariantMap performedTOsNew() const {
    return m_reportManager->performedTOsNew();
  };
  Q_INVOKABLE QString findReportPdf(const QString &categoryKey,
                                    const QString &dateIso) const {
    return m_reportManager->findReportPdf(categoryKey, dateIso);
  };
  // Q_INVOKABLE methods - Utility
  Q_INVOKABLE QStringList getFixStatusOptions() const;
  Q_INVOKABLE bool createArchive(const QString &folderPath,
                                 const QString &mode);
  Q_INVOKABLE QString getReportDirPath() const;

  // Property getters
  QString title() const;
  bool isLoading() const { return m_loading; }
  QString error() const { return m_error; }
  SettingsManager *settingsManager() const;
  StepModel *stepsModel();
  QString startTime() const;
  ReportManager *reportManager() { return m_reportManager; }
  FileService *fileService() const { return m_reportManager->fileService(); }
  NetworkService *networkService() const {
    return m_reportManager->networkService();
  }

  // Property setters
  Q_INVOKABLE void setStartTime(const QString &time);
  Q_INVOKABLE void setSettingsManager(SettingsManager *manager);

  // Internal upload management
  void startNextUpload();
  void startNextUpload(const QUrl &apiUrl);
  void handleSingleReportUploadFinished(bool success, const QString &error);
  void processServerReports(const QJsonObject &serverReports,
                            const QString &serialNumber);

signals:
  // Property change signals
  void titleChanged();
  void settingsManagerChanged();
  void loadingChanged();
  void errorOccurred(const QString &error);
  void startTimeChanged();

  // Operation signals
  void dataLoaded();
  void stepUpdated(int index);
  void allReportsUploaded();

private:
  // Private setters
  void setLoading(bool loading);
  void setError(const QString &error);

private:
  // State management
  bool m_loading = false;
  QString m_error;
  bool m_isUploading = false;

  // Core components
  ReportManager *m_reportManager;

  // Upload queue management
  QQueue<QList<QString>> m_pendingReports;

  // Constants
  QStringList numbersTO = {"TO-1", "TO-2", "TO-3"};
};
#pragma once

#include "settingsmanager.h"
#include "stepmodel.h"
#include <QObject>
#include <QVariant>
#include <qtmetamacros.h>

class NetworkService;
class FileService;
class PdfExporter;

class ReportManager : public QObject {
  Q_OBJECT

  // Property declarations
  Q_PROPERTY(QString title READ title NOTIFY titleChanged)
  Q_PROPERTY(QString startTime READ startTime WRITE setStartTime NOTIFY
                 startTimeChanged)
  Q_PROPERTY(SettingsManager *settingsManager READ settingsManager WRITE
                 setSettingsManager NOTIFY settingsManagerChanged)

public:
  // Construction/Destruction
  explicit ReportManager(FileService *fileService,
                         NetworkService *networkService,
                         QObject *parent = nullptr);
  ~ReportManager() = default;

  // Q_INVOKABLE methods - Report Operations
  Q_INVOKABLE bool loadReport(const QString &filePath);
  Q_INVOKABLE void saveReportJson(const QString &path);
  Q_INVOKABLE void exportReportToPdf(const QString &path);
  Q_INVOKABLE void saveReport(bool firstSave);
  Q_INVOKABLE void revokeReport();
  Q_INVOKABLE bool uploadReport(const QString &sourceFolderPath, bool after);
  Q_INVOKABLE bool createArchive(const QString &folderPath,
                                 const QString &mode);

  // Q_INVOKABLE methods - Utility
  Q_INVOKABLE QVariantMap performedTOs() const;
  Q_INVOKABLE QVariantMap performedTOsNew() const;
  Q_INVOKABLE QString getReportDirPath() const;
  Q_INVOKABLE QString findReportPdf(const QString &categoryKey,
                                    const QString &dateIso) const;
  // Property getters
  QString title() const { return m_title; }
  QString startTime() const { return m_startTime; }
  QString currentNumberTO() const { return m_numberTO; }
  SettingsManager *settingsManager() const { return m_settingsManager; };
  StepModel *stepsModel() { return &m_model; }
  FileService *fileService() const { return m_fileService; }
  NetworkService *networkService() const { return m_networkService; }

  // Property setters
  void setStartTime(const QString &time);
  void setCurrentNumberTO(const QString &numberTO);
  void setSettingsManager(SettingsManager *manager);

signals:
  // Property change signals
  void titleChanged();
  void startTimeChanged();
  void numberTOChanged();
  void settingsManagerChanged();

  // Operation signals
  void reportLoaded();
  void errorOccurred(const QString &error);

private:
  // Private helper methods
  qint64 getDirSize(const QString &path);
  bool removeDir(const QString &dirPath);
  void setError(const QString &error);

private:
  // Core data members
  QString m_title;
  QString m_startTime;
  QString m_numberTO;
  StepModel m_model;

  // Service dependencies
  SettingsManager *m_settingsManager = nullptr;
  FileService *m_fileService;
  NetworkService *m_networkService;
};
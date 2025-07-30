#pragma once
#include "settingsmanager.h"
#include "stepmodel.h"
#include <QObject>

class DataManager : public QObject {
  Q_OBJECT
  Q_PROPERTY(QString title READ title NOTIFY titleChanged)
  Q_PROPERTY(bool isLoading READ isLoading NOTIFY loadingChanged)
  Q_PROPERTY(QString error READ error NOTIFY errorOccurred)
  Q_PROPERTY(StepModel *stepsModel READ stepsModel CONSTANT)
  Q_PROPERTY(SettingsManager *settingsManager READ settingsManager WRITE
                 setSettingsManager NOTIFY settingsManagerChanged)
  Q_PROPERTY(QString startTime READ startTime WRITE setStartTime NOTIFY
                 startTimeChanged)
public:
  explicit DataManager(QObject *parent = nullptr);
  ~DataManager() {}

  Q_INVOKABLE bool load(const QString &filePath);
  Q_INVOKABLE void saveJson(const QString &path);
  Q_INVOKABLE void exportPdf(const QString &path);
  Q_INVOKABLE void save(const bool first_save);
  Q_INVOKABLE void revoke();
  Q_INVOKABLE bool uploadReport(const QString &sourceFolderPath, bool after);

  Q_INVOKABLE void setStepStatus(int index, Step::CompletionStatus status);
  Q_INVOKABLE void setDefectDetails(int index, const QString &description,
                                    const QString &repairMethod,
                                    Step::DefectDetails::FixStatus fixStatus);

  Q_INVOKABLE QStringList getFixStatusOptions() const;

  QString title() const { return m_title; }
  bool isLoading() const { return m_loading; }
  QString error() const { return m_error; }
  StepModel *stepsModel() { return &m_model; }
  SettingsManager *settingsManager() const;
  void setSettingsManager(SettingsManager *manager);
  Q_INVOKABLE QString startTime() const { return m_startTime; }
  Q_INVOKABLE void setStartTime(const QString &time) {
    if (m_startTime != time) {
      m_startTime = time;
      emit startTimeChanged();
    }
  }

signals:
  void titleChanged();
  void settingsManagerChanged();
  void loadingChanged();
  void errorOccurred(const QString &error);
  void dataLoaded();
  void stepUpdated(int index);
  void startTimeChanged();

private:
  void setLoading(bool loading) {
    if (m_loading != loading) {
      m_loading = loading;
      emit loadingChanged();
    }
  }

  void setError(const QString &error) {
    m_error = error;
    emit errorOccurred(error);
  }

  SettingsManager *m_settingsManager = nullptr;
  QString m_title;
  bool m_loading = false;
  QString m_error;
  StepModel m_model;
  QString m_startTime;
};
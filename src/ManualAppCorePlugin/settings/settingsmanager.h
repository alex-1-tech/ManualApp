#pragma once

#include <qtmetamacros.h>

#include <QDate>
#include <QJsonObject>
#include <QMap>
#include <QObject>
#include <QQmlEngine>
#include <QSettings>

#include "modelsettings.h"


#define DEFINE_SETTING(Type, Name, Default)                                                                  \
  Q_PROPERTY(Type Name READ Name WRITE set##Name NOTIFY Name##Changed)                                       \
public:                                                                                                      \
  [[nodiscard]] Type Name() const                                                                            \
  {                                                                                                          \
    return m_settings.value(#Name, Default).value<Type>();                                                   \
  }                                                                                                          \
  void set##Name(const Type& value)                                                                          \
  {                                                                                                          \
    if (value != Name()) {                                                                                   \
      m_settings.setValue(#Name, value);                                                                     \
      emit Name##Changed();                                                                                  \
    }                                                                                                        \
  }                                                                                                          \
  Q_SIGNAL void Name##Changed();

#define DEFINE_DATE_SETTING(Name)                                                                            \
  Q_PROPERTY(QDate Name READ Name WRITE set##Name NOTIFY Name##Changed)                                      \
public:                                                                                                      \
  [[nodiscard]] QDate Name() const                                                                           \
  {                                                                                                          \
    return QDate::fromString(m_settings.value(#Name).toString(), Qt::ISODate);                               \
  }                                                                                                          \
  void set##Name(const QDate& value)                                                                         \
  {                                                                                                          \
    if (value != Name()) {                                                                                   \
      m_settings.setValue(#Name, value.toString(Qt::ISODate));                                               \
      emit Name##Changed();                                                                                  \
    }                                                                                                        \
  }                                                                                                          \
  Q_SIGNAL void Name##Changed();

class SettingsManager : public QObject
{
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

  Q_PROPERTY(QStringList availableModels READ availableModels NOTIFY modelsChanged)

  // Common properties for all models
  DEFINE_SETTING(QString, serialNumber, QString())

  DEFINE_SETTING(QString, currentModel, QString("kalmar32"))
  DEFINE_DATE_SETTING(lastUpdateManualAppDate)
  DEFINE_DATE_SETTING(lastUpdateSoftwareDate)
  DEFINE_SETTING(QString, deviceHWID, QString())
  DEFINE_SETTING(QString, hostHWID, QString())
  DEFINE_SETTING(QString, railType, QString())
  DEFINE_SETTING(bool, isFirstRun, true)

public:
  explicit SettingsManager(QObject* parent = nullptr);
  ~SettingsManager();

  Q_INVOKABLE ModelSettings* getModelSettings(const QString& modelName = QString()) const;
  Q_INVOKABLE QStringList availableModels() const { return m_models.keys(); }

  Q_INVOKABLE ModelSettings* getSettings(const QString& name) const { return getModelSettings(name); }
  Q_INVOKABLE ModelSettings* getCurrentSettings() const { return getModelSettings(currentModel()); }

  Q_INVOKABLE void completeFirstRun();

  Q_INVOKABLE void saveModelSettings();
  Q_INVOKABLE void debugPrint() const;
  Q_INVOKABLE void saveAllSettings();
  Q_INVOKABLE void loadAllSettings();

  Q_INVOKABLE void updateLastManualAppDate() { setlastUpdateManualAppDate(QDate::currentDate()); }
  Q_INVOKABLE void updateLastSoftwareDate() { setlastUpdateSoftwareDate(QDate::currentDate()); }
  Q_INVOKABLE void saveDateIso(const QString& key, const QString& dateStr);

  [[nodiscard]] QJsonObject toJsonForDjango() const;
  QJsonObject readJsonFile(const QString& filePath);
  void fromJson(const QJsonObject& obj);

signals:
  void modelsChanged();
  void modelSettingsChanged(const QString& modelName);

private:
  void initializeModels();

private:
  QSettings m_settings;
  QMap<QString, ModelSettings*> m_models;
  QString m_configPath;
};
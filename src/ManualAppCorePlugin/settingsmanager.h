#pragma once
#include <QDate>
#include <QJsonObject>
#include <QObject>
#include <QQmlEngine>
#include <QSettings>

#include "kalmar32settings.h"
#include "phasar32settings.h"


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

  Q_PROPERTY(Kalmar32Settings* kalmarSettings READ kalmarSettings CONSTANT)
  Q_PROPERTY(Phasar32Settings* phasarSettings READ phasarSettings CONSTANT)

  // Common properties for all models
  DEFINE_SETTING(QString, serialNumber, QString())
  DEFINE_DATE_SETTING(shipmentDate)
  DEFINE_SETTING(QString, invoice, QString())
  DEFINE_SETTING(QString, packetList, QString())
  DEFINE_SETTING(QString, currentModel, QString("kalmar32"))
  DEFINE_SETTING(QString, wifiRouterAddress, QString())
  DEFINE_SETTING(QString, windowsPassword, QString())
  DEFINE_SETTING(QString, notes, QString())

  DEFINE_SETTING(QString, deviceHWID, QString())
  DEFINE_SETTING(QString, hostHWID, QString())
  DEFINE_SETTING(bool, isFirstRun, true)

public:
  explicit SettingsManager(QObject* parent = nullptr);
  ~SettingsManager();

  Kalmar32Settings* kalmarSettings() const { return m_kalmarSettings; }
  Phasar32Settings* phasarSettings() const { return m_phasarSettings; }

  Q_INVOKABLE void completeFirstRun();
  Q_INVOKABLE bool isKalmar32() const { return currentModel() == "kalmar32"; }
  Q_INVOKABLE bool isPhasar32() const { return currentModel() == "phasar32"; }

  Q_INVOKABLE void saveModelSettings();
  Q_INVOKABLE void debugPrint() const;
  Q_INVOKABLE void saveAllSettings();
  Q_INVOKABLE void loadAllSettings();

  Q_INVOKABLE bool hasLicense();
  Q_INVOKABLE QJsonObject license();
  Q_INVOKABLE void saveLicense(const QJsonObject& license);
  Q_INVOKABLE void clearLicense();


  [[nodiscard]] QJsonObject toJsonForDjango() const;
  void fromJson(const QJsonObject& obj);

private:
  QSettings m_settings;
  Kalmar32Settings* m_kalmarSettings;
  Phasar32Settings* m_phasarSettings;
};

#pragma once
#include <QDate>
#include <QJsonObject>
#include <QObject>
#include <QQmlEngine>
#include <QSettings>

#define DEFINE_SETTING(Type, Name, Default)                                    \
  Q_PROPERTY(Type Name READ Name WRITE set##Name NOTIFY Name##Changed)         \
public:                                                                        \
  [[nodiscard]] Type Name() const {                                            \
    return m_settings.value(#Name, Default).value<Type>();                     \
  }                                                                            \
  void set##Name(const Type &value) {                                          \
    if (value != Name()) {                                                     \
      m_settings.setValue(#Name, value);                                       \
      emit Name##Changed();                                                    \
    }                                                                          \
  }                                                                            \
  Q_SIGNAL void Name##Changed();

#define DEFINE_DATE_SETTING(Name)                                              \
  Q_PROPERTY(QDate Name READ Name WRITE set##Name NOTIFY Name##Changed)        \
public:                                                                        \
  [[nodiscard]] QDate Name() const {                                           \
    return QDate::fromString(m_settings.value(#Name).toString(), Qt::ISODate); \
  }                                                                            \
  void set##Name(const QDate &value) {                                         \
    if (value != Name()) {                                                     \
      m_settings.setValue(#Name, value.toString(Qt::ISODate));                 \
      emit Name##Changed();                                                    \
    }                                                                          \
  }                                                                            \
  Q_SIGNAL void Name##Changed();

class SettingsManager : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

  // Registration data
  DEFINE_SETTING(QString, serialNumber, QString())
  DEFINE_DATE_SETTING(shipmentDate)
  DEFINE_SETTING(QString, caseNumber, QString())

  // PC tablet Latitude Dell 7230
  DEFINE_SETTING(QString, pcTabletDell7230, QString())
  DEFINE_SETTING(QString, softwareInstallerPath, QString())
  DEFINE_SETTING(QString, acDcPowerAdapterDell, QString())
  DEFINE_SETTING(QString, dcChargerAdapterBattery, QString())

  // Ultrasonic equipment
  DEFINE_SETTING(QString, ultrasonicPhasedArrayPulsar, QString())
  DEFINE_SETTING(QString, manualProbs36, QString())
  DEFINE_SETTING(QString, straightProbs0, QString())

  // Cables and accessories
  DEFINE_SETTING(bool, hasDcCableBattery, false)
  DEFINE_SETTING(bool, hasEthernetCables, false)
  DEFINE_SETTING(QString, dcBatteryBox, QString())
  DEFINE_SETTING(QString, acDcChargerAdapterBattery, QString())

  // Calibration and tools
  DEFINE_SETTING(QString, calibrationBlockSo3r, QString())
  DEFINE_SETTING(bool, hasRepairToolBag, false)
  DEFINE_SETTING(bool, hasInstalledNameplate, false)

  // Дополнительные поля
  DEFINE_SETTING(QString, notes, QString())

  // first run
  DEFINE_SETTING(bool, isFirstRun, true);

public:
  explicit SettingsManager(QObject *parent = nullptr);
  ~SettingsManager() = default;

  Q_INVOKABLE void completeFirstRun();

  void debugPrint() const;
  void saveAllSettings();
  Q_INVOKABLE void loadAllSettings();
  [[nodiscard]] QJsonObject toJsonForDjango() const;
  void fromJson(const QJsonObject &obj);

private:
  QSettings m_settings;
};
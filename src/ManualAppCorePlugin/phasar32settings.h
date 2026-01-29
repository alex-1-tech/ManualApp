#pragma once
#include <QQmlEngine>

#include "settingsbase.h"


#define DEFINE_MODULE_SETTING(Type, Name, Default)                                                           \
  Q_PROPERTY(Type Name READ Name WRITE set##Name NOTIFY Name##Changed)                                       \
public:                                                                                                      \
  [[nodiscard]] Type Name() const                                                                            \
  {                                                                                                          \
    return m_##Name;                                                                                         \
  }                                                                                                          \
  void set##Name(const Type& value)                                                                          \
  {                                                                                                          \
    if (value != m_##Name) {                                                                                 \
      m_##Name = value;                                                                                      \
      emit Name##Changed();                                                                                  \
    }                                                                                                        \
  }                                                                                                          \
  Q_SIGNAL void Name##Changed();                                                                             \
                                                                                                             \
private:                                                                                                     \
  Type m_##Name = Default;

class Phasar32Settings : public SettingsBase
{
  Q_OBJECT
  QML_ELEMENT

  // PC tablet components
  DEFINE_MODULE_SETTING(QString, pcTabletDell7230, QString())
  DEFINE_MODULE_SETTING(QString, acDcPowerAdapterDell, QString())
  DEFINE_MODULE_SETTING(QString, dcChargerAdapterBattery, QString())

  // Ultrasonic equipment
  DEFINE_MODULE_SETTING(QString, ultrasonicPhasedArrayPulsar, QString())
  // Ultrasonic blocks with dates
  DEFINE_MODULE_SETTING(QString, dcn, QString())
  DEFINE_MODULE_SETTING(QString, abBack, QString())
  DEFINE_MODULE_SETTING(QString, gfCombo, QString())
  DEFINE_MODULE_SETTING(QString, ffCombo, QString())
  DEFINE_MODULE_SETTING(QString, abFront, QString())
  DEFINE_MODULE_SETTING(QString, flange50, QString())
  DEFINE_MODULE_SETTING(QString, manualProbs, QString())

  DEFINE_MODULE_SETTING(bool, hasDcCableBattery, false)
  DEFINE_MODULE_SETTING(bool, hasEthernetCables, false)

  // Additional equipment
  DEFINE_MODULE_SETTING(QString, waterTankWithTap, QString())
  DEFINE_MODULE_SETTING(QString, dcBatteryBox, QString())
  DEFINE_MODULE_SETTING(bool, hasAcDcChargerAdapterBattery, false)

  // Calibration and tools
  DEFINE_MODULE_SETTING(QString, calibrationBlockSo3r, QString())
  DEFINE_MODULE_SETTING(bool, hasRepairToolBag, false)
  DEFINE_MODULE_SETTING(bool, hasInstalledNameplate, false)

public:
  explicit Phasar32Settings(QObject* parent = nullptr);

  void loadFromSettings(QSettings& settings, const QString& prefix = "") override;
  void saveToSettings(QSettings& settings, const QString& prefix = "") const override;
  QJsonObject toJson() const override;
  void fromJson(const QJsonObject& obj) override;
  void debugPrint() const override;
};
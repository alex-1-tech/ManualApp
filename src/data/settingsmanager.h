#pragma once
#include <QDate>
#include <QJsonObject>
#include <QObject>
#include <QSettings>

#define DEFINE_SETTING(Type, Name, Default)                                    \
  Q_PROPERTY(Type Name READ Name WRITE set##Name NOTIFY Name##Changed)         \
public:                                                                        \
  Type Name() const { return m_settings.value(#Name, Default).value<Type>(); } \
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
  QDate Name() const {                                                         \
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
  // Registration data
  DEFINE_SETTING(QString, serialNumber, QString())
  DEFINE_DATE_SETTING(shipmentDate)
  DEFINE_SETTING(QString, caseNumber, QString())

  // Main components
  DEFINE_SETTING(QString, firstPhasedArrayConverters, QString())
  DEFINE_SETTING(QString, secondPhasedArrayConverters, QString())
  DEFINE_SETTING(QString, batteryCase, QString())

  // Blocks and modules
  DEFINE_SETTING(QString, aosBlock, QString())
  DEFINE_SETTING(QString, flashDrive, QString())
  DEFINE_SETTING(QString, coThreeRMeasureChanged, QString())

  // Certification and checks
  DEFINE_SETTING(QString, calibrationCertificate, QString())
  DEFINE_DATE_SETTING(calibrationDate)

  // Spare parts kit
  DEFINE_SETTING(bool, hasTabletScrews, false)
  DEFINE_SETTING(bool, hasEthernetCable, false)
  DEFINE_SETTING(QString, batteryCharger, QString())
  DEFINE_SETTING(QString, tabletCharger, QString())
  DEFINE_SETTING(bool, hasToolKit, false)

  // Inspection and documentation
  DEFINE_SETTING(QString, softwareCheck, QString())
  DEFINE_SETTING(QString, photoVideoUrl, QString())
  DEFINE_SETTING(double, weight, 0.0)
  DEFINE_SETTING(QString, notes, QString())

  // Additional components
  DEFINE_SETTING(QString, manualInclined, QString())
  DEFINE_SETTING(QString, straight, QString())
  DEFINE_SETTING(QString, photoUrl, QString())

public:
  explicit SettingsManager(QObject *parent = nullptr);
  ~SettingsManager() = default;

  void debugPrint() const;
  void saveAllSettings();
  void loadAllSettings();
  QJsonObject toJson() const;
  void fromJson(const QJsonObject &obj);

private:
  QSettings m_settings;
};
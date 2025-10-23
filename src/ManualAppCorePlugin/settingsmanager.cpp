#include "settingsmanager.h"
#include "utils.h"
#include <QDebug>
#include <QMetaProperty>
#include <QJsonObject>
#include <QJsonValue>

namespace {

const QHash<QString, QString> &specialCamelToSnake() {
  static const QHash<QString, QString> map = {
      // Регистрационные данные
      {QStringLiteral("serialNumber"), QStringLiteral("serial_number")},
      {QStringLiteral("shipmentDate"), QStringLiteral("shipment_date")},
      {QStringLiteral("caseNumber"), QStringLiteral("case_number")},

      // PC tablet компоненты
      {QStringLiteral("pcTabletDell7230"),
       QStringLiteral("pc_tablet_dell_7230")},
      {QStringLiteral("acDcPowerAdapterDell"),
       QStringLiteral("ac_dc_power_adapter_dell")},
      {QStringLiteral("dcChargerAdapterBattery"),
       QStringLiteral("dc_charger_adapter_battery")},

      // Ультразвуковое оборудование
      {QStringLiteral("ultrasonicPhasedArrayPulsar"),
       QStringLiteral("ultrasonic_phased_array_pulsar")},
      {QStringLiteral("manualProbs36"), QStringLiteral("manual_probs_36")},
      {QStringLiteral("straightProbs0"), QStringLiteral("straight_probs_0")},

      // Кабели и аксессуары
      {QStringLiteral("hasDcCableBattery"),
       QStringLiteral("has_dc_cable_battery")},
      {QStringLiteral("hasEthernetCables"),
       QStringLiteral("has_ethernet_cables")},
      {QStringLiteral("dcBatteryBox"), QStringLiteral("dc_battery_box")},
      {QStringLiteral("acDcChargerAdapterBattery"),
       QStringLiteral("ac_dc_charger_adapter_battery")},

      // Калибровка и инструменты
      {QStringLiteral("calibrationBlockSo3r"),
       QStringLiteral("calibration_block_so_3r")},
      {QStringLiteral("hasRepairToolBag"),
       QStringLiteral("has_repair_tool_bag")},
      {QStringLiteral("hasInstalledNameplate"),
       QStringLiteral("has_installed_nameplate")},

      // Дополнительные поля
      {QStringLiteral("notes"), QStringLiteral("notes")}
  };
  return map;
}

const QHash<QString, QString> &specialSnakeToCamel() {
  static QHash<QString, QString> rev;
  if (rev.isEmpty()) {
    const QHash<QString, QString> &fwd = specialCamelToSnake();
    for (auto it = fwd.constBegin(); it != fwd.constEnd(); ++it) {
      rev.insert(it.value(), it.key());
    }
  }
  return rev;
}

bool stringToBool(const QString &s) {
  QString t = s.trimmed().toLower();
  return (t == QLatin1String("true") || t == QLatin1String("1") ||
          t == QLatin1String("yes") || t == QLatin1String("да") ||
          t == QLatin1String("y"));
}

} // namespace

SettingsManager::SettingsManager(QObject *parent)
    : QObject(parent), m_settings("votum", "ManualApp") {
  loadAllSettings();
  // m_settings.clear();
}

void SettingsManager::completeFirstRun() {
  DEBUG_COLORED("SettingsManager", "completeFirstRun", "first init settings",
                COLOR_MAGENTA, COLOR_MAGENTA);
  m_settings.setValue("isFirstRun", false);
}

void SettingsManager::saveAllSettings() {
  const QMetaObject *meta = this->metaObject();
  for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
    QMetaProperty prop = meta->property(i);
    if (!prop.isReadable())
      continue;

    QVariant value = prop.read(this);

    // Сохраняем QDate как ISO-строку, остальные типы — как есть
    if (value.canConvert<QDate>()) {
      m_settings.setValue(prop.name(), value.toDate().toString(Qt::ISODate));
    } else {
      m_settings.setValue(prop.name(), value);
    }
  }
}

void SettingsManager::loadAllSettings() {
  const QMetaObject *meta = this->metaObject();
  for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
    QMetaProperty prop = meta->property(i);
    if (!prop.isWritable())
      continue;

    if (!m_settings.contains(prop.name()))
      continue;

    QVariant val = m_settings.value(prop.name());

    if (prop.userType() == QMetaType::QDate) {
      QDate date = QDate::fromString(val.toString(), Qt::ISODate);
      prop.write(this, date);
    } else {
      prop.write(this, val);
    }
  }
}

void SettingsManager::debugPrint() const {
  const QMetaObject *meta = this->metaObject();
  for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
    QMetaProperty prop = meta->property(i);
    QVariant value = prop.read(this);
    qDebug() << prop.name() << "=" << value;
  }
}

QJsonObject SettingsManager::toJsonForDjango() const {
  QJsonObject obj;
  const QMetaObject *meta = this->metaObject();
  const QHash<QString, QString> &special = specialCamelToSnake();

  for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
    QMetaProperty prop = meta->property(i);
    if (!prop.isReadable())
      continue;

    QVariant value = prop.read(this);
    const int type = value.userType();

    QString originalName = QString::fromLatin1(prop.name());
    QString outKey;
    if (special.contains(originalName)) {
      outKey = special.value(originalName);
    } else {
      continue;
    }

    if (type == QMetaType::QDate) {
      QDate date = value.toDate();
      if (date.isValid())
        obj[outKey] = date.toString(Qt::ISODate);
      else
        obj[outKey] = QString();
    } else {
      obj[outKey] = QJsonValue::fromVariant(value);
    }
  }

  return obj;
}

void SettingsManager::fromJson(const QJsonObject &obj) {
  const QMetaObject *meta = this->metaObject();
  const QHash<QString, QString> &specialRev = specialSnakeToCamel();

  for (auto it = obj.constBegin(); it != obj.constEnd(); ++it) {
    const QString key = it.key();
    const QJsonValue val = it.value();

    QString propName =
        specialRev.contains(key) ? specialRev.value(key) : key;

    if (propName.isEmpty()) {
      qDebug() << "SettingsManager::fromJson: empty propName for key" << key;
      continue;
    }

    int propIndex = meta->indexOfProperty(propName.toLatin1().constData());
    if (propIndex < 0) {
      qDebug() << "SettingsManager::fromJson: unknown property for key" << key
               << "=> tried" << propName;
      continue;
    }

    QMetaProperty prop = meta->property(propIndex);
    QString settingsKey = QString::fromLatin1(prop.name());
    QVariant writeVal;

    if (prop.userType() == QMetaType::QDate) {
      if (val.isString()) {
        QString s = val.toString().trimmed();
        if (s.isEmpty()) {
          writeVal = QString();
        } else {
          QDate d = QDate::fromString(s, Qt::ISODate);
          if (d.isValid())
            writeVal = d.toString(Qt::ISODate);
          else
            writeVal = s;
        }
      } else {
        writeVal = QString();
      }
    } else if (prop.userType() == QMetaType::Bool) {
      if (val.isBool())
        writeVal = val.toBool();
      else if (val.isString())
        writeVal = stringToBool(val.toString());
      else if (val.isDouble())
        writeVal = (val.toInt() != 0);
      else
        writeVal = false;
    } else if (prop.userType() == QMetaType::Double) {
      if (val.isDouble())
        writeVal = val.toDouble();
      else if (val.isString()) {
        QString s = val.toString().trimmed();
        s.replace(',', '.');
        writeVal = s.isEmpty() ? 0.0 : s.toDouble();
      } else if (val.isBool())
        writeVal = val.toBool() ? 1.0 : 0.0;
      else
        writeVal = QVariant();
    } else if (prop.userType() == QMetaType::Int) {
      if (val.isDouble())
        writeVal = val.toInt();
      else if (val.isString())
        writeVal = val.toString().toInt();
      else if (val.isBool())
        writeVal = val.toBool() ? 1 : 0;
      else
        writeVal = QVariant();
    } else {
      if (val.isNull() || val.isUndefined())
        writeVal = QString();
      else if (val.isString())
        writeVal = val.toString();
      else
        writeVal = val.toVariant();
    }

    if (writeVal.isValid()) {
      m_settings.setValue(settingsKey, writeVal);
    }
  }

  m_settings.sync();

  loadAllSettings();
}

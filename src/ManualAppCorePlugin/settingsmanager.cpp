#include "settingsmanager.h"
#include "utils.h"
#include <QDebug>
#include <QMetaProperty>

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
  for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
    QMetaProperty prop = meta->property(i);
    if (!prop.isReadable())
      continue;

    QVariant value = prop.read(this);
    const int type = value.userType();

    QString originalName = prop.name();
    QString snakeCaseName;

    for (int i = 0; i < originalName.length(); ++i) {
      QChar c = originalName.at(i);
      if (c.isUpper()) {
        snakeCaseName += '_' + c.toLower();
      } else {
        snakeCaseName += c;
      }
    }

    if (snakeCaseName == "co_three_r_measure")
      snakeCaseName = "co3r_measure";
    // Обработка QDate → строка (ISO 8601)
    if (type == QMetaType::QDate) {
      QDate date = value.toDate();
      if (date.isValid())
        obj[snakeCaseName] = date.toString(Qt::ISODate);
    } else {
      obj[snakeCaseName] = QJsonValue::fromVariant(value);
    }
  }

  return obj;
}

namespace {
QString snakeToCamel(const QString &snake) {
  if (snake.isEmpty())
    return QString();

  QStringList parts = snake.split('_', Qt::SkipEmptyParts);
  if (parts.isEmpty())
    return QString();

  QString camel = parts.first();
  for (int i = 1; i < parts.size(); ++i) {
    QString p = parts.at(i);
    if (p.isEmpty())
      continue;
    camel += p.left(1).toUpper() + p.mid(1);
  }
  return camel;
}

bool stringToBool(const QString &s) {
  QString t = s.trimmed().toLower();
  return (t == QLatin1String("true") || t == QLatin1String("1") ||
          t == QLatin1String("yes") || t == QLatin1String("да") ||
          t == QLatin1String("y"));
}
}

void SettingsManager::fromJson(const QJsonObject &obj) {
  const QMetaObject *meta = this->metaObject();

  static const QHash<QString, QString> specialMap = {
    {QStringLiteral("co3r_measure"), QStringLiteral("coThreeRMeasure")},
    {QStringLiteral("co_three_r_measure"), QStringLiteral("coThreeRMeasure")},
    {QStringLiteral("photo_url"), QStringLiteral("photoUrl")},
    {QStringLiteral("photo_video_url"), QStringLiteral("photoVideoUrl")},
    {QStringLiteral("flash_drive"), QStringLiteral("flashDrive")},
    {QStringLiteral("has_ethernet_cable"), QStringLiteral("hasEthernetCable")},
    {QStringLiteral("has_tablet_screws"), QStringLiteral("hasTabletScrews")},
    {QStringLiteral("battery_charger"), QStringLiteral("batteryCharger")},
    {QStringLiteral("tablet_charger"), QStringLiteral("tabletCharger")},
    {QStringLiteral("calibration_date"), QStringLiteral("calibrationDate")},
    {QStringLiteral("shipment_date"), QStringLiteral("shipmentDate")},
    {QStringLiteral("serial_number"), QStringLiteral("serialNumber")},
    {QStringLiteral("case_number"), QStringLiteral("caseNumber")},
    {QStringLiteral("manual_inclined"), QStringLiteral("manualInclined")},
    {QStringLiteral("first_phased_array_converters"), QStringLiteral("firstPhasedArrayConverters")},
    {QStringLiteral("second_phased_array_converters"), QStringLiteral("secondPhasedArrayConverters")},
    {QStringLiteral("aos_block"), QStringLiteral("aosBlock")},
    {QStringLiteral("battery_case"), QStringLiteral("batteryCase")},
  };

  auto snakeToCamel = [](const QString &snake) -> QString {
    if (snake.isEmpty()) return {};
    QStringList parts = snake.split('_', Qt::SkipEmptyParts);
    if (parts.isEmpty()) return {};
    QString camel = parts.first();
    for (int i = 1; i < parts.size(); ++i) {
      const QString &p = parts.at(i);
      if (p.isEmpty()) continue;
      camel += p.left(1).toUpper() + p.mid(1);
    }
    return camel;
  };

  auto strToBool = [](const QString &s) -> bool {
    const QString t = s.trimmed().toLower();
    return (t == QLatin1String("true") || t == QLatin1String("1") ||
            t == QLatin1String("yes") || t == QLatin1String("да") ||
            t == QLatin1String("y"));
  };


  for (auto it = obj.constBegin(); it != obj.constEnd(); ++it) {
    const QString key = it.key();
    const QJsonValue val = it.value();

    QString propName = specialMap.contains(key) ? specialMap.value(key) : snakeToCamel(key);
    if (propName.isEmpty()) {
      qDebug() << "SettingsManager::fromJson: empty propName for key" << key;
      continue;
    }

    int propIndex = meta->indexOfProperty(propName.toLatin1().constData());
    if (propIndex < 0) {
      qDebug() << "SettingsManager::fromJson: unknown property for key" << key << "=> tried" << propName;
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
          if (d.isValid()) writeVal = d.toString(Qt::ISODate);
          else writeVal = s;
        }
      } else {
        writeVal = QString();
      }
    } else if (prop.userType() == QMetaType::Bool) {
      if (val.isBool()) writeVal = val.toBool();
      else if (val.isString()) writeVal = strToBool(val.toString());
      else if (val.isDouble()) writeVal = (val.toInt() != 0);
      else writeVal = false;
    } else if (prop.userType() == QMetaType::Double) {
      if (val.isDouble()) writeVal = val.toDouble();
      else if (val.isString()) {
        QString s = val.toString().trimmed();
        s.replace(',', '.');
        writeVal = s.isEmpty() ? 0.0 : s.toDouble();
      } else if (val.isBool()) writeVal = val.toBool() ? 1.0 : 0.0;
      else writeVal = QVariant(); 
    } else if (prop.userType() == QMetaType::Int) {
      if (val.isDouble()) writeVal = val.toInt();
      else if (val.isString()) writeVal = val.toString().toInt();
      else if (val.isBool()) writeVal = val.toBool() ? 1 : 0;
      else writeVal = QVariant();
    } else {
      if (val.isNull() || val.isUndefined()) writeVal = QString();
      else if (val.isString()) writeVal = val.toString();
      else writeVal = val.toVariant();
    }

    if (writeVal.isValid()) {
      m_settings.setValue(settingsKey, writeVal);
    }
  }

  m_settings.sync();

  loadAllSettings();
}

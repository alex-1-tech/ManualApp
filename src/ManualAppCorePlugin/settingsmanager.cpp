#include "settingsmanager.h"
#include "utils.h"
#include <QDebug>
#include <QJsonObject>
#include <QJsonValue>
#include <QMetaProperty>


namespace {

const QHash<QString, QString> &specialCamelToSnake() {
  static const QHash<QString, QString> map = {
      // Регистрационные данные
      {QStringLiteral("serialNumber"), QStringLiteral("serial_number")},
      {QStringLiteral("shipmentDate"), QStringLiteral("shipment_date")},
      {QStringLiteral("caseNumber"), QStringLiteral("case_number")},
      {QStringLiteral("notes"), QStringLiteral("notes")},
      // {QStringLiteral("currentModel"), QStringLiteral("equipment_type")}
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
    : QObject(parent), m_settings("votum", "ManualApp"),
      m_kalmarSettings(new Kalmar32Settings(this)),
      m_phasarSettings(new Phasar32Settings(this)) {
  loadAllSettings();
}

SettingsManager::~SettingsManager() {
  // QObject parent-child relationship handles deletion
}

void SettingsManager::completeFirstRun() {
  DEBUG_COLORED("SettingsManager", "completeFirstRun", "first init settings",
                COLOR_MAGENTA, COLOR_MAGENTA);
  m_settings.setValue("isFirstRun", false);
}
void SettingsManager::saveModelSettings() {
  m_kalmarSettings->saveToSettings(m_settings);
  m_phasarSettings->saveToSettings(m_settings);
}
void SettingsManager::saveAllSettings() {
  // Save common properties
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

  // Save model-specific settings
  m_kalmarSettings->saveToSettings(m_settings);
  m_phasarSettings->saveToSettings(m_settings);
}

void SettingsManager::loadAllSettings() {
  // Load common properties
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

  // Load model-specific settings
  m_kalmarSettings->loadFromSettings(m_settings);
  m_phasarSettings->loadFromSettings(m_settings);
}

void SettingsManager::debugPrint() const {
  qDebug() << "=== Common Settings ===";
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

  // Serialize common properties
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
      continue; // Skip properties not in special map
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

  // Serialize model-specific settings based on current model
  if (currentModel() == "kalmar32") {
    QJsonObject modelObj = m_kalmarSettings->toJson();
    for (auto it = modelObj.constBegin(); it != modelObj.constEnd(); ++it) {
      obj[it.key()] = it.value();
    }
  } else if (currentModel() == "phasar32") {
    QJsonObject modelObj = m_phasarSettings->toJson();
    for (auto it = modelObj.constBegin(); it != modelObj.constEnd(); ++it) {
      obj[it.key()] = it.value();
    }
  }

  return obj;
}

void SettingsManager::fromJson(const QJsonObject &obj) {
  const QMetaObject *meta = this->metaObject();
  const QHash<QString, QString> &specialRev = specialSnakeToCamel();

  // Deserialize common properties
  for (auto it = obj.constBegin(); it != obj.constEnd(); ++it) {
    const QString key = it.key();
    const QJsonValue val = it.value();

    QString propName = specialRev.contains(key) ? specialRev.value(key) : key;

    if (propName.isEmpty()) {
      continue;
    }

    int propIndex = meta->indexOfProperty(propName.toLatin1().constData());
    if (propIndex < 0) {
      continue; // Skip unknown properties
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

  // Deserialize model-specific settings
  if (obj.contains("pc_tablet_dell_7230") ||
      obj.contains("water_tank_with_tap")) {
    // Try to detect which model this JSON belongs to
    if (obj.contains("water_tank_with_tap")) {
      m_phasarSettings->fromJson(obj);
    } else {
      m_kalmarSettings->fromJson(obj);
    }
  }

  m_settings.sync();
  loadAllSettings();
}

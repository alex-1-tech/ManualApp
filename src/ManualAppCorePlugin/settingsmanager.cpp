#include "settingsmanager.h"

#include <QDebug>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>
#include <QMetaProperty>

#include "kalmar32settings.h"
#include "utils.h"


namespace
{

const QHash<QString, QString>& specialCamelToSnake()
{
  static const QHash<QString, QString> map = {
      // Регистрационные данные
      {QStringLiteral("serialNumber"), QStringLiteral("serial_number")},
      {QStringLiteral("shipmentDate"), QStringLiteral("shipment_date")},
      {QStringLiteral("invoice"), QStringLiteral("invoice")},
      {QStringLiteral("packetList"), QStringLiteral("packet_list")},
      {QStringLiteral("wifiRouterAddress"), QStringLiteral("wifi_router_address")},
      {QStringLiteral("windowsPassword"), QStringLiteral("windows_password")},
      {QStringLiteral("notes"), QStringLiteral("notes")},
      {QStringLiteral("HWID"), QStringLiteral("HWID")},
      {QStringLiteral("currentModel"), QStringLiteral("equipment_type")}};
  return map;
}

const QHash<QString, QString>& specialSnakeToCamel()
{
  static QHash<QString, QString> rev;
  if (rev.isEmpty()) {
    const QHash<QString, QString>& fwd = specialCamelToSnake();
    for (auto it = fwd.constBegin(); it != fwd.constEnd(); ++it) {
      rev.insert(it.value(), it.key());
    }
  }
  return rev;
}

bool stringToBool(const QString& s)
{
  QString t = s.trimmed().toLower();
  return (t == QLatin1String("true") || t == QLatin1String("1") || t == QLatin1String("yes") ||
          t == QLatin1String("да") || t == QLatin1String("y"));
}

} // namespace

SettingsManager::SettingsManager(QObject* parent)
    : QObject(parent)
    , m_settings("technovotum", "ManualApp")
    , m_kalmarSettings(new Kalmar32Settings(this))
    , m_phasarSettings(new Phasar32Settings(this))
{
  loadAllSettings();
}

SettingsManager::~SettingsManager()
{
  // QObject parent-child relationship handles deletion
}

void SettingsManager::completeFirstRun()
{
  DEBUG_COLORED("SettingsManager", "completeFirstRun", "first init settings", COLOR_MAGENTA, COLOR_MAGENTA);
  m_settings.setValue("isFirstRun", false);
}
void SettingsManager::saveModelSettings()
{
  m_kalmarSettings->saveToSettings(m_settings);
  m_phasarSettings->saveToSettings(m_settings);
}
void SettingsManager::saveAllSettings()
{
  // Save common properties
  const QMetaObject* meta = this->metaObject();
  for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
    QMetaProperty prop = meta->property(i);
    if (!prop.isReadable()) continue;

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

void SettingsManager::loadAllSettings()
{
  // Load common properties
  const QMetaObject* meta = this->metaObject();
  for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
    QMetaProperty prop = meta->property(i);
    if (!prop.isWritable()) continue;

    if (!m_settings.contains(prop.name())) continue;

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

void SettingsManager::debugPrint() const
{
  qDebug() << "=== Common Settings ===";
  const QMetaObject* meta = this->metaObject();
  for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
    QMetaProperty prop = meta->property(i);
    QVariant value = prop.read(this);
    qDebug() << prop.name() << "=" << value;
  }

  if (currentModel() == "kalmar32")
    m_kalmarSettings->debugPrint();
  else if (currentModel() == "phasar32")
    m_phasarSettings->debugPrint();
}

QJsonObject SettingsManager::toJsonForDjango() const
{
  QJsonObject obj;
  const QMetaObject* meta = this->metaObject();
  const QHash<QString, QString>& special = specialCamelToSnake();

  // Serialize common properties
  for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
    QMetaProperty prop = meta->property(i);
    if (!prop.isReadable()) continue;

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

void SettingsManager::fromJson(const QJsonObject& obj)
{
  const QMetaObject* meta = this->metaObject();
  const QHash<QString, QString>& specialRev = specialSnakeToCamel();

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

  QString newModel = m_settings.value("currentModel").toString();

  if (newModel == "kalmar32") {
    DEBUG_COLORED("SettingsManager", "fromJson", "Loading Kalmar32 settings", COLOR_MAGENTA, COLOR_MAGENTA);
    m_kalmarSettings->fromJson(obj);
    m_kalmarSettings->saveToSettings(m_settings);
  } else if (newModel == "phasar32") {
    DEBUG_COLORED("SettingsManager", "fromJson", "Loading Phasar32 settings", COLOR_MAGENTA, COLOR_MAGENTA);
    m_phasarSettings->fromJson(obj);
    m_phasarSettings->saveToSettings(m_settings);
  } else {
    DEBUG_COLORED("SettingsManager", "fromJson", "Model not specified, trying to detect", COLOR_MAGENTA,
                  COLOR_MAGENTA);
    if (obj.contains("water_tank_with_tap")) {
      m_phasarSettings->fromJson(obj);
      m_phasarSettings->saveToSettings(m_settings);
      m_settings.setValue("currentModel", "phasar32");
    } else if (obj.contains("pc_tablet_dell_7230")) {
      m_kalmarSettings->fromJson(obj);
      m_kalmarSettings->saveToSettings(m_settings);
      m_settings.setValue("currentModel", "kalmar32");
    } else {
      DEBUG_ERROR_COLORED("SettingsManager", "fromJson", "Could not detect model type from JSON",
                          COLOR_MAGENTA, COLOR_MAGENTA);
    }
  }

  m_settings.sync();
  loadAllSettings();
}

Q_INVOKABLE bool SettingsManager::hasLicense()
{
  m_settings.beginGroup("license");
  bool ok = m_settings.contains("raw") || !m_settings.childKeys().isEmpty();
  m_settings.endGroup();
  return ok;
}

Q_INVOKABLE QJsonObject SettingsManager::license()
{
  m_settings.beginGroup("license");

  QJsonObject result;
  result["license_key"] = m_settings.value("license_key").toString();
  result["signature"] = m_settings.value("signature").toString();

  QJsonObject payload;
  payload["ver"] = m_settings.value("ver").toString();
  payload["product"] = m_settings.value("product").toString();
  payload["company_name"] = m_settings.value("company_name").toString();
  payload["host_hwid"] = m_settings.value("host_hwid").toString();
  payload["device_hwid"] = m_settings.value("device_hwid").toString();
  payload["exp"] = m_settings.value("exp").toString();

  QJsonObject features;
  payload["features"] = features;

  result["payload"] = payload;

  m_settings.endGroup();

  return result;
}

Q_INVOKABLE void SettingsManager::saveLicense(const QJsonObject& license)
{
  m_settings.beginGroup("license");

  m_settings.setValue("license_key", license.value("license_key").toString());
  m_settings.setValue("signature", license.value("signature").toString());

  QJsonObject payload = license.value("payload").toObject();

  m_settings.setValue("ver", payload.value("ver").toString());
  m_settings.setValue("product", payload.value("product").toString());
  m_settings.setValue("company_name", payload.value("company_name").toString());
  m_settings.setValue("host_hwid", payload.value("host_hwid").toString());
  m_settings.setValue("device_hwid", payload.value("device_hwid").toString());
  m_settings.setValue("exp", payload.value("exp").toString());

  QJsonObject features = payload.value("features").toObject();
  m_settings.setValue("features", QJsonDocument(features).toJson(QJsonDocument::Compact));

  m_settings.endGroup();

  QString hostHwid = payload.value("host_hwid").toString();
  if (hostHwid != "") {
    m_settings.setValue("HWID", hostHwid);
  } else {
    QString device_hwid = payload.value("device_hwid").toString();
    m_settings.setValue("HWID", device_hwid);
  }
  m_settings.sync();

  DEBUG_COLORED("SettingsManager", "saveLicense", "License saved with all parameters", COLOR_GREEN,
                COLOR_GREEN);
}

Q_INVOKABLE void SettingsManager::clearLicense()
{
  m_settings.beginGroup("license");
  for (const QString& k : m_settings.childKeys()) {
    m_settings.remove(k);
  }
  m_settings.endGroup();
  m_settings.sync();

  DEBUG_COLORED("SettingsManager", "clearLicense", "License cleared from QSettings", COLOR_MAGENTA,
                COLOR_MAGENTA);
}

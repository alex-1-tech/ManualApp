#include "settingsmanager.h"

#include <QCoreApplication>
#include <QDebug>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>
#include <QMetaProperty>

#include "../file/loger.h"


namespace
{

const QHash<QString, QString>& specialCamelToSnake()
{
  static const QHash<QString, QString> map = {
      {QStringLiteral("serialNumber"), QStringLiteral("serial_number")},
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
{
  initializeModels();
  loadAllSettings();
}

SettingsManager::~SettingsManager()
{
  qDeleteAll(m_models);
}

void SettingsManager::initializeModels()
{
  QString configPath = QCoreApplication::applicationDirPath() + "/media/jsons/models.json";
  m_configPath = configPath;

  QJsonObject rootObj = readJsonFile(configPath);

  if (rootObj.isEmpty()) {
    return;
  }

  if (!rootObj.contains("models") || !rootObj["models"].isObject()) {
    qWarning() << "JSON does not contain 'models' object";
    return;
  }

  QJsonObject modelsObj = rootObj["models"].toObject();
  QStringList modelNames = modelsObj.keys();

  if (modelNames.isEmpty()) {
    qWarning() << "No models found in configuration file";
    return;
  }

  for (const QString& modelName : modelNames) {
    ModelSettings* settings = new ModelSettings(modelName, this);

    if (!settings->loadConfiguration(configPath)) {
      qWarning() << "Failed to load configuration for model:" << modelName;
    } else {
      m_models[modelName] = settings;
    }
  }
}

QJsonObject SettingsManager::readJsonFile(const QString& filePath)
{
  QFile file(filePath);
  if (!file.open(QIODevice::ReadOnly)) {
    qWarning() << "Cannot open file:" << filePath;
    return QJsonObject();
  }

  QByteArray jsonData = file.readAll();
  file.close();

  QJsonParseError parseError;
  QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonData, &parseError);

  if (parseError.error != QJsonParseError::NoError) {
    qWarning() << "JSON parse error:" << parseError.errorString();
    return QJsonObject();
  }

  return jsonDoc.object();
}

ModelSettings* SettingsManager::getModelSettings(const QString& modelName) const
{
  if (modelName.isEmpty()) {
    return m_models.value(currentModel(), nullptr);
  }
  return m_models.value(modelName, nullptr);
}

void SettingsManager::completeFirstRun()
{
  DEBUG_COLORED("SettingsManager", "completeFirstRun", "Initial setup completed - first run flag cleared",
                COLOR_GREEN, COLOR_GREEN);
  m_settings.setValue("isFirstRun", false);
  updateLastManualAppDate();
}

void SettingsManager::saveModelSettings()
{
  DEBUG_COLORED("SettingsManager", "saveModelSettings", "Saving model-specific settings", COLOR_GREEN,
                COLOR_GREEN);

  for (auto it = m_models.begin(); it != m_models.end(); ++it) {
    it.value()->saveToSettings(m_settings);
  }
}

void SettingsManager::saveAllSettings()
{
  DEBUG_COLORED("SettingsManager", "saveAllSettings", "Saving all settings to persistent storage",
                COLOR_GREEN, COLOR_GREEN);

  const QMetaObject* meta = this->metaObject();
  for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
    QMetaProperty prop = meta->property(i);
    if (!prop.isReadable()) continue;

    QVariant value = prop.read(this);
    if (value.metaType().id() == QMetaType::QDate) {
      m_settings.setValue(prop.name(), value.toDate().toString(Qt::ISODate));
    } else {
      m_settings.setValue(prop.name(), value);
    }
  }

  saveModelSettings();

  m_settings.sync();
}

void SettingsManager::loadAllSettings()
{
  DEBUG_COLORED("SettingsManager", "loadAllSettings", "Loading all settings from persistent storage",
                COLOR_GREEN, COLOR_GREEN);

  const QMetaObject* meta = this->metaObject();
  for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
    QMetaProperty prop = meta->property(i);
    if (!prop.isWritable()) continue;

    if (!m_settings.contains(prop.name())) continue;

    QVariant val = m_settings.value(prop.name());
    if (prop.metaType().id() == QMetaType::QDate) {
      QDate date = QDate::fromString(val.toString(), Qt::ISODate);
      prop.write(this, date);
    } else {
      prop.write(this, val);
    }
  }

  for (auto it = m_models.begin(); it != m_models.end(); ++it) {
    it.value()->loadFromSettings(m_settings, currentModel());
  }

  emit modelsChanged();
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

  if (m_models.contains(currentModel())) {
    m_models[currentModel()]->debugPrint();
  }
}

QJsonObject SettingsManager::toJsonForDjango() const
{
  QJsonObject obj;
  const QMetaObject* meta = this->metaObject();
  const QHash<QString, QString>& special = specialCamelToSnake();

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

  if (m_models.contains(currentModel())) {
    QJsonObject modelObj = m_models[currentModel()]->toJson();
    for (auto it = modelObj.constBegin(); it != modelObj.constEnd(); ++it) {
      obj[it.key()] = it.value();
    }
  }

  return obj;
}

void SettingsManager::fromJson(const QJsonObject& obj)
{
  DEBUG_COLORED("SettingsManager", "fromJson", "Loading settings from JSON object", COLOR_GREEN, COLOR_GREEN);

  const QMetaObject* meta = this->metaObject();
  const QHash<QString, QString>& specialRev = specialSnakeToCamel();

  for (auto it = obj.constBegin(); it != obj.constEnd(); ++it) {
    const QString key = it.key();
    const QJsonValue val = it.value();

    QString propName = specialRev.contains(key) ? specialRev.value(key) : key;
    if (propName.isEmpty()) {
      continue;
    }

    int propIndex = meta->indexOfProperty(propName.toLatin1().constData());
    if (propIndex < 0) {
      continue;
    }

    QMetaProperty prop = meta->property(propIndex);
    QString settingsKey = QString::fromLatin1(prop.name());
    QVariant writeVal;

    if (prop.metaType().id() == QMetaType::QDate) {
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
    } else if (prop.metaType().id() == QMetaType::Bool) {
      if (val.isBool())
        writeVal = val.toBool();
      else if (val.isString())
        writeVal = stringToBool(val.toString());
      else if (val.isDouble())
        writeVal = (val.toInt() != 0);
      else
        writeVal = false;
    } else if (prop.metaType().id() == QMetaType::Double) {
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
    } else if (prop.metaType().id() == QMetaType::Int) {
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

  QString modelToUse = currentModel();

  if (m_models.contains(modelToUse)) {
    DEBUG_COLORED("SettingsManager", "fromJson",
                  QString("Loading %1 model-specific settings").arg(modelToUse), COLOR_GREEN, COLOR_GREEN);
    m_models[modelToUse]->fromJson(obj);
    m_models[modelToUse]->saveToSettings(m_settings);
  }

  m_settings.sync();
  loadAllSettings();
}


void SettingsManager::saveDateIso(const QString& key, const QString& dateStr)
{
  if (key.isEmpty()) return;

  QDate date;

  date = QDate::fromString(dateStr, Qt::ISODate);

  if (!date.isValid()) date = QLocale().toDate(dateStr, QLocale::ShortFormat);

  if (!date.isValid()) date = QDate::fromString(dateStr, "M/d/yy");

  if (!date.isValid()) {
    bool ok = false;
    qint64 ts = dateStr.toLongLong(&ok);
    if (ok) date = QDateTime::fromSecsSinceEpoch(ts).date();
  }

  if (!date.isValid()) {
    DEBUG_ERROR_COLORED("SettingsManager", "saveDateIso", "invalid date:", COLOR_GREEN, COLOR_GREEN);
    return;
  }

  m_settings.setValue(key, date.toString(Qt::ISODate));
}
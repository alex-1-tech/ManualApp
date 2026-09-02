#include "modelsettings.h"

#include <qcontainerfwd.h>

#include <QDebug>
#include <QMetaObject>
#include <QMetaProperty>
#include <QMetaType>

int ModelSettings::s_propertyCounter = 0;

QVariantMap ModelSettings::FieldMetadata::toVariantMap() const
{
  QVariantMap map;
  map["name"] = name;
  map["label"] = label;
  map["helpText"] = helpText;
  map["type"] = type;
  map["cppName"] = cppName;

  return map;
}

ModelSettings::ModelSettings(const QString& modelName, QObject* parent)
    : QObject(parent)
    , m_modelName(modelName)
{
}

bool ModelSettings::loadConfiguration(const QString& jsonPath)
{
  QFile file(jsonPath);
  if (!file.open(QIODevice::ReadOnly)) {
    qWarning() << "Failed to open config file:" << jsonPath;
    return false;
  }

  QByteArray data = file.readAll();
  QJsonDocument doc = QJsonDocument::fromJson(data);
  if (doc.isNull()) {
    qWarning() << "Invalid JSON in config file:" << jsonPath;
    return false;
  }

  QJsonObject root = doc.object();

  if (root.contains("models") && root["models"].isObject()) {
    QJsonObject models = root["models"].toObject();
    if (models.contains(m_modelName) && models[m_modelName].isObject()) {
      QJsonObject modelConfig = models[m_modelName].toObject();
      parseModelMetadata(modelConfig);
      createPropertiesFromConfig(modelConfig);
      return true;
    }
  }

  if (root.contains("sections") && root["sections"].isArray()) {
    createPropertiesFromConfig(root);
    return true;
  }

  qWarning() << "Model" << m_modelName << "not found in config file";
  return false;
}

void ModelSettings::parseModelMetadata(const QJsonObject& config)
{
  m_modelTitle.clear();
  m_modelDescription.clear();

  if (config.contains("fields") && config["fields"].isObject()) {
    QJsonObject metadata = config["fields"].toObject();
    m_modelTitle = metadata["title"].toString();
    m_modelDescription = metadata["description"].toString();
    m_modelInstallerPath = metadata["installer_path"].toString();
  }

  if (config.contains("variants") && config["variants"].isArray()) {
    m_modelVariants = config["variants"].toArray().toVariantList();
  }
}

bool ModelSettings::loadScheme(const QString& jsonPath)
{
  QFile file(jsonPath);
  if (!file.open(QIODevice::ReadOnly)) return false;

  QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
  QJsonObject root = doc.object();

  if (root.contains("sections") && root["sections"].isArray()) {
    createPropertiesFromConfig(root);
    return true;
  }
  return false;
}

void ModelSettings::createPropertiesFromConfig(const QJsonObject& config)
{
  m_sections.clear();
  m_fieldsMetadata.clear();
  m_values.clear();

  if (!config.contains("sections") || !config["sections"].isArray()) {
    qWarning() << "Missing sections array in" << m_modelName << "config";
    return;
  }

  QJsonArray sectionsArray = config["sections"].toArray();

  for (const QJsonValue& sectionVal : sectionsArray) {
    if (!sectionVal.isObject()) continue;

    QJsonObject sectionObj = sectionVal.toObject();

    Section section;
    section.title = sectionObj["title"].toString();

    QJsonArray fields = sectionObj["fields"].toArray();

    for (const QJsonValue& fieldVal : fields) {
      if (!fieldVal.isObject()) continue;

      QJsonObject field = fieldVal.toObject();

      FieldMetadata metadata;
      metadata.name = field["name"].toString();
      metadata.label = field["label"].toString();
      metadata.cppName = field["cpp_name"].toString();
      metadata.type = field["type"].toString("string");
      metadata.helpText = field["help_text"].toString();

      QVariant defaultValue;

      if (metadata.type == "boolean")
        defaultValue = false;
      else
        defaultValue = QString();

      m_fieldsMetadata[metadata.cppName] = metadata;
      m_values[metadata.cppName] = defaultValue;

      setProperty(metadata.name.toLatin1().constData(), defaultValue);

      section.fields.append(metadata);
    }

    m_sections.append(section);
  }

  emit fieldsChanged();
}
void ModelSettings::loadFromSettings(QSettings& settings, const QString& currentModel, const QString& prefix)
{
  QString pre = prefix.isEmpty() ? m_modelName + "/" : prefix;

  for (auto it = m_fieldsMetadata.begin(); it != m_fieldsMetadata.end(); ++it) {
    const QString& cppName = it.key();
    const FieldMetadata& metadata = it.value();

    QVariant value;
    QString key = pre + cppName;
    QString generalKey = cppName;

    if (cppName == "serialNumber") {
      if (settings.contains(generalKey)) {
        settings.remove(generalKey);
        qDebug() << "Removed global serialNumber:" << generalKey;
      }
    }

    if (settings.contains(key)) {
      value = settings.value(key);
    } else {
      if (metadata.type == "boolean") {
        value = false;
      } else {
        value = QString();
      }
    }

    if (metadata.type == "boolean") {
      if (value.typeId() == QMetaType::QString) {
        QString str = value.toString().trimmed().toLower();
        value = (str == "true" || str == "1" || str == "yes" || str == "да");
      } else {
        value = value.toBool();
      }
    }
    m_values[cppName] = value;
    setProperty(cppName.toLatin1().constData(), value);
  }
}


void ModelSettings::saveToSettings(QSettings& settings, const QString& prefix) const
{
  QString pre = prefix.isEmpty() ? m_modelName + "/" : prefix;

  for (auto it = m_values.constBegin(); it != m_values.constEnd(); ++it) {
    settings.setValue(pre + it.key(), it.value());
  }
}

QJsonObject ModelSettings::toJson() const
{
  QJsonObject obj;

  for (auto it = m_values.constBegin(); it != m_values.constEnd(); ++it) {
    const QString& fieldName = it.key();
    if (m_fieldsMetadata.contains(fieldName)) {
      const FieldMetadata& metadata = m_fieldsMetadata[fieldName];
      obj[metadata.name] = QJsonValue::fromVariant(it.value());
    }
  }

  return obj;
}

void ModelSettings::fromJson(const QJsonObject& obj)
{
  for (auto it = m_fieldsMetadata.begin(); it != m_fieldsMetadata.end(); ++it) {
    const QString& fieldName = it.key();
    const FieldMetadata& metadata = it.value();

    if (obj.contains(metadata.name)) {
      QJsonValue val = obj[metadata.name];
      QVariant variant;

      if (metadata.type == "boolean") {
        variant = val.toBool();
      } else {
        variant = val.toString();
      }

      m_values[fieldName] = variant;
      setProperty(fieldName.toLatin1().constData(), variant);
    }
  }
}

void ModelSettings::debugPrint() const
{
  qDebug() << "=== " << m_modelName << " Settings (Dynamic) ===";
  for (auto it = m_values.constBegin(); it != m_values.constEnd(); ++it) {
    qDebug() << it.key() << "=" << it.value();
  }
}

QVariant ModelSettings::getValue(const QString& name) const
{
  return property(name.toLatin1().constData());
}

void ModelSettings::setValue(const QString& name, const QVariant& value)
{
  QVariant newValue = value;

  if (value.metaType().id() == QMetaType::QDate) {
    newValue = value.toDate().toString(Qt::ISODate); // YYYY-MM-DD
  } else if (value.metaType().id() == QMetaType::QDateTime) {
    newValue = value.toDateTime().date().toString(Qt::ISODate);
  }

  QVariant oldValue = property(name.toLatin1().constData());

  if (oldValue != newValue) {
    setProperty(name.toLatin1().constData(), newValue);
    m_values[name] = newValue;
    emit propertyChanged(name, newValue);
  }
}

QStringList ModelSettings::getPropertyNames() const
{
  return m_values.keys();
}

QVariantMap ModelSettings::getFieldMetadata(const QString& fieldName) const
{
  if (!m_fieldsMetadata.contains(fieldName)) {
    return QVariantMap();
  }

  return m_fieldsMetadata[fieldName].toVariantMap();
}

QVariantList ModelSettings::getFieldsMetadata() const
{
  QVariantList result;
  for (auto it = m_fieldsMetadata.constBegin(); it != m_fieldsMetadata.constEnd(); ++it) {
    result.append(it.value().toVariantMap());
  }
  return result;
}

QVariantList ModelSettings::getSectionsMetadata() const
{
  QVariantList sectionsList;

  for (const Section& section : m_sections) {
    QVariantMap sectionMap;
    sectionMap["title"] = section.title;

    QVariantList fieldsList;
    for (const FieldMetadata& field : section.fields) {
      fieldsList.append(field.toVariantMap());
    }

    sectionMap["fields"] = fieldsList;
    sectionsList.append(sectionMap);
  }

  return sectionsList;
}
#include "modelsettings.h"

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
  map["placeholder"] = placeholder;
  map["type"] = type;
  map["jsonKey"] = jsonKey;
  map["defaultValue"] = defaultValue;
  map["cppType"] = cppType;
  map["visibleInInitialMode"] = visibleInInitialMode;
  map["checkboxText"] = checkboxText;
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

  QJsonObject metadata;

  if (config.contains("fields") && config["fields"].isObject()) {
    metadata = config["fields"].toObject();
  }

  if (!metadata.isEmpty()) {
    if (metadata.contains("title")) {
      m_modelTitle = metadata["title"].toString();
    }

    if (metadata.contains("description")) {
      m_modelDescription = metadata["description"].toString();
    }

    if (metadata.contains("installer_path")) {
      m_modelInstallerPath = metadata["installer_path"].toString();
    }
  }
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
      metadata.placeholder = field["placeholder"].toString();
      metadata.type = field["type"].toString();
      metadata.jsonKey = field["json_key"].toString();
      metadata.cppType = field["cpptype"].toString();
      metadata.visibleInInitialMode = field["visibleInInitialMode"].toBool(false);
      metadata.checkboxText = field["checkboxText"].toString();

      QVariant defaultValue;

      if (metadata.cppType == "bool")
        defaultValue = field["default"].toBool(false);
      else if (metadata.cppType == "int")
        defaultValue = field["default"].toInt(0);
      else if (metadata.cppType == "double")
        defaultValue = field["default"].toDouble(0.0);
      else
        defaultValue = field["default"].toString("");

      metadata.defaultValue = defaultValue;

      m_fieldsMetadata[metadata.name] = metadata;
      m_values[metadata.name] = defaultValue;

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
    const QString& fieldName = it.key();
    const FieldMetadata& metadata = it.value();

    QVariant value;
    QString key = pre + fieldName;
    QString generalKey = fieldName;

    if (fieldName == "serialNumber") {
      if (settings.contains(key)) {
        value = settings.value(key, metadata.defaultValue);

        if (!settings.contains(generalKey)) {
          settings.setValue(generalKey, value);
          qDebug() << "Copied serialNumber from model to General:" << value;
        }
      } else if (settings.contains(generalKey)) {
        value = settings.value(generalKey, metadata.defaultValue);

        settings.setValue(key, value);
        qDebug() << "Copied serialNumber from General to model:" << value;
      } else {
        value = metadata.defaultValue;

        if (value.isValid() && !value.isNull() && value.toString() != "") {
          settings.setValue(generalKey, value);
          settings.setValue(key, value);
          qDebug() << "Set default serialNumber in both locations:" << value;
        }
      }
    } else if (settings.contains(key)) {
      value = settings.value(key, metadata.defaultValue);
    } else {
      value = metadata.defaultValue;
    }

    if (metadata.cppType == "bool") {
      if (value.typeId() == QMetaType::QString) {
        QString str = value.toString().toLower();
        value = (str == "true" || str == "1" || str == "yes" || str == "да");
      } else if (value.typeId() == QMetaType::Int) {
        value = value.toInt() != 0;
      } else if (value.typeId() != QMetaType::Bool) {
        value = value.toBool();
      }
    } else if (metadata.cppType == "int") {
      if (value.typeId() == QMetaType::QString) {
        value = value.toString().toInt();
      } else if (value.typeId() != QMetaType::Int) {
        value = value.toInt();
      }
    } else if (metadata.cppType == "double") {
      if (value.typeId() == QMetaType::QString) {
        value = value.toString().replace(',', '.').toDouble();
      } else if (value.typeId() != QMetaType::Double) {
        value = value.toDouble();
      }
    }

    m_values[fieldName] = value;
    setProperty(fieldName.toLatin1().constData(), value);
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
      obj[metadata.jsonKey] = QJsonValue::fromVariant(it.value());
    }
  }

  return obj;
}

void ModelSettings::fromJson(const QJsonObject& obj)
{
  for (auto it = m_fieldsMetadata.begin(); it != m_fieldsMetadata.end(); ++it) {
    const QString& fieldName = it.key();
    const FieldMetadata& metadata = it.value();

    if (obj.contains(metadata.jsonKey)) {
      QJsonValue val = obj[metadata.jsonKey];
      QVariant variant;

      if (metadata.cppType == "bool") {
        if (val.isBool()) {
          variant = val.toBool();
        } else if (val.isString()) {
          QString str = val.toString().toLower();
          variant = (str == "true" || str == "1" || str == "yes" || str == "да");
        } else if (val.isDouble()) {
          variant = val.toInt() != 0;
        } else {
          variant = false;
        }
      } else if (metadata.cppType == "int") {
        if (val.isDouble()) {
          variant = val.toInt();
        } else if (val.isString()) {
          variant = val.toString().toInt();
        } else {
          variant = 0;
        }
      } else if (metadata.cppType == "double") {
        if (val.isDouble()) {
          variant = val.toDouble();
        } else if (val.isString()) {
          variant = val.toString().replace(',', '.').toDouble();
        } else {
          variant = 0.0;
        }
      } else {
        if (val.isNull() || val.isUndefined()) {
          variant = QString();
        } else if (val.isString()) {
          variant = val.toString();
        } else {
          variant = val.toVariant();
        }
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
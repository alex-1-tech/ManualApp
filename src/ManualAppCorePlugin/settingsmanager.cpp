#include "settingsmanager.h"
#include "utils.h"
#include <QDebug>
#include <QMetaProperty>

SettingsManager::SettingsManager(QObject *parent)
    : QObject(parent), m_settings("votum", "ManualApp") {
  loadAllSettings();
  // m_settings.clear();
  // qDebug() << isFirstRun();
  // debugPrint();
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

void SettingsManager::fromJson(const QJsonObject &obj) {
  const QMetaObject *meta = this->metaObject();
  for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
    QMetaProperty prop = meta->property(i);
    if (!prop.isWritable())
      continue;

    QString name = prop.name();
    if (!obj.contains(name))
      continue;

    QVariant value;

    if (prop.userType() == QMetaType::QDate) {
      value = QDate::fromString(obj[name].toString(), Qt::ISODate);
    } else {
      value = obj[name].toVariant();
    }

    prop.write(this, value);
  }
}
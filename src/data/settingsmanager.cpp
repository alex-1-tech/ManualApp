#include "settingsmanager.h"
#include <QDebug>
#include <QMetaProperty>

SettingsManager::SettingsManager(QObject *parent)
    : QObject(parent), m_settings("votum", "ManualApp") {}


void SettingsManager::debugPrint() const {
    const QMetaObject *meta = this->metaObject();
    for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
        QMetaProperty prop = meta->property(i);
        QVariant value = prop.read(this);
        qDebug() << prop.name() << "=" << value;
    }
}

void SettingsManager::saveAllSettings() {
    const QMetaObject *meta = this->metaObject();
    for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
        QMetaProperty prop = meta->property(i);
        if (!prop.isReadable()) continue;

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
        if (!prop.isWritable()) continue;

        QVariant val = m_settings.value(prop.name());

        if (prop.userType() == QMetaType::QDate) {
            QDate date = QDate::fromString(val.toString(), Qt::ISODate);
            prop.write(this, date);
        } else {
            prop.write(this, val);
        }
    }
}

QJsonObject SettingsManager::toJson() const {
    QJsonObject obj;
    const QMetaObject *meta = this->metaObject();
    for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
        QMetaProperty prop = meta->property(i);
        if (!prop.isReadable()) continue;

        QVariant value = prop.read(this);

        // Обработка QDate → строка (ISO 8601)
        if (value.canConvert<QDate>()) {
            QDate date = value.toDate();
            obj[prop.name()] = date.toString(Qt::ISODate);
        } else {
            obj[prop.name()] = QJsonValue::fromVariant(value);
        }
    }
    return obj;
}

void SettingsManager::fromJson(const QJsonObject &obj) {
    const QMetaObject *meta = this->metaObject();
    for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
        QMetaProperty prop = meta->property(i);
        if (!prop.isWritable()) continue;

        QString name = prop.name();
        if (!obj.contains(name)) continue;

        QVariant value;

        if (prop.userType() == QMetaType::QDate) {
            value = QDate::fromString(obj[name].toString(), Qt::ISODate);
        } else {
            value = obj[name].toVariant();
        }

        prop.write(this, value);
    }
}
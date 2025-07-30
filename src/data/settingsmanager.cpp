#include "settingsmanager.h"

SettingsManager::SettingsManager(QObject* parent) 
    : QObject(parent), m_settings("votum", "ManualApp") 
{
}


QString SettingsManager::machineSerial() const {
    return m_settings.value("machineSerial", "").toString();
}

void SettingsManager::setMachineSerial(const QString& serial) {
    if (machineSerial() != serial) {
        m_settings.setValue("machineSerial", serial);
        emit machineSerialChanged();
    }
}

QString SettingsManager::tabletSerial() const {
    return m_settings.value("tabletSerial", "").toString();
}

void SettingsManager::setTabletSerial(const QString& serial) {
    if (tabletSerial() != serial) {
        m_settings.setValue("tabletSerial", serial);
        emit tabletSerialChanged();
    }
}

QString SettingsManager::evbSerial() const {
    return m_settings.value("evbSerial", "").toString();
}

void SettingsManager::setEvbSerial(const QString& serial) {
    if (evbSerial() != serial) {
        m_settings.setValue("evbSerial", serial);
        emit evbSerialChanged();
    }
}
#pragma once
#include <QObject>
#include <QSettings>

class SettingsManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString machineSerial READ machineSerial WRITE setMachineSerial NOTIFY machineSerialChanged)
    Q_PROPERTY(QString tabletSerial READ tabletSerial WRITE setTabletSerial NOTIFY tabletSerialChanged)
    Q_PROPERTY(QString evbSerial READ evbSerial WRITE setEvbSerial NOTIFY evbSerialChanged)

public:
    explicit SettingsManager(QObject* parent = nullptr);
    ~SettingsManager() {
    }

    QString machineSerial() const;
    void setMachineSerial(const QString& serial);

    QString tabletSerial() const;
    void setTabletSerial(const QString& serial);

    QString evbSerial() const;
    void setEvbSerial(const QString& serial);

signals:
    void machineSerialChanged();
    void tabletSerialChanged();
    void evbSerialChanged();

private:
    QSettings m_settings;
};
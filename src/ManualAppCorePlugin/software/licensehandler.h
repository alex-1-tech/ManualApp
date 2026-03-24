#pragma once

#include <QDate>
#include <QJsonObject>
#include <QObject>
#include <QSettings>

class LicenseHandler : public QObject
{
  Q_OBJECT
  Q_PROPERTY(bool isLicenseActivate READ isLicenseActivate NOTIFY licenseActivationStatusChanged)
public:
  explicit LicenseHandler(QObject* parent = nullptr);
  ~LicenseHandler();

  bool hasLicense() const;
  QJsonObject license() const;
  void saveLicense(const QJsonObject& license);
  void clearLicense();
  bool verifyLicense();
  Q_INVOKABLE void licenseActivationSucceeded() { setIsLicenseActivate(true); }
  Q_INVOKABLE bool isLicenseActivate() const;
  void setIsLicenseActivate(bool value);

  void checkLicenseKeyOnStart();

signals:
  void licenseChanged();
  void licenseVerified(bool valid);
  void licenseActivationStatusChanged(bool activated);

private:
  void updateActivationStatusFromSettings();

private:
  QSettings m_settings;
  bool m_isLicenseActivate;
};
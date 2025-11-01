#pragma once

#include <QDebug>
#include <QDir>
#include <QObject>
#include <QSettings>

class ConfigManager : public QObject {
  Q_OBJECT

public:
  static ConfigManager &instance();

  QString djangoBaseUrl() const;
  QString appVersion() const;

  void printConfig() const;

private:
  ConfigManager(QObject *parent = nullptr);
  QSettings *m_settings;
  QString m_configPath;
};

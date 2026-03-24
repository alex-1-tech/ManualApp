#include "configmanager.h"

#include <QApplication>


ConfigManager& ConfigManager::instance()
{
  static ConfigManager instance;
  return instance;
}

ConfigManager::ConfigManager(QObject* parent)
    : QObject(parent)
{
  QDir currentDir = QDir::current();
  QString configPath = QCoreApplication::applicationDirPath() + "/.config.ini";

  if (!QFile::exists(configPath)) {
    qWarning() << "Config file not found:" << configPath;
    configPath = currentDir.absoluteFilePath(".config.ini");
  }

  m_configPath = configPath;
  m_settings = new QSettings(configPath, QSettings::IniFormat, this);

  qDebug() << "Config loaded from:" << configPath;
}

QString ConfigManager::djangoBaseUrl() const
{
  return m_settings->value("base_url", "http://127.0.0.1:8000").toString();
}
QString ConfigManager::appVersion() const
{
  return m_settings->value("app_version", "-").toString();
}
void ConfigManager::printConfig() const
{
  qDebug() << "Config path:" << m_configPath;
  qDebug() << "Django URL:" << djangoBaseUrl();
}
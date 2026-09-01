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
  QString exeDir = QCoreApplication::applicationDirPath();
  QStringList searchPaths = {exeDir + "/.config.ini",    // build/Debug
                             exeDir + "/../.config.ini", // build/
                             exeDir + "/../../.config.ini", QDir::current().absoluteFilePath(".config.ini")};

  QString finalPath = searchPaths.last();

  for (const QString& path : searchPaths) {
    if (QFile::exists(path)) {
      finalPath = path;
      break;
    }
  }

  if (!QFile::exists(finalPath)) {
    qWarning() << "Config file not found in any standard locations. Defaulting to:" << finalPath;
  }

  m_configPath = QDir::cleanPath(finalPath);
  m_settings = new QSettings(m_configPath, QSettings::IniFormat, this);

  qDebug() << "Config loaded from:" << m_configPath;
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
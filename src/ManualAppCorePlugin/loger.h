#pragma once
#include <QCoreApplication>
#include <QDateTime>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QMutex>
#include <QMutexLocker>
#include <QString>
#include <QTextStream>

#define COLOR_RESET "\033[0m"
#define COLOR_RED "\033[31m"
#define COLOR_GREEN "\033[32m"
#define COLOR_YELLOW "\033[33m"
#define COLOR_BLUE "\033[34m"
#define COLOR_MAGENTA "\033[35m"
#define COLOR_CYAN "\033[36m"
#define COLOR_WHITE "\033[37m"

#define DEBUG_COLORED(module, action, message, colorModule, colorAction)                                     \
  do {                                                                                                       \
    QString msg = QString(colorModule) + "[" + module + "]" + colorAction + "[" + action + "] " +            \
                  COLOR_RESET + message;                                                                     \
    qDebug().noquote() << msg;                                                                               \
  } while (false)

#define DEBUG_ERROR_COLORED(module, action, message, colorModule, colorAction)                               \
  do {                                                                                                       \
    QString msg = QString(colorModule) + "[" + module + "]" + colorAction + "[" + action + "] " +            \
                  COLOR_RED + message + COLOR_RESET;                                                         \
    qWarning().noquote() << msg;                                                                             \
  } while (false)

#define LOG_DEBUG(module, action, message) DEBUG_COLORED(module, action, message, COLOR_CYAN, COLOR_GREEN)

#define LOG_INFO(module, action, message)                                                                    \
  Logger::instance().log(module, action, message, Logger::LogLevel::Info)

#define LOG_WARNING(module, action, message)                                                                 \
  Logger::instance().log(module, action, message, Logger::LogLevel::Warning)

#define LOG_ERROR(module, action, message)                                                                   \
  DEBUG_ERROR_COLORED(module, action, message, COLOR_RED, COLOR_YELLOW)

#define LOG_CRITICAL(module, action, message)                                                                \
  Logger::instance().log(module, action, message, Logger::LogLevel::Critical)

inline QString resolveResourcePath(const QString& filePath)
{
  if (filePath.startsWith("qrc:/")) return ":" + filePath.mid(4);
  if (filePath.startsWith(":/")) return filePath;
  return ":/" + filePath;
}


class Logger
{
public:
  enum class LogLevel { Debug, Info, Warning, Error, Critical };


  static Logger& instance()
  {
    static Logger instance;
    return instance;
  }

  void initialize(const QString& logDir = "",
                  qint64 maxFileSize = 10 * 1024 * 1024, // 10 MB
                  int maxFiles = 5)
  {
    QMutexLocker locker(&m_mutex);

    m_maxFileSize = maxFileSize;
    m_maxFiles = maxFiles;

    if (logDir.isEmpty()) {
      m_logDir = QCoreApplication::applicationDirPath() + "/logs";
    } else {
      m_logDir = logDir;
    }

    QDir dir(m_logDir);
    if (!dir.exists()) {
      dir.mkpath(".");
    }

    QString dateStr = QDateTime::currentDateTime().toString("yyyy-MM-dd");
    m_currentLogFile = QString("%1/app_%2.log").arg(m_logDir).arg(dateStr);

    m_logFile.setFileName(m_currentLogFile);
    if (!m_logFile.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
      qWarning() << "Cannot open log file:" << m_currentLogFile;
      return;
    }

    m_initialized = true;
  }

  void log(const QString& module, const QString& action, const QString& message,
           LogLevel level = LogLevel::Info)
  {
    QMutexLocker locker(&m_mutex);

    if (!m_initialized) {
      initialize();
    }

    checkFileSize();

    QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss.zzz");
    QString levelStr = logLevelToString(level);
    QString logEntry =
        QString("[%1] [%2] [%3] [%4] %5\n").arg(timestamp).arg(levelStr).arg(module).arg(action).arg(message);

    QTextStream stream(&m_logFile);
    stream << logEntry;
    stream.flush();

    if (level != LogLevel::Debug) {
      QString color = getColorForLevel(level);
      QString coloredLog = QString("%1[%2]%3 [%4] [%5] %6%7")
                               .arg(color)
                               .arg(levelStr)
                               .arg(COLOR_RESET)
                               .arg(module)
                               .arg(action)
                               .arg(message)
                               .arg(COLOR_RESET);
      switch (level) {
        case LogLevel::Info: qInfo().noquote() << coloredLog; break;
        case LogLevel::Warning: qWarning().noquote() << coloredLog; break;
        case LogLevel::Error:
        case LogLevel::Critical: qCritical().noquote() << coloredLog; break;
        default: break;
      }
    }
  }

  QString getCurrentLogFile()
  {
    QMutexLocker locker(&m_mutex);
    return m_currentLogFile;
  }

  QString getLogDir()
  {
    QMutexLocker locker(&m_mutex);
    return m_logDir;
  }

  void cleanOldLogs(int daysToKeep = 30)
  {
    QMutexLocker locker(&m_mutex);

    QDir dir(m_logDir);
    QStringList logFiles = dir.entryList(QStringList("*.log"), QDir::Files);

    QDateTime now = QDateTime::currentDateTime();

    for (const QString& fileName : logFiles) {
      QString filePath = m_logDir + "/" + fileName;
      QFileInfo fileInfo(filePath);
      QDateTime fileDate = fileInfo.lastModified();

      if (fileDate.daysTo(now) > daysToKeep) {
        QFile::remove(filePath);
      }
    }
  }

  void setMaxFileSize(qint64 maxSize)
  {
    QMutexLocker locker(&m_mutex);
    m_maxFileSize = maxSize;
  }

  void setMaxFiles(int maxFiles)
  {
    QMutexLocker locker(&m_mutex);
    m_maxFiles = maxFiles;
  }

  void close()
  {
    QMutexLocker locker(&m_mutex);
    if (m_logFile.isOpen()) {
      m_logFile.close();
    }
    m_initialized = false;
  }
  static void cleanup() { instance().close(); }

  ~Logger() { close(); }

private:
  Logger()
      : m_initialized(false)
      , m_maxFileSize(10 * 1024 * 1024)
      , m_maxFiles(5)
  {
  }
  Logger(const Logger&) = delete;
  Logger& operator=(const Logger&) = delete;

  void checkFileSize()
  {
    if (m_logFile.size() >= m_maxFileSize) {
      m_logFile.close();

      for (int i = m_maxFiles - 1; i > 0; --i) {
        QString oldFile = QString("%1.%2").arg(m_currentLogFile).arg(i);
        QString newFile = QString("%1.%2").arg(m_currentLogFile).arg(i + 1);

        if (QFile::exists(oldFile)) {
          QFile::rename(oldFile, newFile);
        }
      }

      QString backupFile = m_currentLogFile + ".1";
      QFile::rename(m_currentLogFile, backupFile);

      if (!m_logFile.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
        qWarning() << "Cannot reopen log file after rotation:" << m_currentLogFile;
        return;
      }
    }
  }

  QString logLevelToString(LogLevel level) const
  {
    switch (level) {
      case LogLevel::Debug: return "DEBUG";
      case LogLevel::Info: return "INFO";
      case LogLevel::Warning: return "WARNING";
      case LogLevel::Error: return "ERROR";
      case LogLevel::Critical: return "CRITICAL";
      default: return "UNKNOWN";
    }
  }

  QString getColorForLevel(LogLevel level) const
  {
    switch (level) {
      case LogLevel::Debug: return COLOR_CYAN;
      case LogLevel::Info: return COLOR_GREEN;
      case LogLevel::Warning: return COLOR_YELLOW;
      case LogLevel::Error: return COLOR_RED;
      case LogLevel::Critical: return COLOR_MAGENTA;
      default: return COLOR_WHITE;
    }
  }

private:
  QFile m_logFile;
  QString m_currentLogFile;
  QString m_logDir;
  QMutex m_mutex;
  bool m_initialized;
  qint64 m_maxFileSize;
  int m_maxFiles;
};
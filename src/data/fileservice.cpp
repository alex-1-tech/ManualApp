#include "fileservice.h"
#include "utils.h"
#include <QFileInfo>

FileService::FileService(QObject *parent) : QObject(parent) {
  DEBUG_COLORED("FileService", "Constructor", "File service initialized",
                COLOR_MAGENTA, COLOR_MAGENTA);
}

FileService::~FileService() {
  DEBUG_COLORED("FileService", "Destructor", "Cleaning up file service",
                COLOR_MAGENTA, COLOR_MAGENTA);
}

bool FileService::saveJsonToFile(const QString &filePath,
                                 const QJsonObject &jsonObject) {
  DEBUG_COLORED("FileService", "saveJsonToFile",
                QString("Attempting to save JSON to file: %1").arg(filePath),
                COLOR_MAGENTA, COLOR_MAGENTA);

  QFileInfo fileInfo(filePath);
  QDir dir = fileInfo.dir();
  if (!dir.exists()) {
    DEBUG_ERROR_COLORED("FileService", "saveJsonToFile",
                        QString("Directory doesn't exist, creating: %1")
                            .arg(dir.absolutePath()),
                        COLOR_MAGENTA, COLOR_MAGENTA);
    if (!dir.mkpath(".")) {
      logFileOperation("saveJsonToFile", filePath, false,
                       "Failed to create directory");
      return false;
    }
  }

  QFile file(filePath);
  if (!file.open(QIODevice::WriteOnly)) {
    logFileOperation("saveJsonToFile", filePath, false,
                     "Failed to open file: " + file.errorString());
    return false;
  }

  QJsonDocument jsonDoc(jsonObject);
  QByteArray jsonData = jsonDoc.toJson();
  DEBUG_COLORED("FileService", "saveJsonToFile",
                QString("JSON data size: %1 bytes").arg(jsonData.size()),
                COLOR_MAGENTA, COLOR_MAGENTA);

  qint64 bytesWritten = file.write(jsonData);
  file.close();

  if (bytesWritten == -1) {
    logFileOperation("saveJsonToFile", filePath, false,
                     "Failed to write to file: " + file.errorString());
    return false;
  }

  logFileOperation("saveJsonToFile", filePath, true,
                   QString("Wrote %1 bytes").arg(bytesWritten));
  return true;
}

QJsonObject FileService::loadJsonFromFile(const QString &filePath) {
  DEBUG_COLORED("FileService", "loadJsonFromFile",
                QString("Attempting to load JSON from file: %1").arg(filePath),
                COLOR_MAGENTA, COLOR_MAGENTA);

  QFile file(filePath);
  if (!file.open(QIODevice::ReadOnly)) {
    logFileOperation("loadJsonFromFile", filePath, false,
                     "Failed to open file: " + file.errorString());
    return QJsonObject();
  }

  QByteArray jsonData = file.readAll();
  file.close();

  DEBUG_COLORED("FileService", "loadJsonFromFile",
                QString("Read %1 bytes from file").arg(jsonData.size()),
                COLOR_MAGENTA, COLOR_MAGENTA);

  QJsonParseError parseError;
  QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonData, &parseError);

  if (parseError.error != QJsonParseError::NoError) {
    logFileOperation("loadJsonFromFile", filePath, false,
                     QString("JSON parse error at offset %1: %2")
                         .arg(parseError.offset)
                         .arg(parseError.errorString()));
    return QJsonObject();
  }

  if (!jsonDoc.isObject()) {
    logFileOperation("loadJsonFromFile", filePath, false,
                     "Document is not a JSON object");
    return QJsonObject();
  }

  logFileOperation("loadJsonFromFile", filePath, true,
                   "Successfully parsed JSON object");
  return jsonDoc.object();
}

bool FileService::deleteFile(const QString &filePath) {
  DEBUG_COLORED("FileService", "deleteFile",
                QString("Attempting to delete file: %1").arg(filePath),
                COLOR_MAGENTA, COLOR_MAGENTA);

  QFile file(filePath);
  if (!file.exists()) {
    logFileOperation("deleteFile", filePath, false, "File doesn't exist");
    return false;
  }

  if (!file.remove()) {
    logFileOperation("deleteFile", filePath, false,
                     "Failed to delete file: " + file.errorString());
    return false;
  }

  logFileOperation("deleteFile", filePath, true, "File successfully deleted");
  return true;
}

bool FileService::fileExists(const QString &filePath) {
  bool exists = QFile::exists(filePath);
  DEBUG_COLORED(
      "FileService", "fileExists",
      QString("Check for file %1 result: %2").arg(filePath).arg(exists),
      COLOR_MAGENTA, COLOR_MAGENTA);
  return exists;
}

QString FileService::getFileSize(const QString &filePath) {
  QFileInfo fileInfo(filePath);
  if (!fileInfo.exists()) {
    logFileOperation("getFileSize", filePath, false, "File doesn't exist");
    return "0";
  }

  qint64 size = fileInfo.size();
  DEBUG_COLORED("FileService", "getFileSize",
                QString("File %1 size: %2 bytes").arg(filePath).arg(size),
                COLOR_MAGENTA, COLOR_MAGENTA);
  return QString::number(size);
}

void FileService::logFileOperation(const QString &operation,
                                   const QString &filePath, bool success,
                                   const QString &additionalInfo) {
  QString logMessage =
      QString("%1: %2").arg(success ? "Success" : "Failed").arg(filePath);

  if (!additionalInfo.isEmpty()) {
    logMessage += " | " + additionalInfo;
  }
  if (success)
    DEBUG_COLORED("FileService", operation, logMessage, COLOR_MAGENTA,
                  COLOR_MAGENTA);
  else
    DEBUG_ERROR_COLORED("FileService", operation, logMessage, COLOR_MAGENTA,
                        COLOR_MAGENTA);
}
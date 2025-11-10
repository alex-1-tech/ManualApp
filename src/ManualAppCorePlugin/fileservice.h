#pragma once

#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QObject>
#include <QStandardPaths>
#include <qtmetamacros.h>

class FileService : public QObject {
  Q_OBJECT
public:
  explicit FileService(QObject *parent = nullptr);
  ~FileService();

  bool saveJsonToFile(const QString &filePath,
                                  const QJsonObject &jsonObject);
  QJsonObject loadJsonFromFile(const QString &filePath);
  bool deleteFile(const QString &filePath);
  bool fileExists(const QString &filePath);
  QString getFileSize(const QString &filePath);

  QString getAppDataPath() const {
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
  };
  QString getDocumentsPath() const {
    return QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
  };
  QString getTempPath() {
    return QStandardPaths::writableLocation(QStandardPaths::TempLocation);
  };
  QString ensureAppDataDirectory();
  QString getFullFilePath(const QString &fileName);

private:
  void logFileOperation(const QString &operation, const QString &filePath,
                        bool success, const QString &additionalInfo = "");
};
#pragma once

#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QObject>
#include <qtmetamacros.h>

class FileService : public QObject {
  Q_OBJECT
public:
  explicit FileService(QObject *parent = nullptr);
  ~FileService();

  Q_INVOKABLE bool saveJsonToFile(const QString &filePath,
                                  const QJsonObject &jsonObject);
  Q_INVOKABLE QJsonObject loadJsonFromFile(const QString &filePath);
  Q_INVOKABLE bool deleteFile(const QString &filePath);
  Q_INVOKABLE bool fileExists(const QString &filePath);
  Q_INVOKABLE QString getFileSize(const QString &filePath);

private:
  void logFileOperation(const QString &operation, const QString &filePath,
                        bool success, const QString &additionalInfo = "");
};
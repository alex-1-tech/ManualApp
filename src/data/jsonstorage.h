#pragma once
#include <QString>
#include <QJsonDocument>

class JsonStorage {
public:
    static QJsonDocument load(const QString& filePath);
    static bool save(const QString& filePath, const QJsonDocument& doc);
};
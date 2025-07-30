#include "jsonstorage.h"
#include <QFile>
#include <QDebug>

QJsonDocument JsonStorage::load(const QString& filePath) {
    QFile f(filePath);
    if (!f.open(QIODevice::ReadOnly)) {
        qWarning() << "JsonStorage: cannot open" << filePath;
        if (!QFile::exists(filePath)) {
            qWarning() << "File does not exist";
        }
        return {};
    }
    return QJsonDocument::fromJson(f.readAll());
}

bool JsonStorage::save(const QString& filePath, const QJsonDocument& doc) {
    QFile f(filePath);
    if (!f.open(QIODevice::WriteOnly)) {
        qWarning() << "JsonStorage: cannot write to" << filePath;
        return false;
    }
    f.write(doc.toJson());
    return true;
}

#pragma once
#include <QString>

inline QString resolveResourcePath(const QString& filePath) {
    if (filePath.startsWith("qrc:/"))
        return ":" + filePath.mid(4);
    if (filePath.startsWith(":/"))
        return filePath;
    return ":/" + filePath;
}
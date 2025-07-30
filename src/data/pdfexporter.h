#pragma once

#include <QString>

class PdfExporter {
public:
    static bool exportToPdf(const QString& html, const QString& filePath);
};

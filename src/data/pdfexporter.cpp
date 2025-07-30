#include "pdfexporter.h"

#include <QPrinter>
#include <QTextDocument>
#include <QPageLayout>
#include <QPageSize>
#include <QMarginsF>
#include <QFileInfo>
#include <QDebug>

bool PdfExporter::exportToPdf(const QString& html, const QString& filePath)
{
    if (html.trimmed().isEmpty()) {
        qWarning() << "PdfExporter: Пустой HTML. PDF не создан.";
        return false;
    }

    QPrinter printer(QPrinter::HighResolution);
    printer.setOutputFormat(QPrinter::PdfFormat);
    printer.setOutputFileName(filePath);
    printer.setPageSize(QPageSize(QPageSize::A4));
    printer.setPageMargins(QMarginsF(10, 15, 10, 15), QPageLayout::Millimeter);

    QTextDocument document;
    document.setHtml(html);
    document.setTextWidth(printer.pageRect(QPrinter::Point).width());

    document.print(&printer);

    qDebug() << "PdfExporter: PDF успешно сохранен в" << QFileInfo(filePath).absoluteFilePath();
    return true;
}

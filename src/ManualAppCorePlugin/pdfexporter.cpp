#include "pdfexporter.h"
#include "utils.h"

#include <QDebug>
#include <QFileInfo>
#include <QMarginsF>
#include <QPageLayout>
#include <QPageSize>
#include <QPrinter>
#include <QTextDocument>
#include <qcontainerfwd.h>

bool PdfExporter::exportToPdf(const QString &html, const QString &filePath,
                              const QString &secondFilePath = QString()) {
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
  if (!secondFilePath.isEmpty()) {
    printer.setOutputFileName(secondFilePath);
    document.print(&printer);
    DEBUG_COLORED("PdfExporter", "exportToPdf",
                  QString("PDF успешно сохранен в %1")
                      .arg(QFileInfo(secondFilePath).absoluteFilePath()),
                  COLOR_CYAN, COLOR_CYAN);
  }
  DEBUG_COLORED("PdfExporter", "exportToPdf",
                QString("PDF успешно сохранен в %1")
                    .arg(QFileInfo(filePath).absoluteFilePath()),
                COLOR_CYAN, COLOR_CYAN);
  return true;
}

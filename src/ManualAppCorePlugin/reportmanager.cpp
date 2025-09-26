#include "reportmanager.h"
#include "fileservice.h"
#include "networkservice.h"
#include "pdfexporter.h"
#include "utils.h"

#include <JlCompress.h>
#include <QCoreApplication>
#include <QDateTime>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QRegularExpression>
#include <qcoreapplication.h>
#include <qfileinfo.h>
#include <qvariant.h>

ReportManager::ReportManager(FileService *fileService,
                             NetworkService *networkService, QObject *parent)
    : QObject(parent), m_fileService(fileService),
      m_networkService(networkService) {
  DEBUG_COLORED("ReportManager", "Constructor", "Constructor called",
                COLOR_GREEN, COLOR_GREEN);
  m_model.setSteps({});

  connect(m_networkService, &NetworkService::uploadFinished, this,
          [this](bool success, const QString &error) {
            if (!success) {
              setError(error);
            }
          });
}
QString ReportManager::getReportDirPath() const {
  return QCoreApplication::applicationDirPath() + "/../media/reports/";
}
QVariantMap ReportManager::performedTOs() const {
  QVariantMap result;

  const QString basePath = getReportDirPath();
  QDir baseDir(basePath);
  if (!baseDir.exists())
    return result;

  // Старая логика (поддержка старого формата)
  QFileInfoList toDirs =
      baseDir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot, QDir::Name);
  QRegularExpression toRe("^TO-.*", QRegularExpression::CaseInsensitiveOption);

  for (const QFileInfo &toInfo : toDirs) {
    const QString toName = toInfo.fileName();
    if (!toRe.match(toName).hasMatch())
      continue;

    QDir toDir(toInfo.absoluteFilePath());
    QFileInfoList dateDirs =
        toDir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot, QDir::Name);

    QList<QDate> dates;
    for (const QFileInfo &dateInfo : dateDirs) {
      QDate date = QDate::fromString(dateInfo.fileName(), "yyyy-MM-dd");
      if (!date.isValid())
        continue;

      QDir d(dateInfo.absoluteFilePath());
      if (!(d.exists("report.json") && d.exists("report.pdf")))
        continue;

      dates.append(date);
    }
    if (dates.isEmpty())
      continue;

    std::sort(dates.begin(), dates.end(), std::greater<QDate>());
    QVariantList dateList;
    for (const QDate &d : dates)
      dateList << d.toString("yyyy-MM-dd");

    result.insert(toName, dateList);
  }

  return result;
}

QVariantMap ReportManager::performedTOsNew() const {
  QVariantMap result;
  const QString basePath = getReportDirPath() + "TOs/";
  QDir dir(basePath);
  if (!dir.exists())
    return result;

  QRegularExpression fileRe(
      R"(^(\d{4}-\d{2}-\d{2})-(TO-\d+)\.pdf$)",
      QRegularExpression::CaseInsensitiveOption);

  QFileInfoList pdfFiles =
      dir.entryInfoList({"*.pdf"}, QDir::Files, QDir::Name);

  QMap<QString, QList<QDate>> grouped;
  for (const QFileInfo &file : pdfFiles) {
    auto match = fileRe.match(file.fileName());
    if (!match.hasMatch())
      continue;

    QDate date = QDate::fromString(match.captured(1), "yyyy-MM-dd");
    QString toKey = match.captured(2);
    if (!date.isValid())
      continue;

    grouped[toKey].append(date);
  }

  for (auto it = grouped.begin(); it != grouped.end(); ++it) {
    std::sort(it.value().begin(), it.value().end(), std::greater<QDate>());
    QVariantList dateList;
    for (const QDate &d : it.value())
      dateList << d.toString("yyyy-MM-dd");
    result.insert(it.key(), dateList);
  }

  return result;
}

QString ReportManager::findReportPdf(const QString &categoryKey,
                                     const QString &dateIso) const {
  const QString path = getReportDirPath() + "TOs/";
  QDir dir(path);
  if (!dir.exists())
    return QString();

  const QString fileName = QString("%1-%2.pdf").arg(dateIso, categoryKey);
  QFileInfo file(path + fileName);
  if (file.exists())
    return file.absoluteFilePath();

  return QString();
}


bool ReportManager::loadReport(const QString &filePath) {
  auto handleError = [this](const QString &msg) {
    DEBUG_ERROR_COLORED("ReportManager", "loadReport", msg, COLOR_RED,
                        COLOR_GREEN);
    setError(msg);
    return false;
  };

  DEBUG_COLORED("ReportManager", "loadReport",
                QString("Attempting to load file: %1").arg(filePath),
                COLOR_GREEN, COLOR_GREEN);
  const QString path = resolveResourcePath(filePath);
  DEBUG_COLORED("ReportManager", "loadReport",
                QString("Resolved path: %1").arg(path), COLOR_GREEN,
                COLOR_GREEN);

  if (!m_fileService->fileExists(path))
    return handleError(tr("File does not exist: %1").arg(path));

  DEBUG_COLORED("ReportManager", "loadReport", "Loading JSON from file...",
                COLOR_GREEN, COLOR_GREEN);
  QJsonObject json = m_fileService->loadJsonFromFile(path);
  if (json.isEmpty())
    return handleError(tr("Failed to load or parse JSON from: %1").arg(path));

  if (!json.contains("title") || !json["title"].isString())
    return handleError(tr("Invalid or missing 'title' field in JSON"));

  m_title = json["title"].toString();
  emit titleChanged();

  if (!json.contains("steps") || !json["steps"].isArray())
    return handleError(tr("Invalid or missing 'steps' array in JSON"));

  QList<Step> steps;
  const QJsonArray stepsArray = json["steps"].toArray();
  DEBUG_COLORED("ReportManager", "loadReport",
                QString("Found %1 steps").arg(stepsArray.size()), COLOR_GREEN,
                COLOR_GREEN);

  for (const QJsonValue &val : stepsArray)
    if (val.isObject())
      steps.push_back(Step::fromJson(val.toObject()));

  m_model.setSteps(steps);
  DEBUG_COLORED("ReportManager", "loadReport",
                QString("Successfully loaded %1 steps").arg(steps.size()),
                COLOR_GREEN, COLOR_GREEN);

  emit reportLoaded();
  DEBUG_COLORED("ReportManager", "loadReport", "Load completed successfully",
                COLOR_GREEN, COLOR_GREEN);
  return true;
}

void ReportManager::saveReportJson(const QString &path) {
  DEBUG_COLORED("ReportManager", "saveReportJson",
                QString("called with path: %1").arg(path), COLOR_GREEN,
                COLOR_GREEN);
  QJsonObject root;
  root["title"] = m_title;

  // Добавляем серийные номера
  if (m_settingsManager) {
    QJsonObject serials;
    serials["serial_number"] = m_settingsManager->serialNumber();
    root["serials"] = serials;
  }

  QJsonArray stepsArray;
  for (const Step &step : m_model.getSteps()) {
    stepsArray.append(step.toJson());
  }
  root["steps"] = stepsArray;

  if (!m_fileService->saveJsonToFile(path, root)) {
    setError(tr("Error saving to file: %1").arg(path));
    return;
  }

  DEBUG_COLORED("ReportManager", "saveReportJson",
                QString("JSON saved to: %1").arg(path), COLOR_GREEN,
                COLOR_GREEN);
}

void ReportManager::exportReportToPdf(const QString &path) {
  DEBUG_COLORED("ReportManager", "exportReportToPdf",
                QString("called with path: %1").arg(path), COLOR_GREEN,
                COLOR_GREEN);
  QString html;
  html += "<html><head><style>"
          "body { font-family: Arial; font-size: 12pt; }"
          "h1 { font-size: 18pt; }"
          "table { width: 100%; border-collapse: collapse; margin-top: 10pt; }"
          "th, td { border: 1px solid #444; padding: 6px; text-align: left; }"
          "th { background-color: #eee; }"
          ".defect-details { margin-left: 20px; font-size: 10pt; }"
          "</style></head><body>";

  html += QString("<h1>%1</h1>").arg(m_title);
  if (m_settingsManager) {
    html += "<div class='serials'>";
    html += QString("<div class='serial-item'><b>S/n:</b> %1</div>")
                .arg(m_settingsManager->serialNumber());
    html += "</div>";
  }

  html += QString("<p>Date: %1</p>")
              .arg(QDateTime::currentDateTime().toString("dd.MM.yyyy HH:mm"));

  html += "<table>"
          "<tr>"
          "<th>#</th>"
          "<th>Step</th>"
          "<th>Status</th>"
          "<th>Breakdown Details</th>"
          "</tr>";

  for (int i = 0; i < m_model.rowCount(); ++i) {
    const Step step = m_model.get(i);
    QString statusText;
    switch (step.completionStatus) {
    case Step::CompletionStatus::NotStarted:
      statusText = "Not Started";
      break;
    case Step::CompletionStatus::Completed:
      statusText = "Completed";
      break;
    case Step::CompletionStatus::HasDefect:
      statusText = "Has Breakdown";
      break;
    case Step::CompletionStatus::Skipped:
      statusText = "Skipped";
      break;
    }

    QString defectDetails;
    if (step.completionStatus == Step::CompletionStatus::HasDefect) {
      defectDetails = QString("<div class='defect-details'>"
                              "<p><b>Description:</b> %1</p>"
                              "<p><b>Repair Method:</b> %2</p>"
                              "<p><b>Status:</b> %3</p>"
                              "</div>")
                          .arg(step.defectDetails.description)
                          .arg(step.defectDetails.repairMethod)
                          .arg([&]() {
                            switch (step.defectDetails.fixStatus) {
                            case Step::DefectDetails::FixStatus::Fixed:
                              return "Fixed";
                            case Step::DefectDetails::FixStatus::Postponed:
                              return "Postponed";
                            case Step::DefectDetails::FixStatus::NotRequired:
                              return "Not Required";
                            case Step::DefectDetails::FixStatus::NotFixed:
                              return "Not Fixed";
                            default:
                              return "Unknown";
                            }
                          }());
    }

    html += QString("<tr>"
                    "<td>%1</td>"
                    "<td>%2</td>"
                    "<td>%3</td>"
                    "<td>%4</td>"
                    "</tr>")
                .arg(i + 1)
                .arg(step.title)
                .arg(statusText)
                .arg(defectDetails);
  }

  html += "</table></body></html>";
  QString stableSavePath = getReportDirPath() + "TOs/" + startTime() + "-" +
                           currentNumberTO() + ".pdf";
  if (!PdfExporter::exportToPdf(html, path, stableSavePath)) {
    setError(tr("PDF export error: %1 and %2").arg(path, stableSavePath));
    return;
  }
  DEBUG_COLORED(
      "ReportManager", "exportReportToPdf",
      QString("PDF successfully exported to: %1 %2").arg(path, stableSavePath),
      COLOR_GREEN, COLOR_GREEN);
}

void ReportManager::saveReport(bool firstSave) {
  DEBUG_COLORED("ReportManager", "saveReport",
                QString("called with firstSave: %1").arg(firstSave),
                COLOR_GREEN, COLOR_GREEN);
  const QString basePath = getReportDirPath() + m_numberTO + "/";
  DEBUG_COLORED("ReportManager", "saveReport",
                QString("path for save: %1").arg(basePath), COLOR_GREEN,
                COLOR_GREEN);
  QDir dir(basePath);

  if (!dir.exists() && !dir.mkpath(".")) {
    setError(tr("Failed to create directory: %1").arg(basePath));
    return;
  }

  const QString reportPath = basePath + m_startTime;
  dir.setPath(reportPath);

  if (!dir.exists() && !dir.mkpath(".")) {
    setError(tr("Failed to create directory: %1").arg(reportPath));
    return;
  }

  const QString json_path = dir.filePath("report.json");
  const QString pdf_path = dir.filePath("report.pdf");

  if (!firstSave) {
    saveReportJson(json_path);
    exportReportToPdf(pdf_path);
  }

  DEBUG_COLORED("ReportManager", "saveReport", "Report saved successfully",
                COLOR_GREEN, COLOR_GREEN);
}

void ReportManager::revokeReport() {
  DEBUG_COLORED("ReportManager", "revokeReport", "called", COLOR_GREEN,
                COLOR_GREEN);
  if (m_startTime.isEmpty()) {
    setError(tr("No test started - nothing to revoke"));
    return;
  }

  const QString basePath = getReportDirPath();
  const QString reportPath = basePath + currentNumberTO() + "/" + startTime();

  QDir reportDir(reportPath);
  if (!reportDir.exists()) {
    setError(tr("Report directory doesn't exist: %1").arg(reportPath));
    return;
  }

  bool success = removeDir(reportPath);

  if (success) {
    DEBUG_COLORED("ReportManager", "revokeReport",
                  QString("Successfully revoked report at: %1").arg(reportPath),
                  COLOR_GREEN, COLOR_GREEN);
    m_startTime = "";
    setError("");
    emit startTimeChanged();
  } else {
    setError(
        tr("Failed to completely remove report directory: %1").arg(reportPath));
  }
}

bool ReportManager::uploadReport(const QString &sourceFolderPath, bool after) {
  DEBUG_COLORED("ReportManager", "uploadReport",
                QString("called with sourceFolderPath: %1, after: %2")
                    .arg(sourceFolderPath)
                    .arg(after),
                COLOR_GREEN, COLOR_GREEN);

  if (sourceFolderPath.isEmpty()) {
    setError(tr("Source folder path is empty"));
    return false;
  }

  QDir sourceDir(sourceFolderPath);
  if (!sourceDir.exists()) {
    setError(tr("Source folder does not exist: %1").arg(sourceFolderPath));
    return false;
  }

  // Создаем базовый путь для сохранения
  const QString basePath = getReportDirPath();
  const QString timestamp =
      QDateTime::currentDateTime().toString("yyyy-MM-dd_HH-mm-ss");
  const QString destPath = after ? (basePath + timestamp + "/before_to/")
                                 : (basePath + timestamp + "/after_to/");

  QDir destDir(destPath);
  if (!destDir.mkpath(".")) {
    setError(tr("Failed to create destination directory: %1").arg(destPath));
    return false;
  }

  // Копируем все файлы из исходной папки
  bool allFilesCopied = true;
  QFileInfoList files =
      sourceDir.entryInfoList(QDir::Files | QDir::NoDotAndDotDot);

  for (const QFileInfo &fileInfo : files) {
    QString destFilePath = destPath + fileInfo.fileName();
    if (!QFile::copy(fileInfo.absoluteFilePath(), destFilePath)) {
      allFilesCopied = false;
      DEBUG_COLORED("ReportManager", "uploadReport",
                    QString("Failed to copy file: %1").arg(fileInfo.fileName()),
                    COLOR_RED, COLOR_GREEN);
    }
  }

  if (!allFilesCopied) {
    setError(tr("Failed to copy some files"));
    return false;
  }

  DEBUG_COLORED("ReportManager", "uploadReport",
                QString("Report uploaded successfully to: %1").arg(destPath),
                COLOR_GREEN, COLOR_GREEN);
  return true;
}

bool ReportManager::createArchive(const QString &folderPath,
                                  const QString &mode) {
  DEBUG_COLORED(
      "ReportManager", "createArchive",
      QString("called with folderPath: %1, mode: %2").arg(folderPath).arg(mode),
      COLOR_GREEN, COLOR_GREEN);

  QDir sourceDir(folderPath);
  if (!sourceDir.exists()) {
    setError("Папка не существует: " + folderPath);
    return false;
  }

  const qint64 MAX_SIZE = 100 * 1024 * 1024;
  qint64 folderSize = getDirSize(folderPath);
  if (folderSize > MAX_SIZE) {
    setError(QString("Размер папки превышает 100 МБ: %1 МБ")
                 .arg(folderSize / (1024 * 1024)));
    return false;
  }

  const QString basePath = getReportDirPath() + m_numberTO + "/";
  const QString subDir = (mode == "before") ? "before_to" : "after_to";
  const QString destDirPath = basePath + startTime() + "/" + subDir + "/";

  QDir destDir(destDirPath);
  if (!destDir.mkpath(".")) {
    setError("Не удалось создать директорию: " + destDirPath);
    return false;
  }

  QString zipFileName = destDirPath + "rail_record.zip";
  if (!JlCompress::compressDir(zipFileName, folderPath)) {
    setError("Не удалось создать архив");
    return false;
  }

  DEBUG_COLORED("ReportManager", "createArchive",
                QString("Архив успешно создан: %1").arg(zipFileName),
                COLOR_GREEN, COLOR_GREEN);
  return true;
}

qint64 ReportManager::getDirSize(const QString &path) {
  qint64 size = 0;
  QDir dir(path);
  QFileInfoList list =
      dir.entryInfoList(QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot);
  for (const QFileInfo &fi : list) {
    if (fi.isDir()) {
      size += getDirSize(fi.absoluteFilePath());
    } else {
      size += fi.size();
    }
  }
  return size;
}

void ReportManager::setStartTime(const QString &time) {
  if (m_startTime != time) {
    DEBUG_COLORED(
        "ReportManager", "setStartTime",
        QString("Changing start time from %1 to %2").arg(m_startTime).arg(time),
        COLOR_GREEN, COLOR_GREEN);
    m_startTime = time;
    emit startTimeChanged();
  }
}

void ReportManager::setCurrentNumberTO(const QString &numberTO) {
  if (m_numberTO != numberTO) {
    DEBUG_COLORED("ReportManager", "setCurrentNumberTO",
                  QString("Changing number TO from %1 to %2")
                      .arg(m_numberTO)
                      .arg(numberTO),
                  COLOR_GREEN, COLOR_GREEN);
    m_numberTO = numberTO;
    emit numberTOChanged();
  }
}

void ReportManager::setSettingsManager(SettingsManager *manager) {
  DEBUG_COLORED("ReportManager", "setSettingsManager", "called", COLOR_GREEN,
                COLOR_GREEN);
  if (m_settingsManager != manager) {
    m_settingsManager = manager;
    emit settingsManagerChanged();
  }
}

bool ReportManager::removeDir(const QString &dirPath) {
  QDir dir(dirPath);
  if (!dir.exists()) {
    return true;
  }

  for (const QFileInfo &info :
       dir.entryInfoList(QDir::NoDotAndDotDot | QDir::Files | QDir::Dirs)) {
    if (info.isDir()) {
      if (!removeDir(info.absoluteFilePath())) {
        return false;
      }
    } else {
      if (!QFile::remove(info.absoluteFilePath())) {
        DEBUG_ERROR_COLORED(
            "ReportManager", "removeDir",
            QString("Failed to remove file: %1").arg(info.absoluteFilePath()),
            COLOR_RED, COLOR_GREEN);
        return false;
      }
    }
  }

  return dir.rmdir(dirPath);
}

void ReportManager::setError(const QString &error) {
  if (!error.isEmpty())
    DEBUG_ERROR_COLORED("ReportManager", "error", error, COLOR_RED,
                        COLOR_GREEN);
  emit errorOccurred(error);
}
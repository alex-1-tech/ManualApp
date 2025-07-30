#include "datamanager.h"
#include "jsonstorage.h"
#include "pdfexporter.h"
#include "utils.h"

#include <QCoreApplication>
#include <QDateTime>
#include <QDebug>
#include <QDir>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

DataManager::DataManager(QObject *parent) : QObject(parent) {
  m_model.setSteps({});
}

void DataManager::setDefectDetails(int index, const QString &description,
                                   const QString &repairMethod,
                                   Step::DefectDetails::FixStatus status) {
  if (index >= 0 && index < m_model.rowCount()) {
    Step step = m_model.get(index);
    step.completionStatus = Step::CompletionStatus::HasDefect;
    step.defectDetails = {description, repairMethod, status};
    m_model.updateStep(index, step);
  }
}
SettingsManager *DataManager::settingsManager() const {
  return m_settingsManager;
}

void DataManager::setSettingsManager(SettingsManager *manager) {
  if (m_settingsManager != manager) {
    m_settingsManager = manager;
    emit settingsManagerChanged();
  }
}
void DataManager::setStepStatus(int index, Step::CompletionStatus status) {
  if (index >= 0 && index < m_model.rowCount()) {
    m_model.setStepStatus(index, status);
  }
}
void DataManager::revoke() {
  if (m_startTime.isNull()) {
    setError(tr("No test started - nothing to revoke"));
    return;
  }

  const QString basePath =
      QCoreApplication::applicationDirPath() + "/../media/reports/";
  const QString reportPath = basePath + startTime();

  QDir reportDir(reportPath);
  if (!reportDir.exists()) {
    setError(tr("Report directory doesn't exist: %1").arg(reportPath));
    return;
  }

  bool allFilesRemoved = true;
  const QFileInfoList files =
      reportDir.entryInfoList(QDir::NoDotAndDotDot | QDir::Files);
  for (const QFileInfo &file : files) {
    if (!QFile::remove(file.absoluteFilePath())) {
      allFilesRemoved = false;
      qWarning() << "Failed to remove file:" << file.absoluteFilePath();
    }
  }

  if (allFilesRemoved) {
    if (!reportDir.rmdir(reportPath)) {
      setError(tr("Failed to remove report directory: %1").arg(reportPath));
      return;
    }
    qDebug() << "Successfully revoked report at:" << reportPath;
  } else {
    setError(tr("Failed to remove some files in report directory: %1")
                 .arg(reportPath));
    return;
  }

  m_startTime = "";
  emit startTimeChanged();
}
bool DataManager::uploadReport(const QString &sourceFolderPath, bool after=false) {
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
    const QString basePath = QCoreApplication::applicationDirPath() + "/../media/reports/";
    const QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd_HH-mm-ss");
    const QString destPath = after ? (basePath + timestamp + "/before_to/")
                              : (basePath + timestamp + "/after_to/");
    QDir destDir(destPath);
    if (!destDir.mkpath(".")) {
        setError(tr("Failed to create destination directory: %1").arg(destPath));
        return false;
    }

    // Копируем все файлы из исходной папки
    bool allFilesCopied = true;
    QFileInfoList files = sourceDir.entryInfoList(QDir::Files | QDir::NoDotAndDotDot);
    
    for (const QFileInfo &fileInfo : files) {
        QString destFilePath = destPath + fileInfo.fileName();
        if (!QFile::copy(fileInfo.absoluteFilePath(), destFilePath)) {
            allFilesCopied = false;
            qWarning() << "Failed to copy file:" << fileInfo.fileName();
        }
    }

    if (!allFilesCopied) {
        setError(tr("Failed to copy some files"));
        return false;
    }

    return true;
}
void DataManager::save(const bool first_save) {
  const QString basePath =
      QCoreApplication::applicationDirPath() + "/../media/reports/";
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
  if (!first_save) {
    saveJson(json_path);
    exportPdf(pdf_path);
  }
}
bool DataManager::load(const QString &filePath) {
  setLoading(true);
  const QString path = resolveResourcePath(filePath);

  QJsonDocument doc = JsonStorage::load(path);
  if (doc.isNull()) {
    setError(tr("Failed to load JSON from: %1").arg(path));
    setLoading(false);
    return false;
  }

  const QJsonObject root = doc.object();
  m_title = root["title"].toString();
  emit titleChanged();

  QList<Step> steps;
  const QJsonArray stepsArray = root["steps"].toArray();
  for (const QJsonValue &val : stepsArray) {
    if (val.isObject()) {
      steps.push_back(Step::fromJson(val.toObject()));
    }
  }

  m_model.setSteps(steps);
  setLoading(false);
  emit dataLoaded();
  return true;
}

void DataManager::saveJson(const QString &path) {
  QJsonObject root;
  root["title"] = m_title;

  // Добавляем серийные номера
  if (m_settingsManager) {
    QJsonObject serials;
    serials["machine"] = m_settingsManager->machineSerial();
    serials["tablet"] = m_settingsManager->tabletSerial();
    serials["evb"] = m_settingsManager->evbSerial();
    root["serials"] = serials;
  }

  QJsonArray stepsArray;
  for (const Step &step : m_model.getSteps()) {
    stepsArray.append(step.toJson());
  }
  root["steps"] = stepsArray;

  if (!JsonStorage::save(path, QJsonDocument(root))) {
    setError(tr("Error saving to file: %1").arg(path));
    return;
  }

  qDebug() << "JSON saved to:" << path;
}
void DataManager::exportPdf(const QString &path) {
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
    html += "<h3>Serial Numbers:</h3>";
    html += QString("<div class='serial-item'><b>Machine:</b> %1</div>")
                .arg(m_settingsManager->machineSerial());
    html += QString("<div class='serial-item'><b>Tablet:</b> %1</div>")
                .arg(m_settingsManager->tabletSerial());
    html += QString("<div class='serial-item'><b>EVB:</b> %1</div>")
                .arg(m_settingsManager->evbSerial());
    html += "</div>";
  }

  html += QString("<p>Date: %1</p>")
              .arg(QDateTime::currentDateTime().toString("dd.MM.yyyy HH:mm"));

  html += "<table>"
          "<tr>"
          "<th>#</th>"
          "<th>Step</th>"
          "<th>Status</th>"
          "<th>Defect Details</th>"
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
      statusText = "Has Defect";
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

  if (!PdfExporter::exportToPdf(html, path)) {
    setError(tr("PDF export error: %1").arg(path));
    return;
  }
}

QStringList DataManager::getFixStatusOptions() const {
  return {"Fixed", "Postponed", "Not Required", "Not Fixed"};
}

#include "datamanager.h"
#include "fileservice.h"
#include "networkservice.h"
#include "reportmanager.h"
#include "settingsmanager.h"
#include "utils.h"

#include <QCoreApplication>
#include <QDebug>
#include <QDir>
#include <QJsonArray>
#include <QJsonObject>
#include <QTimer>

DataManager::DataManager(QObject *parent) : QObject(parent) {

  FileService *fileService = new FileService(this);
  NetworkService *networkService =
      new NetworkService(fileService, nullptr, this);
  m_reportManager = new ReportManager(fileService, networkService, this);
  networkService->setReportManager(m_reportManager);

  DEBUG_COLORED("DataManager", "Constructor", "DataManager initialized",
                COLOR_CYAN, COLOR_CYAN);

  // Проксируем сигналы от ReportManager
  connect(m_reportManager->networkService(), &NetworkService::errorOccurred,
          this, &DataManager::setError);
  connect(m_reportManager, &ReportManager::titleChanged, this,
          &DataManager::titleChanged);
  connect(m_reportManager, &ReportManager::startTimeChanged, this,
          &DataManager::startTimeChanged);
  connect(m_reportManager, &ReportManager::settingsManagerChanged, this,
          &DataManager::settingsManagerChanged);
  connect(m_reportManager, &ReportManager::reportLoaded, this,
          &DataManager::dataLoaded);
  connect(m_reportManager, &ReportManager::errorOccurred, this,
          [this](const QString &error) { setError(error); });

  connect(m_reportManager->networkService(), &NetworkService::uploadFinished,
          this, [this](bool success, const QString &error) {
            setLoading(false);
            if (!success) {
              setError(error);
            }
          });
}

QString DataManager::title() const { return m_reportManager->title(); }

QString DataManager::startTime() const { return m_reportManager->startTime(); }

void DataManager::setStartTime(const QString &time) {
  m_reportManager->setStartTime(time);
}
void DataManager::setCurrentNumberTO(const QString &numberTO) {
  m_reportManager->setCurrentNumberTO(numberTO);
}
QString DataManager::currentNumberTO() {
  return m_reportManager->currentNumberTO();
}
StepModel *DataManager::stepsModel() { return m_reportManager->stepsModel(); }

SettingsManager *DataManager::settingsManager() const {
  return m_reportManager->settingsManager();
}

void DataManager::setSettingsManager(SettingsManager *manager) {
  m_reportManager->setSettingsManager(manager);
}

bool DataManager::load(const QString &filePath) {
  DEBUG_COLORED("DataManager", "load",
                QString("Loading file: %1").arg(filePath), COLOR_CYAN,
                COLOR_CYAN);
  setLoading(true);
  setError("");
  bool result = m_reportManager->loadReport(filePath);
  setLoading(false);
  return result;
}

void DataManager::saveJson(const QString &path) {
  DEBUG_COLORED("DataManager", "saveJson",
                QString("Saving JSON to: %1").arg(path), COLOR_CYAN,
                COLOR_CYAN);
  m_reportManager->saveReportJson(path);
}

void DataManager::exportPdf(const QString &path) {
  DEBUG_COLORED("DataManager", "exportPdf",
                QString("Exporting PDF to: %1").arg(path), COLOR_CYAN,
                COLOR_CYAN);
  m_reportManager->exportReportToPdf(path);
}

void DataManager::save(const bool first_save) {
  DEBUG_COLORED("DataManager", "save",
                QString("Saving report, first save: %1").arg(first_save),
                COLOR_CYAN, COLOR_CYAN);
  m_reportManager->saveReport(first_save);
}

void DataManager::revoke() {
  DEBUG_COLORED("DataManager", "revoke", "Revoking report", COLOR_CYAN,
                COLOR_CYAN);
  m_reportManager->revokeReport();
}

bool DataManager::uploadReport(const QString &sourceFolderPath, bool after) {
  DEBUG_COLORED("DataManager", "uploadReport",
                QString("Uploading report from: %1, after: %2")
                    .arg(sourceFolderPath)
                    .arg(after),
                COLOR_CYAN, COLOR_CYAN);
  setLoading(true);
  bool result = m_reportManager->uploadReport(sourceFolderPath, after);
  setLoading(false);
  return result;
}

void DataManager::setStepStatus(int index, Step::CompletionStatus status) {
  DEBUG_COLORED("DataManager", "setStepStatus",
                QString("Setting status for step: %1").arg(index), COLOR_CYAN,
                COLOR_CYAN);
  m_reportManager->stepsModel()->setStepStatus(index, status);
  emit stepUpdated(index);
}

void DataManager::setDefectDetails(int index, const QString &description,
                                   const QString &repairMethod,
                                   Step::DefectDetails::FixStatus fixStatus) {
  DEBUG_COLORED("DataManager", "setDefectDetails",
                QString("Setting defect details for step: %1").arg(index),
                COLOR_CYAN, COLOR_CYAN);
  if (index >= 0 && index < m_reportManager->stepsModel()->rowCount()) {
    Step step = m_reportManager->stepsModel()->get(index);
    step.completionStatus = Step::CompletionStatus::HasDefect;
    step.defectDetails = {description, repairMethod, fixStatus};
    m_reportManager->stepsModel()->updateStep(index, step);
    emit stepUpdated(index);
  }
}

QString DataManager::createSettingsJsonFile(const QString &filePath) {
  DEBUG_COLORED("DataManager", "createSettingsJsonFile",
                QString("Creating settings JSON at: %1").arg(filePath),
                COLOR_CYAN, COLOR_CYAN);
  if (!m_reportManager->settingsManager()) {
    setError("SettingsManager не инициализирован");
    return QString();
  }
  return m_reportManager->fileService()->saveJsonToFile(
             filePath, m_reportManager->settingsManager()->toJsonForDjango())
             ? filePath
             : QString();
}

bool DataManager::deleteSettingsJsonFile(const QString &filePath) {
  DEBUG_COLORED("DataManager", "deleteSettingsJsonFile",
                QString("Deleting file: %1").arg(filePath), COLOR_CYAN,
                COLOR_CYAN);
  return m_reportManager->fileService()->deleteFile(filePath);
}
void DataManager::setCurrentSettings(const QUrl &apiUrl) {
  DEBUG_COLORED("DataManager", "setCurrentSettings",
                QString("Download settings from %1").arg(apiUrl.toString()),
                COLOR_CYAN, COLOR_CYAN);

  if (!apiUrl.isValid() || apiUrl.scheme().isEmpty()) {
    setError("Invalid API URL: must include http:// or https://");
    return;
  }

  setLoading(true);
  setError("");

  m_reportManager->networkService()->getJsonFromDjango(
      apiUrl,
      [this](const QJsonObject &json) {
        if (json.isEmpty()) {
          setError("Received empty settings JSON.");
          setLoading(false);
          return;
        }

        QJsonObject settingsObj = json;
        if (json.contains("settings") && json["settings"].isObject()) {
          settingsObj = json["settings"].toObject();
        }
        m_reportManager->settingsManager()->fromJson(settingsObj);

        DEBUG_COLORED("DataManager", "setCurrentSettings",
                      "Settings successfully downloaded and applied",
                      COLOR_CYAN, COLOR_CYAN);

        setLoading(false);
      },
      [this](const QString &error) {
        DEBUG_ERROR_COLORED(
            "DataManager", "setCurrentSettings",
            QString("Failed to download settings: %1").arg(error), COLOR_CYAN,
            COLOR_CYAN);
        setError(error);
        setLoading(false);
      });
}

void DataManager::uploadSettingsToDjango(const QUrl &apiUrl) {
  DEBUG_COLORED("DataManager", "uploadSettingsToDjango",
                QString("Uploading settings to %1").arg(apiUrl.toString()),
                COLOR_CYAN, COLOR_CYAN);

  if (!apiUrl.isValid() || apiUrl.scheme().isEmpty()) {
    setError("Invalid API URL: must include http:// or https://");
    return;
  }

  if (!m_reportManager->settingsManager()) {
    setError("SettingsManager не инициализирован");
    return;
  }
  QJsonObject json = m_reportManager->settingsManager()->toJsonForDjango();
  if (json.isEmpty()) {
    setError("Failed to load JSON settings.");
    return;
  }

  setLoading(true);
  qDebug() << json;
  m_reportManager->networkService()->uploadJsonToDjango(apiUrl, json);
}
QString DataManager::getReportDirPath() const {
  return m_reportManager->getReportDirPath();
}
void DataManager::uploadReportToDjango(const QUrl &apiUrl) {
  const QString basePath =
      getReportDirPath() + m_reportManager->currentNumberTO() + "/";
  const QString filePath = basePath + startTime();
  DEBUG_COLORED("DataManager", "uploadReportToDjango",
                QString("Uploading report from: %1 to: %2")
                    .arg(filePath)
                    .arg(apiUrl.toString()),
                COLOR_CYAN, COLOR_CYAN);
  setLoading(true);
  m_reportManager->networkService()->uploadReport(apiUrl, filePath);
}

void DataManager::syncReportsWithServer() {
  DEBUG_COLORED("DataManager", "syncReportsWithServer", "Starts sync",
                COLOR_CYAN, COLOR_CYAN);
  QString serialNumber = m_reportManager->settingsManager()->serialNumber();
  if (serialNumber.isEmpty()) {
    DEBUG_ERROR_COLORED("DataManager", "syncReportsWithServer",
                        "Serial number doesn`t exist", COLOR_CYAN, COLOR_CYAN);
    return;
  }

  QUrl apiUrl(QString(djangoBaseUrl() +
                      "/api/kalmar32/%1/get_reports")
                  .arg(serialNumber));

  setLoading(true);
  m_reportManager->networkService()->getJsonFromDjango(
      apiUrl,
      [this, serialNumber](const QJsonObject &json) {
        processServerReports(json, serialNumber);
        setLoading(false);
      },
      [this](const QString &error) {
        DEBUG_ERROR_COLORED("DataManager", "syncReportsWithServer",
                            "Error when receiving data: " + error, COLOR_CYAN,
                            COLOR_CYAN);
        setLoading(false);
      });
}

void DataManager::processServerReports(const QJsonObject &serverReports,
                                       const QString &serialNumber) {
  QString basePath = getReportDirPath();

  m_pendingReports.clear();

  QDate oneMonthAgo = QDate::currentDate().addMonths(-1).addDays(-1);

  for (auto const &number_to : numbersTO) {
    QString toPath = basePath + number_to + "/";
    QDir reportDir(toPath);

    if (!reportDir.exists()) {
      continue;
    }

    QStringList localReports =
        reportDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
    QJsonArray onlineReports = serverReports[number_to].toArray();

    QMap<QString, QJsonObject> onlineReportMap;

    for (const auto &val : onlineReports) {
      if (val.isObject()) {
        QJsonObject reportObj = val.toObject();
        QString date = reportObj["date"].toString();
        onlineReportMap[date] = reportObj;
      }
    }

    for (const auto &localReport : localReports) {
      QDate reportDate = QDate::fromString(localReport, "yyyy-MM-dd");
      QString fullReportPath = toPath + localReport;
      QDir reportDir(fullReportPath);
      if (reportDir.isEmpty()) {
        if (reportDir.removeRecursively()) {
          DEBUG_COLORED("DataManager", "processServerReports",
                        QString("Deleted empty old report: %1/%2")
                            .arg(number_to)
                            .arg(localReport),
                        COLOR_CYAN, COLOR_CYAN);
          continue;
        } else {
          DEBUG_ERROR_COLORED(
              "DataManager", "processServerReports",
              QString("Failed to delete empty old report: %1/%2")
                  .arg(number_to)
                  .arg(localReport),
              COLOR_CYAN, COLOR_CYAN);
        }
      }
      if (reportDate.isValid() && reportDate < oneMonthAgo) {
        if (QDir(fullReportPath).removeRecursively()) {
          DEBUG_COLORED("DataManager", "processServerReports",
                        QString("Deleted old report: %1/%2")
                            .arg(number_to)
                            .arg(localReport),
                        COLOR_CYAN, COLOR_CYAN);
        } else {
          DEBUG_ERROR_COLORED("DataManager", "processServerReports",
                              QString("Failed to delete old report: %1/%2")
                                  .arg(number_to)
                                  .arg(localReport),
                              COLOR_CYAN, COLOR_CYAN);
        }
        continue;
      }
      if (onlineReportMap.contains(localReport)) {

        QJsonObject serverReport = onlineReportMap[localReport];
        bool jsonExists = serverReport["json"].toBool();
        bool pdfExists = serverReport["pdf"].toBool();

        if (!jsonExists || !pdfExists) {
          m_pendingReports.enqueue(
              {toPath + localReport + '/', localReport, number_to});
        }
      } else {
        m_pendingReports.enqueue(
            {toPath + localReport + '/', localReport, number_to});
      }
    }
  }

  DEBUG_COLORED(
      "DataManager", "processServerReports",
      QString("Found %1 reports to upload").arg(m_pendingReports.size()),
      COLOR_CYAN, COLOR_CYAN);

  if (!m_pendingReports.isEmpty()) {
    startNextUpload();
  } else {
    m_isUploading = false;
    DEBUG_COLORED("DataManager", "processServerReports", "No reports to upload",
                  COLOR_CYAN, COLOR_CYAN);
  }
}

void DataManager::startNextUpload() {
  if (m_pendingReports.isEmpty()) {
    m_isUploading = false;
    DEBUG_COLORED("DataManager", "startNextUpload",
                  "All reports uploaded successfully", COLOR_CYAN, COLOR_CYAN);
    emit allReportsUploaded();
    return;
  }

  m_isUploading = true;
  QList nextReportList = m_pendingReports.dequeue();

  QString apiUrl = djangoBaseUrl() + "/api/report/";

  DEBUG_COLORED("DataManager", "startNextUpload",
                QString("Starting upload of report: %1, remaining: %2")
                    .arg(nextReportList[0])
                    .arg(m_pendingReports.size()),
                COLOR_CYAN, COLOR_CYAN);

  disconnect(m_reportManager->networkService(), &NetworkService::uploadFinished,
             this, &DataManager::handleSingleReportUploadFinished);

  connect(m_reportManager->networkService(), &NetworkService::uploadFinished,
          this, &DataManager::handleSingleReportUploadFinished,
          Qt::UniqueConnection);

  m_reportManager->networkService()->uploadReport(
      QUrl(apiUrl), nextReportList[0], nextReportList[1], nextReportList[2]);
}

void DataManager::handleSingleReportUploadFinished(bool success,
                                                   const QString &error) {
  DEBUG_COLORED("DataManager", "handleSingleReportUploadFinished",
                QString("Report upload finished: success=%1, error=%2")
                    .arg(success)
                    .arg(error),
                COLOR_CYAN, COLOR_CYAN);

  if (!success) {
    DEBUG_ERROR_COLORED("DataManager", "handleSingleReportUploadFinished",
                        "Upload error: " + error, COLOR_CYAN, COLOR_CYAN);
  }

  if (m_reportManager->networkService()->isUploadingReport()) {
    DEBUG_COLORED("DataManager", "handleSingleReportUploadFinished",
                  "Report still uploading, ignoring intermediate step",
                  COLOR_CYAN, COLOR_CYAN);
    return;
  }

  QTimer::singleShot(400, this, [this]() {
    DEBUG_COLORED("DataManager", "handleSingleReportUploadFinished",
                  "Starting next upload after delay", COLOR_CYAN, COLOR_CYAN);
    startNextUpload();
  });
}

QStringList DataManager::getFixStatusOptions() const {
  DEBUG_COLORED("DataManager", "getFixStatusOptions",
                "Getting fix status options", COLOR_CYAN, COLOR_CYAN);
  return {"Fixed", "Postponed", "Not Required", "Not Fixed"};
}

bool DataManager::createArchive(const QString &folderPath,
                                const QString &mode) {
  DEBUG_COLORED(
      "DataManager", "createArchive",
      QString("Creating archive from: %1 mode: %2").arg(folderPath).arg(mode),
      COLOR_CYAN, COLOR_CYAN);
  return m_reportManager->createArchive(folderPath, mode);
}

void DataManager::setLoading(bool loading) {
  if (m_loading != loading) {
    m_loading = loading;
    emit loadingChanged();
  }
}

void DataManager::setError(const QString &error) {
  m_error = error;
  emit errorOccurred(error);
}
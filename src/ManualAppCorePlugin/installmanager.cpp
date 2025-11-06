#include "installmanager.h"
#include "utils.h"
#include <QCoreApplication>

InstallManager::InstallManager(QObject *parent) 
    : QObject(parent)
    , m_statusMessage("Ready to install")
    , m_isInstalling(false)
    , m_process(nullptr)
    , m_timeoutTimer(nullptr)
{
    DEBUG_COLORED("InstallManager", "Constructor", "InstallManager initialized", COLOR_CYAN, COLOR_CYAN);
}

InstallManager::~InstallManager() {
    cleanupProcess();
}

QString InstallManager::buildInstallerPath(const QString &model) const {
    QString basePath = QCoreApplication::applicationDirPath();
    QString installerName;
    
    if (model.toLower() == "kalmar32") {
        installerName = "/media/apps/Kalmar.exe";
    } else if (model.toLower() == "phasar32") {
        installerName = "/media/apps/Phasar.exe";
    } else {
        DEBUG_ERROR_COLORED("InstallManager", "buildInstallerPath", 
                           QString("Unknown model: %1").arg(model), COLOR_CYAN, COLOR_CYAN);
        return QString();
    }
    
    return basePath + installerName;
}

bool InstallManager::installerExists(const QString &model) const {
    QString path = buildInstallerPath(model);
    if (path.isEmpty()) {
        return false;
    }
    
    bool exists = QFile::exists(path);
    DEBUG_COLORED("InstallManager", "installerExists", 
                 QString("Installer %1 exists: %2").arg(path).arg(exists), COLOR_CYAN, COLOR_CYAN);
    
    return exists;
}

void InstallManager::runInstaller(const QString &model) {
    DEBUG_COLORED("InstallManager", "runInstaller", 
                 QString("Starting installer for model: %1").arg(model), COLOR_CYAN, COLOR_CYAN);
    
    if (m_isInstalling) {
        DEBUG_COLORED("InstallManager", "runInstaller", "Installation already in progress", COLOR_CYAN, COLOR_CYAN);
        return;
    }
    
    // Build installer path
    QString path = buildInstallerPath(model);
    if (path.isEmpty()) {
        setStatusMessage("Error: Unknown device model");
        return;
    }
    
    // Check if installer exists
    if (!QFile::exists(path)) {
        DEBUG_ERROR_COLORED("InstallManager", "runInstaller", 
                           QString("Installer not found: %1").arg(path), COLOR_CYAN, COLOR_CYAN);
        setStatusMessage(QString("Installer not found: %1").arg(path));
        emit errorOccurred(QString("Installer not found: %1").arg(path));
        return;
    }
    
    setInstallerPath(path);
    setIsInstalling(true);
    setStatusMessage("Starting installation...");
    
    try {
        cleanupProcess();
        
        m_process = new QProcess(this);
        m_timeoutTimer = new QTimer(this);
        
        // Подключаем сигналы
        connect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
                this, &InstallManager::onProcessFinished);
        connect(m_process, &QProcess::errorOccurred,
                this, &InstallManager::onProcessErrorOccurred);
        connect(m_timeoutTimer, &QTimer::timeout,
                this, &InstallManager::onTimeout);
        
        QFileInfo fileInfo(path);
        m_process->setWorkingDirectory(fileInfo.path());
        
        setStatusMessage("Running installer...");
        
        // ЗАМЕНИТЕ ЭТУ СТРОКУ:
        // bool started = QProcess::startDetached(path, QStringList(), fileInfo.path());
        
        // НА ЭТО:
        m_process->start(path, QStringList());
        bool started = m_process->waitForStarted(5000); // ждем 5 секунд для запуска
        
        if (started) {
            DEBUG_COLORED("InstallManager", "runInstaller", "Installer started successfully", COLOR_CYAN, COLOR_CYAN);
            setStatusMessage("Installer started! Please follow the installation steps.");
            emit installationStarted();
            
            m_timeoutTimer->start(30000);
        } else {
            DEBUG_ERROR_COLORED("InstallManager", "runInstaller", 
                               "Failed to start installer process", COLOR_CYAN, COLOR_CYAN);
            setStatusMessage("Failed to start installer. Please run manually.");
            emit errorOccurred("Failed to start installer process");
            cleanupProcess();
            setIsInstalling(false);
        }
        
    } catch (const std::exception &e) {
        DEBUG_ERROR_COLORED("InstallManager", "runInstaller", 
                           QString("Exception: %1").arg(e.what()), COLOR_CYAN, COLOR_CYAN);
        setStatusMessage(QString("Error starting installer: %1").arg(e.what()));
        emit errorOccurred(QString("Exception: %1").arg(e.what()));
        cleanupProcess();
        setIsInstalling(false);
    }
}

void InstallManager::onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus) {
    DEBUG_COLORED("InstallManager", "onProcessFinished", 
                 QString("Process finished with exit code: %1, status: %2").arg(exitCode).arg(exitStatus), 
                 COLOR_CYAN, COLOR_CYAN);
    
    if (m_timeoutTimer && m_timeoutTimer->isActive()) {
        m_timeoutTimer->stop();
    }
    
    bool success = (exitStatus == QProcess::NormalExit && exitCode == 0);
    
    if (success) {
        setStatusMessage("Installation completed successfully!");
        DEBUG_COLORED("InstallManager", "onProcessFinished", "Installation completed successfully", COLOR_CYAN, COLOR_CYAN);
    } else {
        setStatusMessage(QString("Installation finished with exit code: %1").arg(exitCode));
        DEBUG_ERROR_COLORED("InstallManager", "onProcessFinished", 
                           QString("Installation failed with exit code: %1").arg(exitCode), COLOR_CYAN, COLOR_CYAN);
    }
    
    emit installationFinished(success);
    cleanupProcess();
    setIsInstalling(false);
}

void InstallManager::onProcessErrorOccurred(QProcess::ProcessError error) {
    DEBUG_ERROR_COLORED("InstallManager", "onProcessErrorOccurred", 
                       QString("Process error: %1").arg(error), COLOR_CYAN, COLOR_CYAN);
    
    if (m_timeoutTimer && m_timeoutTimer->isActive()) {
        m_timeoutTimer->stop();
    }
    
    QString errorMessage;
    switch (error) {
        case QProcess::FailedToStart:
            errorMessage = "Installer failed to start. File may be missing or permissions insufficient.";
            break;
        case QProcess::Crashed:
            errorMessage = "Installer crashed during execution.";
            break;
        case QProcess::Timedout:
            errorMessage = "Installer timed out.";
            break;
        case QProcess::WriteError:
            errorMessage = "Write error occurred with installer.";
            break;
        case QProcess::ReadError:
            errorMessage = "Read error occurred with installer.";
            break;
        default:
            errorMessage = "Unknown error occurred with installer.";
            break;
    }
    
    setStatusMessage(errorMessage);
    emit errorOccurred(errorMessage);
    cleanupProcess();
    setIsInstalling(false);
}

void InstallManager::onTimeout() {
    DEBUG_COLORED("InstallManager", "onTimeout", "Process timeout reached", COLOR_CYAN, COLOR_CYAN);
    
    if (m_process && m_process->state() == QProcess::Running) {
        DEBUG_COLORED("InstallManager", "onTimeout", "Terminating hung process", COLOR_CYAN, COLOR_CYAN);
        m_process->terminate();
        
        // Wait for termination
        if (!m_process->waitForFinished(5000)) {
            DEBUG_ERROR_COLORED("InstallManager", "onTimeout", "Process did not terminate, killing", COLOR_CYAN, COLOR_CYAN);
            m_process->kill();
        }
    }
    
    setStatusMessage("Installation timeout. Please check if installer started properly.");
    emit errorOccurred("Installation timeout");
    cleanupProcess();
    setIsInstalling(false);
}

void InstallManager::cleanupProcess() {
    if (m_process) {
        if (m_process->state() == QProcess::Running) {
            m_process->terminate();
            m_process->waitForFinished(1000);
        }
        m_process->deleteLater();
        m_process = nullptr;
    }
    
    if (m_timeoutTimer) {
        if (m_timeoutTimer->isActive()) {
            m_timeoutTimer->stop();
        }
        m_timeoutTimer->deleteLater();
        m_timeoutTimer = nullptr;
    }
}

void InstallManager::setStatusMessage(const QString &message) {
    if (m_statusMessage != message) {
        m_statusMessage = message;
        emit statusMessageChanged();
    }
}

void InstallManager::setIsInstalling(bool installing) {
    if (m_isInstalling != installing) {
        m_isInstalling = installing;
        emit isInstallingChanged();
    }
}

void InstallManager::setInstallerPath(const QString &path) {
    if (m_installerPath != path) {
        m_installerPath = path;
        emit installerPathChanged();
    }
}
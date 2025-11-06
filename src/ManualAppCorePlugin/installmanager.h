#pragma once

#include <QObject>
#include <QProcess>
#include <QTimer>
#include <QFile>
#include <QDir>
#include <QDebug>
#include <QQmlEngine>

class InstallManager : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)
    Q_PROPERTY(bool isInstalling READ isInstalling NOTIFY isInstallingChanged)
    Q_PROPERTY(QString installerPath READ installerPath NOTIFY installerPathChanged)

public:
    explicit InstallManager(QObject *parent = nullptr);
    ~InstallManager();

    // Q_INVOKABLE methods
    Q_INVOKABLE void runInstaller(const QString &model);
    Q_INVOKABLE bool installerExists(const QString &model) const;

    // Property getters
    QString statusMessage() const { return m_statusMessage; }
    bool isInstalling() const { return m_isInstalling; }
    QString installerPath() const { return m_installerPath; }

signals:
    void statusMessageChanged();
    void isInstallingChanged();
    void installerPathChanged();
    void installationStarted();
    void installationFinished(bool success);
    void errorOccurred(const QString &error);

private slots:
    void onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void onProcessErrorOccurred(QProcess::ProcessError error);
    void onTimeout();

private:
    void setStatusMessage(const QString &message);
    void setIsInstalling(bool installing);
    void setInstallerPath(const QString &path);
    QString buildInstallerPath(const QString &model) const;
    void cleanupProcess();

    // State
    QString m_statusMessage;
    bool m_isInstalling;
    QString m_installerPath;

    // Process management
    QProcess *m_process;
    QTimer *m_timeoutTimer;
};
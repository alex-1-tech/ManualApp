#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <qdebug.h>
#include "data/datamanager.h"
#include "data/settingsmanager.h"
#include "data/stepmodel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    SettingsManager* settingsManager = new SettingsManager(&app);
    DataManager* dataManager = new DataManager(&app);
    
    

    QQmlApplicationEngine engine;

    engine.addImportPath("qrc:/qml");
    engine.addImportPath("qrc:/");

    // engine.rootContext()->setContextProperty("settingsManager", settingsManager);
    // engine.rootContext()->setContextProperty("dataManager", dataManager);

    qmlRegisterSingletonInstance("ManualApp.Core", 1, 0, "DataManager", dataManager);
    qmlRegisterSingletonInstance("ManualApp.Core", 1, 0, "SettingsManager", settingsManager);
    qmlRegisterType<StepModel>("datamanager.Models", 1, 0, "StepModel");

    // qmlRegisterType<DataManager>("datamanager", 1, 0, "DataManager");
    

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { 
            qCritical() << "Failed to load QML file!";
            QCoreApplication::exit(-1); 
        },
        Qt::QueuedConnection
    );
    dataManager->setSettingsManager(settingsManager);
    engine.load(QUrl("qrc:/qml/Main.qml"));

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "No root objects loaded!";
        return -1;
    }

    return app.exec();
}
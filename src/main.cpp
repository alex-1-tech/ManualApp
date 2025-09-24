#include <QGuiApplication>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlEngine>
#include <qdebug.h>
#include <qurl.h>
#include <QDir>

int main(int argc, char *argv[])
{   

    QApplication app(argc, argv);
    QString appVersion = "1.0";
    qDebug() << "Qt version: " << qVersion();

    QQmlApplicationEngine engine;
    
    engine.addImportPath("qrc:/qml");
    engine.addImportPath(QDir::currentPath()+ "/src");
    qDebug() << "QML import paths:" << engine.importPathList();
    qDebug() << "App dir:" << QCoreApplication::applicationDirPath();
    engine.load(QUrl("qrc:/qml/Start.qml"));

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "No root objects loaded!";
        return -1;
    }

    return app.exec();
}
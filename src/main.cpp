#include <QApplication>
#include <QDir>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickStyle>
#include <qdebug.h>
#include <qurl.h>

int main(int argc, char *argv[]) {

  QApplication app(argc, argv);
  qDebug() << "Qt version: " << qVersion();
  // QQuickStyle::setStyle("Material");
  QQmlApplicationEngine engine;

  engine.addImportPath("qrc:/qml");
  engine.addImportPath(QDir::currentPath() + "/src");
  qDebug() << "QML import paths:" << engine.importPathList();
  qDebug() << "App dir:" << QCoreApplication::applicationDirPath();
  engine.load(QUrl("qrc:/qml/Start.qml"));

  if (engine.rootObjects().isEmpty()) {
    qCritical() << "No root objects loaded!";
    return -1;
  }

  return app.exec();
}

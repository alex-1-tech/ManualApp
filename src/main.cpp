#include <QApplication>
#include <QDir>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickStyle>
#include <QDebug>
#include <QUrl>
#include <QIcon>

int main(int argc, char *argv[]) {

  QApplication app(argc, argv);
  QQmlApplicationEngine engine;
  QQuickStyle::setStyle("Material");
  app.setWindowIcon(QIcon(":/media/icons/logo.png"));

  app.setOrganizationName("technovotum");
  app.setOrganizationDomain("votum.asuscomm.com");
  app.setApplicationName("ManualApp");

  engine.addImportPath("qrc:/qml");
  engine.addImportPath(QDir::currentPath() + "/src");
  engine.load(QUrl("qrc:/qml/Start.qml"));

  if (engine.rootObjects().isEmpty()) {
    qCritical() << "No root objects loaded!";
    return -1;
  }

  return app.exec();
}

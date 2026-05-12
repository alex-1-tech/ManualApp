#pragma once

#include <QCryptographicHash>
#include <QObject>
#include <QQmlEngine>

class AdminManager : public QObject
{
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

  Q_PROPERTY(bool adminMode READ adminMode NOTIFY adminModeChanged)

public:
  explicit AdminManager(QObject* parent = nullptr);

  static AdminManager* create(QQmlEngine*, QJSEngine*) { return new AdminManager(); }

  bool adminMode() const { return m_adminMode; };
  Q_INVOKABLE void registerClick();
  Q_INVOKABLE bool verifyPassword(const QString& password);
  Q_INVOKABLE void logout();

signals:
  void adminModeChanged();
  void showPasswordDialog();

private:
  void resetClicks();

private:
  int m_clickCount = 0;
  qint64 m_lastClickTime = 0;

  bool m_adminMode = false;

  const int REQUIRED_CLICKS = 5;
  const int CLICK_INTERVAL_MS = 500;

  QByteArray m_passwordHash;
};
#include "adminmanager.h"

#include <QDateTime>

AdminManager::AdminManager(QObject* parent)
    : QObject(parent)
{
  m_passwordHash = QCryptographicHash::hash("1234", QCryptographicHash::Sha256);
}

void AdminManager::registerClick()
{
  qint64 now = QDateTime::currentMSecsSinceEpoch();

  if (now - m_lastClickTime < CLICK_INTERVAL_MS) {
    m_clickCount++;
  } else {
    m_clickCount = 1;
  }

  m_lastClickTime = now;

  if (m_clickCount >= REQUIRED_CLICKS) {
    resetClicks();
    emit showPasswordDialog();
  }
}

bool AdminManager::verifyPassword(const QString& password)
{
  QByteArray hash = QCryptographicHash::hash(password.toUtf8(), QCryptographicHash::Sha256);

  if (hash == m_passwordHash) {
    m_adminMode = true;
    emit adminModeChanged();
    return true;
  }

  return false;
}

void AdminManager::logout()
{
  m_adminMode = false;
  emit adminModeChanged();
}

void AdminManager::resetClicks()
{
  m_clickCount = 0;
  m_lastClickTime = 0;
}
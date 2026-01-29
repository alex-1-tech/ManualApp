#pragma once
#include <QDebug>
#include <QString>

#define COLOR_RESET "\033[0m"
#define COLOR_RED "\033[31m"
#define COLOR_GREEN "\033[32m"
#define COLOR_YELLOW "\033[33m"
#define COLOR_BLUE "\033[34m"
#define COLOR_MAGENTA "\033[35m"
#define COLOR_CYAN "\033[36m"
#define COLOR_WHITE "\033[37m"

#define DEBUG_COLORED(module, action, message, colorModule, colorAction)                                     \
  qDebug().noquote() << (QString(colorModule) + "[" + module + "]" + colorAction + "[" + action + "] " +     \
                         COLOR_RESET + message)
#define DEBUG_ERROR_COLORED(module, action, message, colorModule, colorAction)                               \
  qWarning().noquote() << (QString(colorModule) + "[" + module + "]" + colorAction + "[" + action + "] " +   \
                           COLOR_RED + message + COLOR_RESET)

inline QString resolveResourcePath(const QString& filePath)
{
  if (filePath.startsWith("qrc:/")) return ":" + filePath.mid(4);
  if (filePath.startsWith(":/")) return filePath;
  return ":/" + filePath;
}

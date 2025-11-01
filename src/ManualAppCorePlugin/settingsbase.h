#pragma once
#include <QJsonObject>
#include <QObject>
#include <QSettings>

class SettingsBase : public QObject {
  Q_OBJECT
public:
  explicit SettingsBase(QObject *parent = nullptr) : QObject(parent) {}
  virtual ~SettingsBase() = default;

  virtual void loadFromSettings(QSettings &settings,
                                const QString &prefix = "") = 0;
  virtual void saveToSettings(QSettings &settings,
                              const QString &prefix = "") const = 0;
  virtual QJsonObject toJson() const = 0;
  virtual void fromJson(const QJsonObject &obj) = 0;
};

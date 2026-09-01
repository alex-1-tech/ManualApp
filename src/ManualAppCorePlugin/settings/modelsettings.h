#pragma once
#include <QCoreApplication>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QMap>
#include <QQmlEngine>
#include <QSettings>
#include <QVector>

class ModelSettings : public QObject
{
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("ModelSettings is created by SettingsManager")

  Q_PROPERTY(QString modelName READ modelName CONSTANT)
  Q_PROPERTY(QString modelTitle READ modelTitle CONSTANT)
  Q_PROPERTY(QString modelDescription READ modelDescription CONSTANT)
  Q_PROPERTY(QString modelInstallerPath READ modelInstallerPath CONSTANT)
  Q_PROPERTY(QVariantList fieldsMetadata READ getFieldsMetadata NOTIFY fieldsChanged)
  Q_PROPERTY(QVariantList modelVariants READ modelVariants CONSTANT)

public:
  explicit ModelSettings(const QString& modelName, QObject* parent = nullptr);
  ~ModelSettings() = default;

  bool loadConfiguration(const QString& jsonPath);
  bool loadScheme(const QString& jsonPath);
  void loadFromSettings(QSettings& settings, const QString& currentModel, const QString& prefix = "");
  void saveToSettings(QSettings& settings, const QString& prefix = "") const;
  QJsonObject toJson() const;
  void fromJson(const QJsonObject& obj);
  void debugPrint() const;

  Q_INVOKABLE QVariant getValue(const QString& name) const;
  Q_INVOKABLE void setValue(const QString& name, const QVariant& value);
  Q_INVOKABLE QStringList getPropertyNames() const;

  struct FieldMetadata {
    QString name;
    QString label;
    QString helpText;
    QString cppName;
    QString type;

    QVariantMap toVariantMap() const;
  };

  struct Section {
    QString title;
    QList<FieldMetadata> fields;
  };

  Q_INVOKABLE QVariantMap getFieldMetadata(const QString& fieldName) const;
  Q_INVOKABLE QVariantList getSectionsMetadata() const;
  Q_INVOKABLE QVariantList getFieldsMetadata() const;
  void parseModelMetadata(const QJsonObject& config);

  QString modelName() const { return m_modelName; }
  QString modelTitle() const { return m_modelTitle; }
  QString modelDescription() const { return m_modelDescription; }
  QString modelInstallerPath() const { return m_modelInstallerPath; }
  QVariantList modelVariants() const { return m_modelVariants; }
signals:
  void propertyChanged(const QString& name, const QVariant& value);
  void fieldsChanged();

private:
  void createPropertiesFromConfig(const QJsonObject& config);
  void registerDynamicProperty(const QString& name, const QVariant& defaultValue);


  QString m_modelName;
  QString m_modelTitle;
  QString m_modelDescription;
  QString m_modelInstallerPath;

  QList<Section> m_sections;
  QMap<QString, FieldMetadata> m_fieldsMetadata;
  QMap<QString, QVariant> m_values;
  QVariantList m_modelVariants;

  static int s_propertyCounter;
};
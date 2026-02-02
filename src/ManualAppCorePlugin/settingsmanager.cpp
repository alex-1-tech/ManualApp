#include "settingsmanager.h"

#include <QDebug>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>
#include <QMetaProperty>

#ifdef Q_OS_LINUX
#include <openssl/ec.h>
#include <openssl/ecdsa.h>
#include <openssl/err.h>
#include <openssl/evp.h>
#include <openssl/pem.h>
#include <openssl/rsa.h>
#include <openssl/sha.h>

#include <QBuffer>
#include <QByteArray>

#endif

#include "kalmar32settings.h"
#include "loger.h"
#include "phasar32settings.h"


namespace
{

const QHash<QString, QString>& specialCamelToSnake()
{
  static const QHash<QString, QString> map = {
      {QStringLiteral("serialNumber"), QStringLiteral("serial_number")},
      {QStringLiteral("shipmentDate"), QStringLiteral("shipment_date")},
      {QStringLiteral("invoice"), QStringLiteral("invoice")},
      {QStringLiteral("packetList"), QStringLiteral("packet_list")},
      {QStringLiteral("wifiRouterAddress"), QStringLiteral("wifi_router_address")},
      {QStringLiteral("windowsPassword"), QStringLiteral("windows_password")},
      {QStringLiteral("notes"), QStringLiteral("notes")},
      {QStringLiteral("currentModel"), QStringLiteral("equipment_type")}};
  return map;
}

const QHash<QString, QString>& specialSnakeToCamel()
{
  static QHash<QString, QString> rev;
  if (rev.isEmpty()) {
    const QHash<QString, QString>& fwd = specialCamelToSnake();
    for (auto it = fwd.constBegin(); it != fwd.constEnd(); ++it) {
      rev.insert(it.value(), it.key());
    }
  }
  return rev;
}

bool stringToBool(const QString& s)
{
  QString t = s.trimmed().toLower();
  return (t == QLatin1String("true") || t == QLatin1String("1") || t == QLatin1String("yes") ||
          t == QLatin1String("да") || t == QLatin1String("y"));
}

#ifdef Q_OS_LINUX
static const char* PUBLIC_KEY_PEM = R"(-----BEGIN PUBLIC KEY-----
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAqK42YubXaskgDhTJEOBF
BGiJKJ1FxyS111FI29y1Uw1KuQiPhPzkK9ni8kT9qCr7HA83dcSehS9UHMjl5Wox
mg42GgxOkN4v3nfgULkUhyziLVCw9AaYsUVU08TCuA5DjFJAyadsEDaogumcjquP
TcDrzZnED68F/PWIwoeknlzgK8Q5hKxyG4EvofkAjmSKw2Kuri8IIWh5FbKqHGmc
OXQZWBjIR9gRh6rCsO1MnKjqfInqvrnEMrTr5YuyqwMBPwKtZsg3C78EqT3CzTV2
sR6ccgZtgcxu54/aLi45IfT38VvImhdESObdde8dsOVyYUoUvm0rsUI1L2dRN3Qh
MJLOxuZLd8J6RT+lIk3jYaG1dQrvILQnguYEq9Q1P0IUsuAvu3gBD/ELXVO3cMm8
iTy3PKIBA9hAx2QYqKVJ1BR6zs0byWj+8Llm95ldJ2IH7Gnmk8AMdFs4epAukWnu
7x/in2STlRgaZrR7EQ5h9iRER5PYkCG1A6rp1/HfuE9kX1NLAI3M/wVubogzUYzq
pPNPpKF0HuXHtcUEVgfNBFnIeF03xqO/MUGsDuFGSPCbiGK8umbcGAypYvD3UcnG
OQ/T+8ZepbGsZlYpL3Ls2tAcN/SqD5bi4cx+JiSntk8JGTlIqVwOCWykeFntNmeh
0QrCabPEyR8hB7dr63xBUTcCAwEAAQ==
-----END PUBLIC KEY-----
)";

static QByteArray lenientBase64Decode(const QByteArray& in)
{
  QByteArray tmp = in;
  tmp.replace('-', '+');
  tmp.replace('_', '/');

  int mod = tmp.size() % 4;
  if (mod != 0) {
    tmp.append(QByteArray(4 - mod, '='));
  }

  return QByteArray::fromBase64(tmp);
}

static QByteArray canonicalizeJson(const QByteArray& json)
{
  QJsonDocument doc = QJsonDocument::fromJson(json);
  if (!doc.isObject()) {
    return json;
  }

  QJsonObject obj = doc.object();
  QJsonObject sorted;

  QStringList keys = obj.keys();
  keys.sort();

  for (const QString& key : keys) {
    sorted[key] = obj[key];
  }

  return QJsonDocument(sorted).toJson(QJsonDocument::Compact);
}

static bool verifySignatureSha256(EVP_PKEY* pubkey, const QByteArray& message, const QByteArray& signature)
{
  if (signature.size() != 512) {
    return false;
  }

  EVP_MD_CTX* ctx = EVP_MD_CTX_new();
  if (!ctx) {
    return false;
  }

  bool result = false;

  if (EVP_DigestVerifyInit(ctx, nullptr, EVP_sha256(), nullptr, pubkey) <= 0) {
    EVP_MD_CTX_free(ctx);
    return false;
  }

  int verify_result =
      EVP_DigestVerify(ctx, reinterpret_cast<const unsigned char*>(signature.constData()), signature.size(),
                       reinterpret_cast<const unsigned char*>(message.constData()), message.size());

  if (verify_result == 1) {
    result = true;
  } else if (verify_result == 0) {
    result = false;
  } else {
    result = false;
  }

  EVP_MD_CTX_free(ctx);
  return result;
}

static EVP_PKEY* loadPublicKey()
{
  BIO* bio = BIO_new_mem_buf(PUBLIC_KEY_PEM, -1);
  if (!bio) {
    return nullptr;
  }

  EVP_PKEY* key = PEM_read_bio_PUBKEY(bio, nullptr, nullptr, nullptr);
  BIO_free(bio);

  return key;
}
#endif

} // namespace

SettingsManager::SettingsManager(QObject* parent)
    : QObject(parent)
    , m_settings("technovotum", "ManualApp")
    , m_kalmarSettings(new Kalmar32Settings(this))
    , m_phasarSettings(new Phasar32Settings(this))
{
  loadAllSettings();
}

SettingsManager::~SettingsManager() {}

void SettingsManager::completeFirstRun()
{
  DEBUG_COLORED("SettingsManager", "completeFirstRun", "Initial setup completed - first run flag cleared",
                COLOR_GREEN, COLOR_GREEN);
  m_settings.setValue("isFirstRun", false);
}

void SettingsManager::saveModelSettings()
{
  DEBUG_COLORED("SettingsManager", "saveModelSettings", "Saving model-specific settings", COLOR_CYAN,
                COLOR_CYAN);
  m_kalmarSettings->saveToSettings(m_settings);
  m_phasarSettings->saveToSettings(m_settings);
}

void SettingsManager::saveAllSettings()
{
  DEBUG_COLORED("SettingsManager", "saveAllSettings", "Saving all settings to persistent storage", COLOR_BLUE,
                COLOR_BLUE);

  const QMetaObject* meta = this->metaObject();
  for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
    QMetaProperty prop = meta->property(i);
    if (!prop.isReadable()) continue;

    QVariant value = prop.read(this);
    if (value.canConvert<QDate>()) {
      m_settings.setValue(prop.name(), value.toDate().toString(Qt::ISODate));
    } else {
      m_settings.setValue(prop.name(), value);
    }
  }

  m_kalmarSettings->saveToSettings(m_settings);
  m_phasarSettings->saveToSettings(m_settings);
}

void SettingsManager::loadAllSettings()
{
  DEBUG_COLORED("SettingsManager", "loadAllSettings", "Loading all settings from persistent storage",
                COLOR_BLUE, COLOR_BLUE);

  const QMetaObject* meta = this->metaObject();
  for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
    QMetaProperty prop = meta->property(i);
    if (!prop.isWritable()) continue;

    if (!m_settings.contains(prop.name())) continue;

    QVariant val = m_settings.value(prop.name());
    if (prop.userType() == QMetaType::QDate) {
      QDate date = QDate::fromString(val.toString(), Qt::ISODate);
      prop.write(this, date);
    } else {
      prop.write(this, val);
    }
  }

  m_kalmarSettings->loadFromSettings(m_settings);
  m_phasarSettings->loadFromSettings(m_settings);
}

void SettingsManager::debugPrint() const
{
  qDebug() << "=== Common Settings ===";
  const QMetaObject* meta = this->metaObject();
  for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
    QMetaProperty prop = meta->property(i);
    QVariant value = prop.read(this);
    qDebug() << prop.name() << "=" << value;
  }

  if (currentModel() == "kalmar32")
    m_kalmarSettings->debugPrint();
  else if (currentModel() == "phasar32")
    m_phasarSettings->debugPrint();
}

QJsonObject SettingsManager::toJsonForDjango() const
{
  QJsonObject obj;
  const QMetaObject* meta = this->metaObject();
  const QHash<QString, QString>& special = specialCamelToSnake();

  for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
    QMetaProperty prop = meta->property(i);
    if (!prop.isReadable()) continue;

    QVariant value = prop.read(this);
    const int type = value.userType();

    QString originalName = QString::fromLatin1(prop.name());
    QString outKey;
    if (special.contains(originalName)) {
      outKey = special.value(originalName);
    } else {
      continue;
    }

    if (type == QMetaType::QDate) {
      QDate date = value.toDate();
      if (date.isValid())
        obj[outKey] = date.toString(Qt::ISODate);
      else
        obj[outKey] = QString();
    } else {
      obj[outKey] = QJsonValue::fromVariant(value);
    }
  }

  if (currentModel() == "kalmar32") {
    QJsonObject modelObj = m_kalmarSettings->toJson();
    for (auto it = modelObj.constBegin(); it != modelObj.constEnd(); ++it) {
      obj[it.key()] = it.value();
    }
  } else if (currentModel() == "phasar32") {
    QJsonObject modelObj = m_phasarSettings->toJson();
    for (auto it = modelObj.constBegin(); it != modelObj.constEnd(); ++it) {
      obj[it.key()] = it.value();
    }
  }

  return obj;
}

void SettingsManager::fromJson(const QJsonObject& obj)
{
  DEBUG_COLORED("SettingsManager", "fromJson", "Loading settings from JSON object", COLOR_MAGENTA,
                COLOR_MAGENTA);

  const QMetaObject* meta = this->metaObject();
  const QHash<QString, QString>& specialRev = specialSnakeToCamel();

  for (auto it = obj.constBegin(); it != obj.constEnd(); ++it) {
    const QString key = it.key();
    const QJsonValue val = it.value();

    QString propName = specialRev.contains(key) ? specialRev.value(key) : key;
    if (propName.isEmpty()) {
      continue;
    }

    int propIndex = meta->indexOfProperty(propName.toLatin1().constData());
    if (propIndex < 0) {
      continue;
    }

    QMetaProperty prop = meta->property(propIndex);
    QString settingsKey = QString::fromLatin1(prop.name());
    QVariant writeVal;

    if (prop.userType() == QMetaType::QDate) {
      if (val.isString()) {
        QString s = val.toString().trimmed();
        if (s.isEmpty()) {
          writeVal = QString();
        } else {
          QDate d = QDate::fromString(s, Qt::ISODate);
          if (d.isValid())
            writeVal = d.toString(Qt::ISODate);
          else
            writeVal = s;
        }
      } else {
        writeVal = QString();
      }
    } else if (prop.userType() == QMetaType::Bool) {
      if (val.isBool())
        writeVal = val.toBool();
      else if (val.isString())
        writeVal = stringToBool(val.toString());
      else if (val.isDouble())
        writeVal = (val.toInt() != 0);
      else
        writeVal = false;
    } else if (prop.userType() == QMetaType::Double) {
      if (val.isDouble())
        writeVal = val.toDouble();
      else if (val.isString()) {
        QString s = val.toString().trimmed();
        s.replace(',', '.');
        writeVal = s.isEmpty() ? 0.0 : s.toDouble();
      } else if (val.isBool())
        writeVal = val.toBool() ? 1.0 : 0.0;
      else
        writeVal = QVariant();
    } else if (prop.userType() == QMetaType::Int) {
      if (val.isDouble())
        writeVal = val.toInt();
      else if (val.isString())
        writeVal = val.toString().toInt();
      else if (val.isBool())
        writeVal = val.toBool() ? 1 : 0;
      else
        writeVal = QVariant();
    } else {
      if (val.isNull() || val.isUndefined())
        writeVal = QString();
      else if (val.isString())
        writeVal = val.toString();
      else
        writeVal = val.toVariant();
    }

    if (writeVal.isValid()) {
      m_settings.setValue(settingsKey, writeVal);
    }
  }

  QString newModel = m_settings.value("currentModel").toString();

  if (newModel == "kalmar32") {
    DEBUG_COLORED("SettingsManager", "fromJson", "Loading Kalmar32 model-specific settings", COLOR_CYAN,
                  COLOR_CYAN);
    m_kalmarSettings->fromJson(obj);
    m_kalmarSettings->saveToSettings(m_settings);
  } else if (newModel == "phasar32") {
    DEBUG_COLORED("SettingsManager", "fromJson", "Loading Phasar32 model-specific settings", COLOR_CYAN,
                  COLOR_CYAN);
    m_phasarSettings->fromJson(obj);
    m_phasarSettings->saveToSettings(m_settings);
  } else {
    if (obj.contains("water_tank_with_tap")) {
      DEBUG_COLORED("SettingsManager", "fromJson", "Auto-detected Phasar32 from JSON data", COLOR_YELLOW,
                    COLOR_YELLOW);
      m_phasarSettings->fromJson(obj);
      m_phasarSettings->saveToSettings(m_settings);
      m_settings.setValue("currentModel", "phasar32");
    } else if (obj.contains("pc_tablet_dell_7230")) {
      DEBUG_COLORED("SettingsManager", "fromJson", "Auto-detected Kalmar32 from JSON data", COLOR_YELLOW,
                    COLOR_YELLOW);
      m_kalmarSettings->fromJson(obj);
      m_kalmarSettings->saveToSettings(m_settings);
      m_settings.setValue("currentModel", "kalmar32");
    } else {
      DEBUG_COLORED("SettingsManager", "fromJson", "Could not detect model type from JSON", COLOR_RED,
                    COLOR_RED);
    }
  }

  m_settings.sync();
  loadAllSettings();
}

Q_INVOKABLE bool SettingsManager::hasLicense()
{
  m_settings.beginGroup("license");
  bool ok = m_settings.contains("raw") || !m_settings.childKeys().isEmpty();
  m_settings.endGroup();
  return ok;
}

Q_INVOKABLE QJsonObject SettingsManager::license()
{
  m_settings.beginGroup("license");

  QJsonObject result;
  result["license_key"] = m_settings.value("license_key").toString();
  result["signature"] = m_settings.value("signature").toString();

  QJsonObject payload;
  payload["ver"] = m_settings.value("ver").toString();
  payload["product"] = m_settings.value("product").toString();
  payload["company_name"] = m_settings.value("company_name").toString();
  payload["host_hwid"] = m_settings.value("host_hwid").toString();
  payload["device_hwid"] = m_settings.value("device_hwid").toString();
  payload["exp"] = m_settings.value("exp").toString();

  QJsonObject features;
  QString featuresStr = m_settings.value("features").toString();
  if (!featuresStr.isEmpty()) {
    QJsonDocument fdoc = QJsonDocument::fromJson(featuresStr.toUtf8());
    if (fdoc.isObject()) {
      features = fdoc.object();
    }
  }

  payload["features"] = features;
  result["payload"] = payload;

  m_settings.endGroup();
  return result;
}

Q_INVOKABLE void SettingsManager::saveLicense(const QJsonObject& license)
{
  DEBUG_COLORED("SettingsManager", "saveLicense", "Saving license to persistent storage", COLOR_GREEN,
                COLOR_GREEN);

  m_settings.beginGroup("license");

  m_settings.setValue("license_key", license.value("license_key").toString());
  m_settings.setValue("signature", license.value("signature").toString());

  QJsonObject payload = license.value("payload").toObject();
  m_settings.setValue("ver", payload.value("ver").toString());
  m_settings.setValue("product", payload.value("product").toString());
  m_settings.setValue("company_name", payload.value("company_name").toString());
  m_settings.setValue("host_hwid", payload.value("host_hwid").toString());
  m_settings.setValue("device_hwid", payload.value("device_hwid").toString());
  m_settings.setValue("exp", payload.value("exp").toString());

  QJsonObject features = payload.value("features").toObject();
  m_settings.setValue("features", QJsonDocument(features).toJson(QJsonDocument::Compact));

  m_settings.endGroup();
  m_settings.sync();

  QString product = payload.value("product").toString().toLower();
  QString licenseKey = license.value("license_key").toString();

#ifdef Q_OS_WIN
  if (product == "phasar32") {
    DEBUG_COLORED("SettingsManager", "saveLicense", "Writing Phasar32 license to Windows registry",
                  COLOR_YELLOW, COLOR_YELLOW);
    QString keyPath = "HKEY_LOCAL_MACHINE\\Software\\Technovotum\\Phasar";
    QSettings registry(keyPath, QSettings::NativeFormat);
    registry.setValue("ProductKey", licenseKey);
    registry.sync();
  }
#endif

  verifyLicense();
  DEBUG_COLORED("SettingsManager", "saveLicense", "License saved with all parameters", COLOR_GREEN,
                COLOR_GREEN);
}

Q_INVOKABLE void SettingsManager::clearLicense()
{
  DEBUG_COLORED("SettingsManager", "clearLicense", "Clearing license from settings", COLOR_RED, COLOR_RED);

  m_settings.beginGroup("license");
  for (const QString& k : m_settings.childKeys()) {
    m_settings.remove(k);
  }
  m_settings.endGroup();
  m_settings.sync();
}

bool SettingsManager::verifyLicense()
{
#ifdef Q_OS_LINUX
  DEBUG_COLORED("SettingsManager", "verifyLicense", "Starting license verification", COLOR_BLUE, COLOR_BLUE);

  if (!hasLicense()) {
    DEBUG_COLORED("SettingsManager", "verifyLicense", "No license found in settings", COLOR_RED, COLOR_RED);
    return false;
  }

  const QString licenseKey = license().value("license_key").toString();
  if (licenseKey.isEmpty()) {
    DEBUG_COLORED("SettingsManager", "verifyLicense", "License key is empty", COLOR_RED, COLOR_RED);
    return false;
  }

  const QStringList parts = licenseKey.split('.');
  if (parts.size() != 2) {
    DEBUG_COLORED("SettingsManager", "verifyLicense",
                  "Invalid license_key format - expected two parts separated by dot", COLOR_RED, COLOR_RED);
    return false;
  }

  QByteArray canonicalRaw = lenientBase64Decode(parts[0].toLatin1());
  QByteArray signatureRaw = lenientBase64Decode(parts[1].toLatin1());

  if (canonicalRaw.isEmpty() || signatureRaw.isEmpty()) {
    DEBUG_COLORED("SettingsManager", "verifyLicense", "Failed to decode license parts from base64", COLOR_RED,
                  COLOR_RED);
    return false;
  }

  QByteArray canonicalized = canonicalizeJson(canonicalRaw);
  QJsonDocument doc = QJsonDocument::fromJson(canonicalized);
  if (!doc.isObject()) {
    DEBUG_COLORED("SettingsManager", "verifyLicense", "Invalid license payload JSON", COLOR_RED, COLOR_RED);
    return false;
  }

  const QJsonObject payload = doc.object();
  QStringList requiredFields = {"ver", "product", "company_name", "host_hwid", "exp"};
  for (const QString& field : requiredFields) {
    if (!payload.contains(field)) {
      DEBUG_COLORED("SettingsManager", "verifyLicense", QString("Missing required field: %1").arg(field),
                    COLOR_RED, COLOR_RED);
      return false;
    }
  }

  const QString expStr = payload.value("exp").toString();
  const QDate expDate = QDate::fromString(expStr, Qt::ISODate);
  if (expDate.isValid() && expDate < QDate::currentDate()) {
    DEBUG_COLORED("SettingsManager", "verifyLicense", QString("License expired on %1").arg(expStr), COLOR_RED,
                  COLOR_RED);
    return false;
  }

  EVP_PKEY* pubkey = loadPublicKey();
  if (!pubkey) {
    DEBUG_COLORED("SettingsManager", "verifyLicense", "Failed to load public key for verification", COLOR_RED,
                  COLOR_RED);
    return false;
  }

  const bool valid = verifySignatureSha256(pubkey, canonicalized, signatureRaw);
  EVP_PKEY_free(pubkey);

  if (valid) {
    DEBUG_COLORED("SettingsManager", "verifyLicense", "License verification SUCCESS", COLOR_GREEN,
                  COLOR_GREEN);
  } else {
    DEBUG_COLORED("SettingsManager", "verifyLicense", "License verification FAILED - signature invalid",
                  COLOR_RED, COLOR_RED);
  }

  return valid;
#else
  DEBUG_COLORED("SettingsManager", "verifyLicense",
                "License verification not supported on this platform, returning true", COLOR_YELLOW,
                COLOR_YELLOW);
  return true;
#endif
}
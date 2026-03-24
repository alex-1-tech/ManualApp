#include "licensehandler.h"

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

#include <QCoreApplication>
#include <QDebug>
#include <QJsonDocument>
#include <QSettings>

#ifdef Q_OS_WIN
#include <QSettings>
#endif

#include "../file/loger.h"

namespace
{

#ifdef Q_OS_LINUX
static const char* PUBLIC_KEY_PEM = R"(-----BEGIN PUBLIC KEY-----
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAqK42YubXaskgDhTJEOBF
BGiJKJ1FxyS111FI29y1Uw1KuQiPhPzkK9ni8kT9qCr7HA83dcSehS9UHMjl5Wox
mg42GgxOkN4v3nfgULkUhyziLVCw9AaYsUVU08TCuA5DjFJAyadsEDaogumcjquP
TcDrzZnED68F/PWIwoeknlzgK8Q5hKxyG4EvofkAjmSKw2Kuri8IIWh5FbKqHGmc
OXQZWBjIR9gRh6rCsO1MnKjqfInqvrnEMrTr5YuyqwMBPwKtZsg3C78EqT3CzTV2
sR6ccgZtgcxu54/aLi45IfT38VvImhdESObdde8dsOVyYUoUvm0rsUI1L2dRN3Qh
MJLOxuZLd8J6RT+lIk3jYaG1dQrvILQnguYEq9Q1P0IUsuAvu3gBD/ELXVO3cMm8
iTy3PKIBA9hAx2QYqKVJ1BR6zs0byWj+8Llm95ldJ2IH7Gmnk8AMdFs4epAukWnu
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

LicenseHandler::LicenseHandler(QObject* parent)
    : QObject(parent)
    , m_settings("technovotum", "ManualApp")
    , m_isLicenseActivate(false)
{
  checkLicenseKeyOnStart();
}

LicenseHandler::~LicenseHandler() {}

void LicenseHandler::checkLicenseKeyOnStart()
{
  m_settings.beginGroup("license");
  QString licenseKey = m_settings.value("license_key").toString();
  m_settings.endGroup();

  if (!licenseKey.isEmpty()) {
    DEBUG_COLORED("LicenseHandler", "checkLicenseKeyOnStart", QString("Found license key on start"),
                  COLOR_GREEN, COLOR_GREEN);
    setIsLicenseActivate(true);
  } else {
    DEBUG_COLORED("LicenseHandler", "checkLicenseKeyOnStart", "No license key found on start", COLOR_GREEN,
                  COLOR_GREEN);
    setIsLicenseActivate(false);
  }
}

void LicenseHandler::updateActivationStatusFromSettings()
{
  m_settings.beginGroup("license");
  QString licenseKey = m_settings.value("license_key").toString();
  m_settings.endGroup();

  setIsLicenseActivate(!licenseKey.isEmpty());
}

bool LicenseHandler::hasLicense() const
{
  return m_settings.contains("license/license_key");
}

QJsonObject LicenseHandler::license() const
{
  QJsonObject result;

  result["license_key"] = m_settings.value("license/license_key").toString();
  result["signature"] = m_settings.value("license/signature").toString();

  QJsonObject payload;
  payload["ver"] = m_settings.value("license/ver").toString();
  payload["product"] = m_settings.value("license/product").toString();
  payload["company_name"] = m_settings.value("license/company_name").toString();
  payload["host_hwid"] = m_settings.value("license/host_hwid").toString();
  payload["device_hwid"] = m_settings.value("license/device_hwid").toString();
  payload["exp"] = m_settings.value("license/exp").toString();

  QString featuresStr = m_settings.value("license/features").toString();
  QJsonObject features;

  if (!featuresStr.isEmpty()) {
    QJsonDocument doc = QJsonDocument::fromJson(featuresStr.toUtf8());
    if (doc.isObject()) features = doc.object();
  }

  payload["features"] = features;
  result["payload"] = payload;

  return result;
}

void LicenseHandler::saveLicense(const QJsonObject& license)
{
  DEBUG_COLORED("LicenseHandler", "saveLicense", "Saving license to persistent storage", COLOR_GREEN,
                COLOR_GREEN);

  m_settings.beginGroup("license");

  QString licenseKey = license.value("license_key").toString();
  m_settings.setValue("license_key", licenseKey);
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

  if (!licenseKey.isEmpty()) {
    setIsLicenseActivate(true);
  }

  QString product = payload.value("product").toString();

#ifdef Q_OS_WIN
  if (product == "phasar01") {
    DEBUG_COLORED("LicenseHandler", "saveLicense", "Writing Phasar01 license to Windows registry",
                  COLOR_GREEN, COLOR_GREEN);
    QString keyPath = "HKEY_CURRENT_USER\\Software\\Technovotum\\Phasar";
    QSettings registry(keyPath, QSettings::NativeFormat);
    registry.setValue("ProductKey", licenseKey);
    registry.sync();
  }
#endif

  verifyLicense();
  emit licenseChanged();
  DEBUG_COLORED("LicenseHandler", "saveLicense", "License saved with all parameters", COLOR_GREEN,
                COLOR_GREEN);
}

void LicenseHandler::clearLicense()
{
  DEBUG_ERROR_COLORED("LicenseHandler", "clearLicense", "Clearing license from settings", COLOR_GREEN,
                      COLOR_GREEN);

  m_settings.beginGroup("license");
  for (const QString& k : m_settings.childKeys()) {
    m_settings.remove(k);
  }
  m_settings.endGroup();
  m_settings.sync();

  setIsLicenseActivate(false);
  emit licenseChanged();
}

bool LicenseHandler::verifyLicense()
{
#ifdef Q_OS_LINUX
  DEBUG_COLORED("LicenseHandler", "verifyLicense", "Starting license verification", COLOR_GREEN, COLOR_GREEN);

  if (!hasLicense()) {
    DEBUG_ERROR_COLORED("LicenseHandler", "verifyLicense", "No license found in settings", COLOR_GREEN,
                        COLOR_GREEN);
    setIsLicenseActivate(false);
    emit licenseVerified(false);
    return false;
  }

  const QString licenseKey = license().value("license_key").toString();
  if (licenseKey.isEmpty()) {
    DEBUG_ERROR_COLORED("LicenseHandler", "verifyLicense", "License key is empty", COLOR_GREEN, COLOR_GREEN);
    setIsLicenseActivate(false);
    emit licenseVerified(false);
    return false;
  }

  const QStringList parts = licenseKey.split('.');
  if (parts.size() != 2) {
    DEBUG_ERROR_COLORED("LicenseHandler", "verifyLicense",
                        "Invalid license_key format - expected two parts separated by dot", COLOR_GREEN,
                        COLOR_GREEN);
    setIsLicenseActivate(false);
    emit licenseVerified(false);
    return false;
  }

  QByteArray canonicalRaw = lenientBase64Decode(parts[0].toLatin1());
  QByteArray signatureRaw = lenientBase64Decode(parts[1].toLatin1());

  if (canonicalRaw.isEmpty() || signatureRaw.isEmpty()) {
    DEBUG_ERROR_COLORED("LicenseHandler", "verifyLicense", "Failed to decode license parts from base64",
                        COLOR_GREEN, COLOR_GREEN);
    setIsLicenseActivate(false);
    emit licenseVerified(false);
    return false;
  }

  QByteArray canonicalized = canonicalizeJson(canonicalRaw);
  QJsonDocument doc = QJsonDocument::fromJson(canonicalized);
  if (!doc.isObject()) {
    DEBUG_ERROR_COLORED("LicenseHandler", "verifyLicense", "Invalid license payload JSON", COLOR_GREEN,
                        COLOR_GREEN);
    setIsLicenseActivate(false);
    emit licenseVerified(false);
    return false;
  }

  const QJsonObject payload = doc.object();
  QStringList requiredFields = {"ver", "product", "company_name", "host_hwid", "exp"};
  for (const QString& field : requiredFields) {
    if (!payload.contains(field)) {
      DEBUG_ERROR_COLORED("LicenseHandler", "verifyLicense", QString("Missing required field: %1").arg(field),
                          COLOR_GREEN, COLOR_GREEN);
      setIsLicenseActivate(false);
      emit licenseVerified(false);
      return false;
    }
  }

  const QString expStr = payload.value("exp").toString();
  const QDate expDate = QDate::fromString(expStr, Qt::ISODate);
  if (expDate.isValid() && expDate < QDate::currentDate()) {
    DEBUG_ERROR_COLORED("LicenseHandler", "verifyLicense", QString("License expired on %1").arg(expStr),
                        COLOR_GREEN, COLOR_GREEN);
    setIsLicenseActivate(false);
    emit licenseVerified(false);
    return false;
  }

  EVP_PKEY* pubkey = loadPublicKey();
  if (!pubkey) {
    DEBUG_ERROR_COLORED("LicenseHandler", "verifyLicense", "Failed to load public key for verification",
                        COLOR_GREEN, COLOR_GREEN);
    setIsLicenseActivate(false);
    emit licenseVerified(false);
    return false;
  }

  const bool valid = verifySignatureSha256(pubkey, canonicalized, signatureRaw);
  EVP_PKEY_free(pubkey);

  if (valid) {
    DEBUG_COLORED("LicenseHandler", "verifyLicense", "License verification SUCCESS", COLOR_GREEN,
                  COLOR_GREEN);
    setIsLicenseActivate(true);
  } else {
    DEBUG_ERROR_COLORED("LicenseHandler", "verifyLicense", "License verification FAILED - signature invalid",
                        COLOR_GREEN, COLOR_GREEN);
    setIsLicenseActivate(false);
  }

  emit licenseVerified(valid);
  return valid;
#else
  DEBUG_COLORED("LicenseHandler", "verifyLicense",
                "License verification not supported on this platform, returning true", COLOR_GREEN,
                COLOR_GREEN);
  setIsLicenseActivate(true);
  emit licenseVerified(true);
  return true;
#endif
}

bool LicenseHandler::isLicenseActivate() const
{
  return m_isLicenseActivate;
}

void LicenseHandler::setIsLicenseActivate(bool value)
{
  if (m_isLicenseActivate != value) {
    m_isLicenseActivate = value;
    emit licenseActivationStatusChanged(value);
  }
}
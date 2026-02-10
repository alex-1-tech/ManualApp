#pragma once

#include <QByteArray>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QString>

class DjangoErrorParser
{
public:
  static QString parse(const QByteArray& data)
  {
    if (data.isEmpty()) return {};

    QJsonDocument doc = QJsonDocument::fromJson(data);

    if (!doc.isObject()) return QString::fromUtf8(data).left(500);

    QJsonObject obj = doc.object();

    // Самые частые Django/DRF варианты
    if (obj.contains("error")) return obj.value("error").toString();

    if (obj.contains("detail")) return obj.value("detail").toString();

    if (obj.contains("message")) return obj.value("message").toString();

    // DRF validation errors (dict field -> list of errors)
    QStringList errors;
    for (auto it = obj.begin(); it != obj.end(); ++it) {
      if (it.value().isArray()) {
        for (const auto& val : it.value().toArray())
          errors << QString("%1: %2").arg(it.key(), val.toString());
      } else if (it.value().isString()) {
        errors << QString("%1: %2").arg(it.key(), it.value().toString());
      }
    }

    if (!errors.isEmpty()) return errors.join("; ");

    return QString::fromUtf8(data).left(500);
  };
};

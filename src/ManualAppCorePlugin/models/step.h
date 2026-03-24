#pragma once
#include <QJsonObject>
#include <QString>

struct Step {
  QString title;

  enum class CompletionStatus {
    NotStarted,
    Completed,
    HasDefect,
    Skipped,
  };
  CompletionStatus completionStatus = CompletionStatus::NotStarted;

  struct DefectDetails {
    QString description;
    QString repairMethod;

    enum class FixStatus { Fixed, Postponed, NotRequired, NotFixed };
    FixStatus fixStatus = FixStatus::Fixed;

    QJsonObject toJson() const
    {
      return {{"description", description},
              {"repairMethod", repairMethod},
              {"fixStatus", static_cast<int>(fixStatus)}};
    }

    static DefectDetails fromJson(const QJsonObject& obj)
    {
      DefectDetails dd;
      dd.description = obj["description"].toString();
      dd.repairMethod = obj["repairMethod"].toString();
      dd.fixStatus = static_cast<FixStatus>(obj["fixStatus"].toInt(0));
      return dd;
    }
  };

  DefectDetails defectDetails;

  QJsonObject toJson() const
  {
    QJsonObject obj;
    obj["title"] = title;
    obj["completionStatus"] = static_cast<int>(completionStatus);

    if (completionStatus == CompletionStatus::HasDefect) {
      obj["defectDetails"] = defectDetails.toJson();
    }
    return obj;
  }

  static Step fromJson(const QJsonObject& obj)
  {
    Step s;
    s.title = obj["title"].toString();
    s.completionStatus = CompletionStatus ::NotStarted;
    // static_cast<CompletionStatus>(obj["completionStatus"].toInt(0));

    if (s.completionStatus == CompletionStatus::HasDefect) {
      s.defectDetails = DefectDetails::fromJson(obj["defectDetails"].toObject());
    }
    return s;
  }
};
#pragma once

#include <QAbstractListModel>
#include <QQmlEngine>

#include "step.h"


class StepModel : public QAbstractListModel
{
  Q_OBJECT
  QML_ELEMENT
public:
  enum StepRoles {
    TitleRole = Qt::UserRole + 1,
    StatusRole,
    HasDefectRole,
    DefectDescriptionRole,
    DefectRepairMethodRole,
    DefectFixStatus
  };
  Q_ENUM(StepRoles)

  explicit StepModel(QObject* parent = nullptr);

  int rowCount(const QModelIndex& parent = {}) const override;
  QVariant data(const QModelIndex& index, int role) const override;
  QHash<int, QByteArray> roleNames() const override;

  Q_INVOKABLE void setSteps(const QList<Step>& steps);
  Q_INVOKABLE void clear();
  Q_INVOKABLE Step get(int index) const;
  Q_INVOKABLE QVariant getData(int index, int role) const;
  Q_INVOKABLE void updateStep(int index, const Step& step);

  Q_INVOKABLE void setStepStatus(int index, Step::CompletionStatus status);
  Q_INVOKABLE void setTitle(int index, const QString& title);
  Q_INVOKABLE void setDefectDescription(int index, const QString& description);
  Q_INVOKABLE void setDefectRepairMethod(int index, const QString& method);
  Q_INVOKABLE void setDefectFixStatus(int index, Step::DefectDetails::FixStatus status);
  std::vector<Step> getSteps() const { return m_steps; }

private:
  std::vector<Step> m_steps;
};

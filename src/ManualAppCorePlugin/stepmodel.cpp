#include "stepmodel.h"

#include <QDebug>


StepModel::StepModel(QObject* parent)
    : QAbstractListModel(parent)
{
}

int StepModel::rowCount(const QModelIndex& parent) const
{
  Q_UNUSED(parent);

  return static_cast<int>(m_steps.size());
}

QVariant StepModel::data(const QModelIndex& index, int role) const
{
  if (!index.isValid() || index.row() >= m_steps.size()) return QVariant();

  const Step& step = m_steps[index.row()];

  switch (role) {
    case TitleRole: return step.title;
    case StatusRole: return static_cast<int>(step.completionStatus);
    case HasDefectRole: return step.completionStatus == Step::CompletionStatus::HasDefect;
    case DefectDescriptionRole:
      return step.completionStatus == Step::CompletionStatus::HasDefect ? step.defectDetails.description : "";
    case DefectRepairMethodRole:
      return step.completionStatus == Step::CompletionStatus::HasDefect ? step.defectDetails.repairMethod
                                                                        : "";
    case DefectFixStatus:
      return step.completionStatus == Step::CompletionStatus::HasDefect
                 ? static_cast<int>(step.defectDetails.fixStatus)
                 : 0;
    default: return QVariant();
  }
}

QHash<int, QByteArray> StepModel::roleNames() const
{
  return {{TitleRole, "title"},
          {StatusRole, "status"},
          {HasDefectRole, "hasDefect"},
          {DefectDescriptionRole, "defectDescriptionRole"},
          {DefectRepairMethodRole, "defectRepairMethodRole"},
          {DefectFixStatus, "defectFixStatus"}};
}

void StepModel::setSteps(const QList<Step>& steps)
{
  beginResetModel();
  m_steps = std::vector<Step>(steps.begin(), steps.end());
  endResetModel();
}

void StepModel::clear()
{
  beginResetModel();
  m_steps.clear();
  endResetModel();
}

Step StepModel::get(int index) const
{
  if (index >= 0 && index < static_cast<int>(m_steps.size())) {
    return m_steps[index];
  }
  return {};
}

QVariant StepModel::getData(int index, int role) const
{
  if (index >= 0 && index < static_cast<int>(m_steps.size())) {
    return data(this->index(index), role);
  }
  return QVariant();
}

void StepModel::updateStep(int index, const Step& step)
{
  if (index >= 0 && index < static_cast<int>(m_steps.size())) {
    m_steps[index] = step;
    emit dataChanged(this->index(index), this->index(index));
  }
}

void StepModel::setStepStatus(int index, Step::CompletionStatus status)
{
  if (index >= 0 && index < static_cast<int>(m_steps.size())) {
    m_steps[index].completionStatus = status;
    if (status != Step::CompletionStatus::HasDefect) {
      m_steps[index].defectDetails = Step::DefectDetails{};
    }
    QVector<int> roles = {StatusRole, HasDefectRole, DefectDescriptionRole, DefectRepairMethodRole,
                          DefectFixStatus};
    emit dataChanged(this->index(index), this->index(index), roles);
  }
}

void StepModel::setTitle(int index, const QString& title)
{
  if (index >= 0 && index < static_cast<int>(m_steps.size())) {
    if (m_steps[index].title != title) {
      m_steps[index].title = title;
      QVector<int> roles = {TitleRole};
      emit dataChanged(this->index(index), this->index(index), roles);
    }
  }
}

void StepModel::setDefectDescription(int index, const QString& description)
{
  if (index >= 0 && index < static_cast<int>(m_steps.size())) {
    if (m_steps[index].defectDetails.description != description) {
      m_steps[index].defectDetails.description = description;
      QVector<int> roles = {DefectDescriptionRole};
      emit dataChanged(this->index(index), this->index(index), roles);
    }
  }
}

void StepModel::setDefectRepairMethod(int index, const QString& method)
{
  if (index >= 0 && index < static_cast<int>(m_steps.size())) {
    if (m_steps[index].defectDetails.repairMethod != method) {
      m_steps[index].defectDetails.repairMethod = method;
      QVector<int> roles = {DefectRepairMethodRole};
      emit dataChanged(this->index(index), this->index(index), roles);
    }
  }
}

void StepModel::setDefectFixStatus(int index, Step::DefectDetails::FixStatus status)
{
  if (index >= 0 && index < static_cast<int>(m_steps.size())) {
    if (m_steps[index].defectDetails.fixStatus != status) {
      m_steps[index].defectDetails.fixStatus = status;
      QVector<int> roles = {DefectFixStatus};
      emit dataChanged(this->index(index), this->index(index), roles);
    }
  }
}

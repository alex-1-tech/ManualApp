import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import ManualApp.Core 1.0
import datamanager.Models 1.0

Item {

    property var stepsModel: DataManager?.stepsModel ?? null
    property int totalSteps: stepsModel?.rowCount() ?? 0
    property int currentStep: totalSteps > 0 ? 0 : -1

    readonly property bool isValidStep: currentStep >= 0 && currentStep < totalSteps

    readonly property int notStarted: 0
    readonly property int completed: 1
    readonly property int hasDefect: 2
    readonly property int skipped: 3

    readonly property int fixed: 0
    readonly property int postponed: 1
    readonly property int notRequired: 2
    readonly property int notFixed: 3

    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16
        width: Math.min(parent.width * 0.9, 600)

        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 24
            font.bold: true
            color: "#000000"
            text: qsTr("MAINTENANCE")
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true

            RowLayout {
                spacing: 10

                Rectangle {
                    width: 30
                    height: 30
                    color: "#000"
                    radius: 15

                    Text {
                        anchors.centerIn: parent
                        color: "#fff"
                        text: isValidStep ? (currentStep + 1).toString() : "0"
                        font.pixelSize: 18
                        font.bold: true
                    }
                }

                Text {
                    text: qsTr("Step %1").arg(isValidStep ? currentStep + 1 : 0)
                    font.pixelSize: 18
                    font.bold: true
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text: qsTr("%1/%2").arg(isValidStep ? currentStep + 1 : 0).arg(totalSteps)
                font.pixelSize: 16
                color: "#555555"
            }
        }

        ProgressBar {
            id: progressbar
            Layout.fillWidth: true
            value: totalSteps > 0 ? (currentStep + 1) / totalSteps : 0
            height: 8
            padding: 0

            contentItem: Item {
                Rectangle {
                    width: parent.width * progressbar.value
                    height: parent.height
                    color: "#3fb8e0"
                }
            }

            background: Rectangle {
                color: "#e0e0e0"
                radius: height / 2
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.topMargin: 10
            text: isValidStep ? DataManager.stepsModel.getData(currentStep, StepModel.TitleRole) : ""
            font.pixelSize: 22
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            CheckBox {
                id: stepCompletedCheck
                Layout.alignment: Qt.AlignLeft
                text: qsTr("Step completed")
                font.pointSize: 14
                checked: isValidStep && (DataManager.stepsModel.getData(currentStep, StepModel.StatusRole) !== notStarted)
                enabled: isValidStep
                onToggled: {
                    if (!isValidStep)
                        return;

                    if (checked) {
                        if (defectFoundCheck.checked) {
                            DataManager.setStepStatus(currentStep, hasDefect);
                        } else {
                            DataManager.setStepStatus(currentStep, completed);
                        }
                    } else {
                        DataManager.setStepStatus(currentStep, notStarted);
                    }
                }
            }

            CheckBox {
                id: defectFoundCheck
                Layout.alignment: Qt.AlignLeft
                text: qsTr("Defect found")
                font.pointSize: 14
                checked: isValidStep && (DataManager.stepsModel.getData(currentStep, StepModel.StatusRole) === hasDefect)
                enabled: stepCompletedCheck.checked && isValidStep
                onToggled: {
                    if (!isValidStep)
                        return;

                    if (checked) {
                        DataManager.setStepStatus(currentStep, hasDefect);
                    } else {
                        DataManager.setStepStatus(currentStep, completed);
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: defectFoundCheck.checked

            Text {
                Layout.fillWidth: true
                text: qsTr("Defect description")
                font.pixelSize: 16
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                color: "#fff"
                border.color: defectDescEdit.text ? "#cccccc" : "#aaaaaa"
                border.width: 1
                radius: 4

                TextEdit {
                    id: defectDescEdit
                    anchors.fill: parent
                    anchors.margins: 8
                    wrapMode: TextEdit.WordWrap
                    font.pixelSize: 14
                    selectByMouse: true
                    text: isValidStep ? DataManager.stepsModel.getData(currentStep, StepModel.DefectDescriptionRole) : ""
                    enabled: defectFoundCheck.checked
                    onTextChanged: {
                        if (isValidStep && defectFoundCheck.checked) {
                            DataManager.stepsModel.setDefectDescription(
                                currentStep, 
                                defectDescEdit.text,
                            );
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        visible: !parent.text
                        Text {
                            anchors.fill: parent
                            color: "#aaaaaa"
                            text: qsTr("Enter defect description here...")
                            font: defectDescEdit.font
                            verticalAlignment: Text.AlignTop
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("Repair method")
                font.pixelSize: 16
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                color: "#fff"
                border.color: repairMethodEdit.text ? "#cccccc" : "#aaaaaa"
                border.width: 1
                radius: 4

                TextEdit {
                    id: repairMethodEdit
                    anchors.fill: parent
                    anchors.margins: 8
                    wrapMode: TextEdit.WordWrap
                    font.pixelSize: 14
                    selectByMouse: true
                    text: isValidStep ? DataManager.stepsModel.getData(currentStep, StepModel.DefectRepairMethodRole) : ""
                    enabled: defectFoundCheck.checked
                    onTextChanged: {
                        if (isValidStep && defectFoundCheck.checked) {
                            DataManager.stepsModel.setDefectRepairMethod(currentStep, text);
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        visible: !parent.text
                        Text {
                            anchors.fill: parent
                            color: "#aaaaaa"
                            text: qsTr("Enter repair method here...")
                            font: repairMethodEdit.font
                            verticalAlignment: Text.AlignTop
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("Fix status")
                font.pixelSize: 16
            }

            ComboBox {
                id: fixStatusCombo
                Layout.fillWidth: true
                model: [qsTr("Fixed"), qsTr("Postponed"), qsTr("Not required"), qsTr("Not fixed")]
                currentIndex: isValidStep ? DataManager.stepsModel.getData(currentStep, StepModel.DefectFixStatus) : fixed
                enabled: defectFoundCheck.checked
                onActivated: {
                    if (isValidStep && defectFoundCheck.checked) {
                        DataManager.stepsModel.setDefectFixStatus(currentStep, currentIndex);
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 20
            Layout.alignment: Qt.AlignHCenter
            spacing: 20

            Button {
                Layout.preferredWidth: 140
                Layout.preferredHeight: 40
                text: qsTr("BACK")
                enabled: currentStep > 0
                onClicked: currentStep--
                font.pixelSize: 14
                Material.background: "#e0e0e0"
                Material.foreground: "#000"
            }

            Button {
                Layout.preferredWidth: 140
                Layout.preferredHeight: 40
                text: currentStep < totalSteps - 1 ? qsTr("NEXT") : qsTr("REVIEW")
                enabled: isValidStep
                onClicked: {
                    if (currentStep < totalSteps - 1) {
                        currentStep++;
                    } else {
                        stackView.push("SummaryScreen.qml");
                    }
                }
                font.pixelSize: 14
                Material.background: "#3fb8e0"
                Material.foreground: "#fff"
            }
        }

        Button {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 140
            Layout.preferredHeight: 40
            text: qsTr("CANCEL")
            font.pixelSize: 14
            Material.background: "#e0e0e0"
            Material.foreground: "#000"
            onClicked: {
                DataManager.revoke()
                stackView.pop()
            }
        }

        Text {
            visible: DataManager.error && DataManager.error.length > 0
            text: DataManager.error || ""
            color: "red"
            font.pixelSize: 14
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }
    }
}

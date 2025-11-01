import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "components"
import "styles"

Item {
    id: root

    property var stepsModel: DataManager?.stepsModel ?? null
    readonly property var stepsRoles: stepsModel?.StepRoles ?? {}
    readonly property int totalSteps: stepsModel?.rowCount() ?? 0
    property int currentStep: totalSteps > 0 ? 0 : -1

    property var stackView
    property var toSelectionScreen

    property int dynamicTopMargin: root.height < 800 ? 40 : root.height * 0.15
    property int fontSize: root.height < 800 ? Theme.fontSubtitle : Theme.fontTitle
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
        color: Theme.colorBgPrimary
    }

    ScrollView {
        id: scrollView
        anchors {
            fill: parent
            topMargin: root.dynamicTopMargin
            leftMargin: root.width < 700? 55: root.width*0.15
            rightMargin: root.width < 700? 55: root.width*0.15
            bottomMargin: 30
        }
        clip: true

        contentWidth: availableWidth
        contentHeight: mainColumn.implicitHeight

        ColumnLayout {
            id: mainColumn
            width: scrollView.availableWidth
            spacing: Theme.fontBody

            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 24
                font.bold: true
                color: Theme.colorTextPrimary
                text: qsTr("MAINTENANCE")
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true

                RowLayout {
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        color: Theme.colorAccent
                        radius: 15

                        Text {
                            anchors.centerIn: parent
                            color: Theme.colorTextPrimary
                            text: root.isValidStep ? (root.currentStep + 1).toString() : "0"
                            font.pixelSize: Theme.fontSubtitle
                            font.bold: true
                        }
                    }

                    Text {
                        text: qsTr("Step %1").arg(root.isValidStep ? root.currentStep + 1 : 0)
                        font.pixelSize: Theme.fontSubtitle
                        font.bold: true
                        color: Theme.colorTextPrimary
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: qsTr("%1/%2").arg(root.isValidStep ? root.currentStep + 1 : 0).arg(root.totalSteps)
                    font.pixelSize: Theme.fontBody
                    color: Theme.colorTextMuted
                }
            }

            ProgressBar {
                id: progressbar
                Layout.fillWidth: true
                value: root.totalSteps > 0 ? (root.currentStep + 1) / root.totalSteps : 0
                Layout.preferredHeight: 8
                padding: 0

                contentItem: Item {
                    Rectangle {
                        width: parent.width * progressbar.value
                        height: parent.height
                        color: Theme.colorAccent
                    }
                }

                background: Rectangle {
                    color: Theme.colorSidebar
                    radius: height / 2
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.topMargin: 10
                text: root.isValidStep ? root.stepsModel.getData(root.currentStep, StepModel.TitleRole) : ""
                font.pixelSize: root.fontSize
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                color: Theme.colorTextPrimary
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                CheckBox {
                    id: stepCompletedCheck
                    Layout.alignment: Qt.AlignLeft
                    text: qsTr("Step completed")
                    font.pointSize: 14
                    checked: root.isValidStep && (root.stepsModel.getData(root.currentStep, StepModel.StatusRole) !== root.notStarted)
                    enabled: root.isValidStep
                    Material.foreground: Theme.colorTextPrimary

                    onToggled: {
                        if (!root.isValidStep)
                            return;

                        if (checked) {
                            if (defectFoundCheck.checked) {
                                DataManager.setStepStatus(root.currentStep, root.hasDefect);
                            } else {
                                DataManager.setStepStatus(root.currentStep, root.completed);
                            }
                        } else {
                            DataManager.setStepStatus(root.currentStep, root.notStarted);
                        }
                    }
                }

                CheckBox {
                    id: defectFoundCheck
                    Layout.alignment: Qt.AlignLeft
                    text: qsTr("Damage found")
                    font.pointSize: 14
                    checked: root.isValidStep && (root.stepsModel.getData(root.currentStep, StepModel.StatusRole) === root.hasDefect)
                    enabled: stepCompletedCheck.checked && root.isValidStep
                    Material.foreground: Theme.colorTextPrimary
                    onToggled: {
                        if (!root.isValidStep)
                            return;
                        root.dynamicTopMargin = 70;
                        if (checked) {
                            DataManager.setStepStatus(root.currentStep, root.hasDefect);
                        } else {
                            DataManager.setStepStatus(root.currentStep, root.completed);
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
                    font.pixelSize: Theme.fontBody
                    color: Theme.colorTextPrimary
                }
                RepairMethodEditor {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    text: root.isValidStep ? root.stepsModel.getData(root.currentStep, StepModel.DefectDescriptionRole) : ""
                    placeholderEditText: qsTr("Enter defect description here...")
                    enabled: defectFoundCheck.checked

                    onTextEditChanged: function (newText) {
                        if (root.isValidStep && defectFoundCheck.checked) {
                            root.stepsModel.setDefectDescription(root.currentStep, newText);
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: qsTr("Repair method")
                    font.pixelSize: Theme.fontBody
                    color: Theme.colorTextPrimary
                }
                RepairMethodEditor {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    text: root.isValidStep ? root.stepsModel.getData(root.currentStep, StepModel.DefectRepairMethodRole) : ""
                    placeholderEditText: qsTr("Enter repair method here...")
                    enabled: defectFoundCheck.checked

                    onTextEditChanged: function (newText) {
                        if (root.isValidStep && defectFoundCheck.checked) {
                            root.stepsModel.setDefectRepairMethod(root.currentStep, newText);
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: qsTr("Fix status")
                    font.pixelSize: Theme.fontBody
                    color: Theme.colorTextPrimary
                }

                ComboBox {
                    id: fixStatusCombo
                    Layout.fillWidth: true
                    model: [qsTr("Fixed"), qsTr("Postponed"), qsTr("Not required"), qsTr("Not fixed")]
                    currentIndex: root.isValidStep ? root.stepsModel.getData(root.currentStep, StepModel.DefectFixStatus) : root.fixed
                    enabled: defectFoundCheck.checked
                    Material.background: Theme.colorNavActive
                    Material.foreground: Theme.colorTextPrimary
                    onActivated: {
                        if (root.isValidStep && defectFoundCheck.checked) {
                            root.stepsModel.setDefectFixStatus(root.currentStep, currentIndex);
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
                    enabled: root.currentStep > 0
                    onClicked: root.currentStep--
                    font.pixelSize: 14
                    Material.background: Theme.colorNavActive
                    Material.foreground: Theme.colorTextPrimary
                }

                Button {
                    Layout.preferredWidth: 140
                    Layout.preferredHeight: 40
                    text: root.currentStep < root.totalSteps - 1 ? qsTr("NEXT") : qsTr("REVIEW")
                    enabled: root.isValidStep
                    onClicked: {
                        if (root.currentStep < root.totalSteps - 1) {
                            root.currentStep++;
                        } else {
                            if (root.stackView) {
                                root.stackView.push("Summary.qml", {
                                    stackView: root.stackView,
                                    toSelectionScreen: root.toSelectionScreen
                                });
                            } else {
                                console.error("StackView is null!");
                            }
                        }
                    }
                    font.pixelSize: 14
                    Material.background: Theme.colorAccent
                    Material.foreground: Theme.colorTextPrimary
                }
            }

            Button {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 140
                Layout.preferredHeight: 40
                text: qsTr("CANCEL")
                font.pixelSize: 14
                Material.background: Theme.colorNavActive
                Material.foreground: Theme.colorTextPrimary
                onClicked: {
                    if (DataManager.currentNumberTO() === "TO-2") {
                        root.stackView.pop(StackView.Immediate);
                    } else {
                        DataManager.revoke();
                        root.stackView.clear();
                        root.stackView.push(root.toSelectionScreen);
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                visible: DataManager.error && DataManager.error.length > 0
                text: DataManager.error || ""
                color: Theme.colorError
                font.pixelSize: 14
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }
            
            Item {
                Layout.fillHeight: true
                Layout.minimumHeight: 400
            }
        }
    }
}

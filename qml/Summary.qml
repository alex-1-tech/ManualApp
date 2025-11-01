pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "utils/Utils.js" as Utils
import "styles"

Item {
    id: root

    property var stackView
    property var toSelectionScreen

    Rectangle {
        anchors.fill: parent
        color: Theme.colorBgPrimary
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 24
            font.bold: true
            text: qsTr("SUMMARY")
            horizontalAlignment: Text.AlignHCenter
            color: Theme.colorTextPrimary
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 12

                Repeater {
                    id: repeater
                    model: DataManager.stepsModel.rowCount()
                    ColumnLayout {
                        id: delegate

                        required property int index
                        width: parent.width
                        spacing: 8

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
                                    text: delegate.index + 1
                                    font.pixelSize: 18
                                    font.bold: true
                                }
                            }

                            Text {
                                text: {
                                    var fullText = DataManager.stepsModel.getData(delegate.index, StepModel.TitleRole);
                                    return fullText.length > 45 ? fullText.substring(0, 45) + "..." : fullText;
                                }
                                font.pixelSize: 18
                                font.bold: true
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                                color: Theme.colorTextPrimary
                            }
                        }

                        RowLayout {
                            spacing: 10

                            Text {
                                text: qsTr("Status:")
                                font.pixelSize: 16
                                color: Theme.colorTextMuted
                            }

                            Text {
                                text: Utils.getStatusText(DataManager.stepsModel.getData(delegate.index, StepModel.StatusRole))
                                font.pixelSize: 16
                                font.bold: true
                                color: {
                                    var status = DataManager.stepsModel.getData(delegate.index, StepModel.StatusRole);
                                    if (status === 1)
                                        return Theme.colorSuccess;     // Completed - зелёный
                                    if (status === 2)
                                        return Theme.colorWarning;     // Defect found - оранжевый
                                    if (status === 3)
                                        return Theme.colorNeutral;     // Skipped - серый
                                    return Theme.colorError;           // Not started - красный
                                }
                            }
                        }

                        ColumnLayout {
                            visible: DataManager.stepsModel.getData(delegate.index, StepModel.StatusRole) === 2
                            spacing: 4
                            Layout.fillWidth: true

                            Text {
                                text: qsTr("Damage description:")
                                font.pixelSize: 16
                                color: Theme.colorTextMuted
                            }

                            Text {
                                text: DataManager.stepsModel.getData(delegate.index, StepModel.DefectDescriptionRole) || qsTr("No description")
                                font.pixelSize: 14
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                                padding: 8
                                color: Theme.colorTextPrimary
                            }
                        }

                        ColumnLayout {
                            visible: DataManager.stepsModel.getData(delegate.index, StepModel.StatusRole) === 2 && DataManager.stepsModel.getData(delegate.index, StepModel.DefectRepairMethodRole)
                            spacing: 4
                            Layout.fillWidth: true

                            Text {
                                text: qsTr("Repair method:")
                                font.pixelSize: 16
                                color: Theme.colorTextMuted
                            }

                            Text {
                                text: DataManager.stepsModel.getData(delegate.index, StepModel.DefectRepairMethodRole)
                                font.pixelSize: 14
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                                padding: 8
                                color: Theme.colorTextPrimary
                            }
                        }

                        RowLayout {
                            visible: DataManager.stepsModel.getData(delegate.index, StepModel.StatusRole) === 2
                            spacing: 10

                            Text {
                                text: qsTr("Fix status:")
                                font.pixelSize: 16
                                color: Theme.colorTextMuted
                            }

                            Text {
                                text: Utils.getFixStatusText(DataManager.stepsModel.getData(delegate.index, StepModel.DefectFixStatus))
                                font.pixelSize: 16
                                font.bold: true
                                color: {
                                    var status = DataManager.stepsModel.getData(delegate.index, StepModel.DefectFixStatus);
                                    if (status === 0)
                                        return Theme.colorSuccess;     // Fixed - зелёный
                                    if (status === 3)
                                        return Theme.colorError;       // Not fixed - красный
                                    return Theme.colorWarning;         // Postponed/Not required - оранжевый
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: Theme.colorSidebar
                            Layout.topMargin: 8
                            Layout.bottomMargin: 8
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 20

            Button {
                Layout.preferredWidth: 140
                Layout.preferredHeight: 40
                text: qsTr("BACK")
                onClicked: root.stackView.pop(StackView.Immediate)
                font.pixelSize: 14
                Material.background: Theme.colorNavActive
                Material.foreground: Theme.colorTextPrimary
            }

            Button {
                id: saveButton
                Layout.preferredWidth: 140
                Layout.preferredHeight: 40
                text: qsTr("SAVE")
                onClicked: {
                    if (DataManager.currentNumberTO() === "TO-2") {
                        root.stackView.push("UploadReport.qml", {
                            mode: "after",
                            stackView: root.stackView
                        }, StackView.Immediate);
                    }else {
                        root.stackView.push("UploadWindow.qml", {
                            stackView: root.stackView
                        }, StackView.Immediate);
                    }
                }
                font.pixelSize: 14
                Material.background: Theme.colorAccent
                Material.foreground: Theme.colorTextPrimary
            }
        }
    }
}

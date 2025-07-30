import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import datamanager.Models 1.0
import ManualApp.Core 1.0

Item {

    // Локальные функции для преобразования статусов в текст
    function getStatusText(status) {
        switch(status) {
            case 0: return qsTr("Not started");
            case 1: return qsTr("Completed");
            case 2: return qsTr("Defect found");
            case 3: return qsTr("Skipped");
            default: return qsTr("Unknown");
        }
    }

    function getFixStatusText(fixStatus) {
        switch(fixStatus) {
            case 0: return qsTr("Fixed");
            case 1: return qsTr("Postponed");
            case 2: return qsTr("Not required");
            case 3: return qsTr("Not fixed");
            default: return qsTr("Unknown");
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // Заголовок
        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 24
            font.bold: true
            text: qsTr("SUMMARY")
            horizontalAlignment: Text.AlignHCenter
        }

        // Список шагов
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 12

                Repeater {
                    model: DataManager.stepsModel.rowCount()

                    ColumnLayout {
                        width: parent.width
                        spacing: 8

                        // Номер шага и заголовок
                        RowLayout {
                            spacing: 10

                            Rectangle {
                                width: 30
                                height: 30
                                color: "#000000"
                                radius: 15

                                Text {
                                    anchors.centerIn: parent
                                    color: "#ffffff"
                                    text: index + 1
                                    font.pixelSize: 18
                                    font.bold: true
                                }
                            }

                            Text {
                                text: DataManager.stepsModel.getData(index, StepModel.TitleRole)
                                font.pixelSize: 18
                                font.bold: true
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }

                        // Статус выполнения
                        RowLayout {
                            spacing: 10

                            Text {
                                text: qsTr("Status:") + " "
                                font.pixelSize: 16
                                color: "#555555"
                            }

                            Text {
                                text: getStatusText(DataManager.stepsModel.getData(index, StepModel.StatusRole))
                                font.pixelSize: 16
                                font.bold: true
                                color: {
                                    var status = DataManager.stepsModel.getData(index, StepModel.StatusRole)
                                    if (status === 1) return "#4CAF50"     // Completed - зеленый
                                    if (status === 2) return "#FF9800"     // Defect found - оранжевый
                                    if (status === 3) return "#9E9E9E"     // Skipped - серый
                                    return "#f44336"                       // Not started - красный
                                }
                            }
                        }

                        // Описание дефекта (если есть)
                        ColumnLayout {
                            visible: DataManager.stepsModel.getData(index, StepModel.StatusRole) === 2
                            spacing: 4
                            Layout.fillWidth: true

                            Text {
                                text: qsTr("Defect description:")
                                font.pixelSize: 16
                                color: "#555555"
                            }

                            Text {
                                text: DataManager.stepsModel.getData(index, StepModel.DefectDescriptionRole) || qsTr("No description")
                                font.pixelSize: 14
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                                padding: 8
                            }
                        }

                        // Метод ремонта (если есть)
                        ColumnLayout {
                            visible: DataManager.stepsModel.getData(index, StepModel.StatusRole) === 2 && 
                                     DataManager.stepsModel.getData(index, StepModel.DefectRepairMethodRole)
                            spacing: 4
                            Layout.fillWidth: true

                            Text {
                                text: qsTr("Repair method:")
                                font.pixelSize: 16
                                color: "#555555"
                            }

                            Text {
                                text: DataManager.stepsModel.getData(index, StepModel.DefectRepairMethodRole)
                                font.pixelSize: 14
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                                padding: 8
                            }
                        }

                        // Статус исправления дефекта
                        RowLayout {
                            visible: DataManager.stepsModel.getData(index, StepModel.StatusRole) === 2
                            spacing: 10

                            Text {
                                text: qsTr("Fix status:") + " "
                                font.pixelSize: 16
                                color: "#555555"
                            }

                            Text {
                                text: getFixStatusText(DataManager.stepsModel.getData(index, StepModel.DefectFixStatus))
                                font.pixelSize: 16
                                font.bold: true
                                color: {
                                    var status = DataManager.stepsModel.getData(index, StepModel.DefectFixStatus)
                                    if (status === 0) return "#4CAF50"     // Fixed - зеленый
                                    if (status === 3) return "#f44336"     // Not fixed - красный
                                    return "#FF9800"                       // Postponed/Not required - оранжевый
                                }
                            }
                        }

                        // Разделитель
                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: "#e0e0e0"
                            Layout.topMargin: 8
                            Layout.bottomMargin: 8
                        }
                    }
                }
            }
        }

        // Кнопки
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 20

            Button {
                Layout.preferredWidth: 140
                Layout.preferredHeight: 40
                text: qsTr("BACK")
                onClicked: stackView.pop()
                font.pixelSize: 14
                Material.background: "#e0e0e0"
                Material.foreground: "#000000"
            }

            Button {
                Layout.preferredWidth: 140
                Layout.preferredHeight: 40
                text: qsTr("SAVE")
                onClicked: {
                    DataManager.save(false);
                    stackView.clear();
                    stackView.push(toSelectionScreen);
                }
                font.pixelSize: 14
                Material.background: "#4CAF50"
                Material.foreground: "#ffffff"
            }
        }
    }
}
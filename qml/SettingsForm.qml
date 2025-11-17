pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "styles"
import "components"

ScrollView {
    id: root

    clip: true

    signal settingsCompleted

    contentItem: Flickable {
        id: flick
        anchors.fill: parent
        clip: true
        contentHeight: formContainer.implicitHeight
        contentWidth: width

        ColumnLayout {
            id: formContainer
            width: root.width > 1100 ? 1000 : root.width * 0.92
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10
            spacing: 20

            // Заголовок с информацией о выбранной модели
            RowLayout {
                Layout.fillWidth: true
                spacing: 15

                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: 20
                    color: Theme.colorButtonPrimary

                    Text {
                        text: SettingsManager.currentModel === "kalmar32" ? "K" : "F"
                        color: "white"
                        font.pointSize: 16
                        font.bold: true
                        anchors.centerIn: parent
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true

                    Text {
                        text: SettingsManager.currentModel === "kalmar32" ? qsTr("KALMAR-32 Configuration") : qsTr("PHASAR-32 Configuration")
                        color: Theme.colorTextPrimary
                        font.pointSize: 24
                        font.bold: true
                    }

                    Text {
                        text: qsTr("Current model: %1").arg(SettingsManager.currentModel)
                        color: Theme.colorTextSecondary
                        font.pointSize: Theme.fontSmall
                    }
                }
            }

            // ОБЩИЕ ПОЛЯ ДЛЯ ВСЕХ МОДЕЛЕЙ
            CardSection {
                title: qsTr("Registration data")

                FormField {
                    label: qsTr("Serial number")
                    placeholder: qsTr("serial number of equipment")
                    settingName: "serialNumber"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("Case number")
                    placeholder: qsTr("serial number of equipment storage case")
                    settingName: "caseNumber"
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    ModelSettingDate {
                        label: "Shipment date"
                        settingName: "shipmentDate"
                        modelSettings: SettingsManager
                    }
                }
            }

            // ПОЛЯ ДЛЯ KALMAR-32
            ColumnLayout {
                visible: SettingsManager.isKalmar32()
                spacing: 20
                Layout.fillWidth: true

                CardSection {
                    title: qsTr("PC Tablet Components")

                    FormField {
                        label: qsTr("PC tablet Latitude Dell 7230")
                        placeholder: qsTr("serial number of PC tablet Latitude Dell 7230")
                        settingName: "pcTabletDell7230"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("AC/DC Power adapter for Dell 7230")
                        placeholder: qsTr("serial number of AC/DC Power adapter for Dell 7230")
                        settingName: "acDcPowerAdapterDell"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("DC Charger adapter for Dell 7230 from battery")
                        placeholder: qsTr("serial number of DC Charger adapter for Dell 7230 from battery")
                        settingName: "dcChargerAdapterBattery"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }
                }

                CardSection {
                    title: qsTr("Ultrasonic Equipment")

                    FormField {
                        label: qsTr("Ultrasonic phased array PULSAR OEM 16/64 established")
                        placeholder: qsTr("serial number of Ultrasonic phased array PULSAR OEM 16/64 established")
                        settingName: "ultrasonicPhasedArrayPulsar"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Left probs RA2.25L16 1.1x10-17")
                        placeholder: qsTr("serial number of Left probs RA2.25L16 1.1x10-17")
                        settingName: "leftProbs"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Production date Left probs RA2.25L16 1.1x10-17")
                        placeholder: qsTr("Production date of left probs RA2.25L16 1.1x10-17")
                        settingName: "leftProbsDate"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Right probs RA2.25L16 1.1x10-17")
                        placeholder: qsTr("serial number of Right probs RA2.25L16 1.1x10-17")
                        settingName: "rightProbs"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Production date right probs RA2.25L16 1.1x10-17")
                        placeholder: qsTr("Production date of right probs RA2.25L16 1.1x10-17")
                        settingName: "rightProbsDate"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Manual probs RA2.25L16 0.9x10-17")
                        placeholder: qsTr("serial number of Manual probs RA2.25L16 0.9x10-17")
                        settingName: "manualProbs"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Production date Manual probs RA2.25L16 0.9x10-17")
                        placeholder: qsTr("Production date of manual probs RA2.25L16 0.9x10-17")
                        settingName: "manualProbsDate"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Straight probs RA5.0L16 0.6x10-12")
                        placeholder: qsTr("serial number of Straight probs RA5.0L16 0.6x10-12")
                        settingName: "straightProbs"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Production date Straight probs RA5.0L16 0.6x10-12")
                        placeholder: qsTr("Production date of straight probs RA5.0L16 0.6x10-12")
                        settingName: "straightProbsDate"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Label {
                            Layout.preferredWidth: root.width < 700 ? 280 : 450
                            text: qsTr("DC Cable from Battery")
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        ModelSettingCheckBox {
                            settingName: "hasDcCableBattery"
                            modelSettings: SettingsManager.kalmarSettings
                            text: qsTr("Included")
                            Layout.columnSpan: 1
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Label {
                            Layout.preferredWidth: root.width < 700 ? 280 : 450
                            text: qsTr("Ethernet Cables")
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        ModelSettingCheckBox {
                            settingName: "hasEthernetCables"
                            modelSettings: SettingsManager.kalmarSettings
                            text: qsTr("Included")
                            Layout.columnSpan: 1
                        }
                    }
                }

                CardSection {
                    title: qsTr("Battery and Charging")

                    FormField {
                        label: qsTr("DC Battery box established")
                        placeholder: qsTr("serial number of DC Battery box established")
                        settingName: "dcBatteryBox"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("AC/DC Charger adapter for battery 2")
                        placeholder: qsTr("serial number of AC/DC Charger adapter for battery 2")
                        settingName: "acDcChargerAdapterBattery"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }
                }

                CardSection {
                    title: qsTr("Calibration and Tools")

                    FormField {
                        label: qsTr("Calibration bloc SO-3R")
                        placeholder: qsTr("serial number of Calibration bloc SO-3R")
                        settingName: "calibrationBlockSo3r"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Label {
                            Layout.preferredWidth: root.width < 700 ? 280 : 450
                            text: qsTr("Small repair tool witch bag")
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        ModelSettingCheckBox {
                            settingName: "hasRepairToolBag"
                            modelSettings: SettingsManager.kalmarSettings
                            text: qsTr("Included")
                            Layout.columnSpan: 1
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Label {
                            Layout.preferredWidth: root.width < 700 ? 280 : 450
                            text: qsTr("Installed nameplate with serial number")
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        ModelSettingCheckBox {
                            settingName: "hasInstalledNameplate"
                            modelSettings: SettingsManager.kalmarSettings
                            text: qsTr("Installed")
                            Layout.columnSpan: 1
                        }
                    }
                }
            }

            // ПОЛЯ ДЛЯ PHASAR-32
            ColumnLayout {
                visible: SettingsManager.isPhasar32()
                spacing: 20
                Layout.fillWidth: true

                CardSection {
                    title: qsTr("PC Tablet Components")

                    FormField {
                        label: qsTr("PC tablet Latitude Dell 7230")
                        placeholder: qsTr("serial number of PC tablet Latitude Dell 7230")
                        settingName: "pcTabletDell7230"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Personalised name tag")
                        placeholder: qsTr("personalised name tag details")
                        settingName: "personalisedNameTag"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("AC/DC Power adapter for Dell 7230")
                        placeholder: qsTr("serial number of AC/DC Power adapter for Dell 7230")
                        settingName: "acDcPowerAdapterDell"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("DC Charger adapter for Dell 7230 from battery")
                        placeholder: qsTr("serial number of DC Charger adapter for Dell 7230 from battery")
                        settingName: "dcChargerAdapterBattery"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }
                }

                                CardSection {
                    title: qsTr("Ultrasonic Equipment")

                    FormField {
                        label: qsTr("Ultrasonic phased array PULSAR OEM 16/128 established")
                        placeholder: qsTr("serial number of Ultrasonic phased array PULSAR OEM 16/128 established")
                        settingName: "ultrasonicPhasedArrayPulsar"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("DCN P112-2,5-F")
                        placeholder: qsTr("serial number of DCN P112-2,5-F")
                        settingName: "dcn"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Production date DCN P112-2,5-F")
                        placeholder: qsTr("Production date of DCN P112-2,5-F")
                        settingName: "dcnDate"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("AB-back PA2,5L16 1,1x10-17-F")
                        placeholder: qsTr("serial number of AB-back PA2,5L16 1,1x10-17-F")
                        settingName: "abBack"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Production date AB-back PA2,5L16 1,1x10-17-F")
                        placeholder: qsTr("Production date of AB-back PA2,5L16 1,1x10-17-F")
                        settingName: "abBackDate"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("GF combo 2PA2,5L16 0,6x10-10-F")
                        placeholder: qsTr("serial number of GF combo 2PA2,5L16 0,6x10-10-F")
                        settingName: "gfCombo"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Production date GF combo 2PA2,5L16 0,6x10-10-F")
                        placeholder: qsTr("Production date of GF combo 2PA2,5L16 0,6x10-10-F")
                        settingName: "gfComboDate"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("FF combo 2PA2,5L16 0,6x10-10-F")
                        placeholder: qsTr("serial number of FF combo 2PA2,5L16 0,6x10-10-F")
                        settingName: "ffCombo"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Production date FF combo 2PA2,5L16 0,6x10-10-F")
                        placeholder: qsTr("Production date of FF combo 2PA2,5L16 0,6x10-10-F")
                        settingName: "ffComboDate"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("AB-front PA2,5L16 1,1x10-17-F")
                        placeholder: qsTr("serial number of AB-front PA2,5L16 1,1x10-17-F")
                        settingName: "abFront"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Production date AB-front PA2,5L16 1,1x10-17-F")
                        placeholder: qsTr("Production date of AB-front PA2,5L16 1,1x10-17-F")
                        settingName: "abFrontDate"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Flange 50 P112-0,6-50-F")
                        placeholder: qsTr("serial number of Flange 50 P112-0,6-50-F")
                        settingName: "flange50"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Production date Flange 50 P112-0,6-50-F")
                        placeholder: qsTr("Production date of Flange 50 P112-0,6-50-F")
                        settingName: "flange50Date"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Manual probs PA2.25L16 0.9x10-17")
                        placeholder: qsTr("serial number of Manual probs PA2.25L16 0.9x10-17")
                        settingName: "manualProbs"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Production date Manual probs PA2.25L16 0.9x10-17")
                        placeholder: qsTr("Production date of Manual probs PA2.25L16 0.9x10-17")
                        settingName: "manualProbsDate"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Label {
                            Layout.preferredWidth: root.width < 700 ? 280 : 450
                            text: qsTr("DC Cable from Battery")
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        ModelSettingCheckBox {
                            settingName: "hasDcCableBattery"
                            modelSettings: SettingsManager.phasarSettings
                            text: qsTr("Included")
                            Layout.columnSpan: 1
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Label {
                            Layout.preferredWidth: root.width < 700 ? 280 : 450
                            text: qsTr("Ethernet Cables")
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        ModelSettingCheckBox {
                            settingName: "hasEthernetCables"
                            modelSettings: SettingsManager.phasarSettings
                            text: qsTr("Included")
                            Layout.columnSpan: 1
                        }
                    }
                }

                CardSection {
                    title: qsTr("Additional Equipment")

                    FormField {
                        label: qsTr("Water tank with a tap")
                        placeholder: qsTr("Water tank details")
                        settingName: "waterTankWithTap"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("DC Battery box established")
                        placeholder: qsTr("serial number of DC Battery box established")
                        settingName: "dcBatteryBox"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("AC/DC Charger adapter for battery")
                        placeholder: qsTr("serial number of AC/DC Charger adapter for battery")
                        settingName: "acDcChargerAdapterBattery"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }
                }

                CardSection {
                    title: qsTr("Calibration and Tools")

                    FormField {
                        label: qsTr("Calibration bloc SO-3R")
                        placeholder: qsTr("serial number of Calibration bloc SO-3R")
                        settingName: "calibrationBlockSo3r"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Label {
                            Layout.preferredWidth: root.width < 700 ? 280 : 450
                            text: qsTr("Small repair tool with bag")
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        ModelSettingCheckBox {
                            settingName: "hasRepairToolBag"
                            modelSettings: SettingsManager.phasarSettings
                            text: qsTr("Included")
                            Layout.columnSpan: 1
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Label {
                            Layout.preferredWidth: root.width < 700 ? 280 : 450
                            text: qsTr("Installed nameplate with serial number")
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        ModelSettingCheckBox {
                            settingName: "hasInstalledNameplate"
                            modelSettings: SettingsManager.phasarSettings
                            text: qsTr("Installed")
                            Layout.columnSpan: 1
                        }
                    }
                }
            }
            // Network settings
            CardSection {
                title: qsTr("Network settings")

                FormField {
                    label: qsTr("Wifi router address")
                    placeholder: qsTr("IP or hostname of the router")
                    settingName: "wifiRouterAddress"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("Windows password")
                    placeholder: qsTr("Enter Windows user password")
                    settingName: "windowsPassword"
                    Layout.fillWidth: true
                }
            }

            // ОБЩИЕ ПОЛЯ (для всех моделей)
            CardSection {
                title: qsTr("Additional Information")

                FormField {
                    label: qsTr("Notes")
                    placeholder: qsTr("Additional notes and comments")
                    settingName: "notes"
                    Layout.fillWidth: true
                    multiline: true
                }
            }

            Button {
                id: button
                text: qsTr("Save")
                font.pixelSize: 18
                onClicked: confirmDialog.open()
                Layout.preferredWidth: 240
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignHCenter

                background: Rectangle {
                    color: button.enabled ? (button.pressed ? Theme.colorButtonPrimaryHover : Theme.colorButtonPrimary) : Theme.colorButtonDisabled
                    radius: 4
                }

                contentItem: Text {
                    text: button.text
                    font.pixelSize: 18
                    color: "white"
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.minimumHeight: 400
            }
        }

        // Диалог подтверждения сохранения
        Popup {
            id: confirmDialog
            modal: true
            focus: true
            width: 400
            height: 180
            anchors.centerIn: Overlay.overlay
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            background: Rectangle {
                color: Theme.colorBgPrimary
                radius: 8
                border.color: Theme.colorBorder
                border.width: 1
            }

            contentItem: ColumnLayout {
                spacing: 20

                Label {
                    text: qsTr("Save confirmation")
                    font.bold: true
                    font.pointSize: Theme.fontSubtitle
                    color: Theme.colorTextPrimary
                    Layout.fillWidth: true
                }

                Label {
                    text: qsTr("Are you sure you want to save the settings?\nAfter saving, some of them cannot be changed.")
                    wrapMode: Text.WordWrap
                    color: Theme.colorTextSecondary
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Button {
                        id: cancelButton
                        text: "Cancel"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 35

                        background: Rectangle {
                            color: cancelButton.pressed ? Theme.colorButtonSecondaryHover : Theme.colorButtonSecondary
                            radius: Theme.radiusButton
                        }

                        contentItem: Text {
                            text: cancelButton.text
                            color: Theme.colorTextPrimary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pointSize: Theme.fontSmall
                        }

                        onClicked: confirmDialog.close()
                    }

                    Button {
                        id: okButton
                        text: "OK"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 35

                        background: Rectangle {
                            color: okButton.pressed ? Theme.colorButtonPrimaryHover : Theme.colorButtonPrimary
                            radius: Theme.radiusButton
                        }

                        contentItem: Text {
                            text: okButton.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pointSize: Theme.fontSmall
                        }

                        onClicked: {
                            // SettingsManager.saveAllSettings();
                            SettingsManager.saveModelSettings();
                            root.settingsCompleted();
                            confirmDialog.close();
                        }
                    }
                }
            }
        }
    }
}

pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "components"
import "styles"

ScrollView {
    id: root

    clip: true
    anchors.fill: parent

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

            // Заголовок
            RowLayout {
                Layout.leftMargin: 50
                Image {
                    source: "qrc:///media/icons/icon-settings.svg"
                    sourceSize.width: 40
                    sourceSize.height: 40
                }

                Text {
                    text: qsTr("Settings")
                    color: Theme.colorTextPrimary
                    font.pointSize: 24
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
                        label: qsTr("Manual probs 36° RA2.25L16 0.9x10-17")
                        placeholder: qsTr("serial number of Manual probs 36° RA2.25L16 0.9x10-17")
                        settingName: "manualProbs36"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Straight probs 0° RA5.0L16 0.6x10-17")
                        placeholder: qsTr("serial number of Straight probs 0° RA5.0L16 0.6x10-17")
                        settingName: "straightProbs0"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
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
                        label: qsTr("Manual probs 36° RA2.25L16 0.9x10-17")
                        placeholder: qsTr("serial number of Manual probs 36° RA2.25L16 0.9x10-17")
                        settingName: "manualProbs36"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
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
                            SettingsManager.saveModelSettings()
                            if(SettingsManager.currentModel == "kalmar32")
                                DataManager.uploadSettingsToDjango(DataManager.djangoBaseUrl() + "/api/kalmar32/");
                            else
                                DataManager.uploadSettingsToDjango(DataManager.djangoBaseUrl() + "/api/phasar32/");
                            confirmDialog.close();
                        }
                    }
                }
            }
        }
    }
}

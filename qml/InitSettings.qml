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

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Text {
                    text: qsTr("Enter characteristics")
                    color: Theme.colorTextPrimary
                    font.pointSize: 24
                }
            }
            CardSection {
                title: qsTr("Registration data")

                FormField {
                    label: qsTr("Serial number:")
                    placeholder: qsTr("Unique equipment serial number")
                    settingName: "serialNumber"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("Case number:")
                    placeholder: qsTr("Equipment storage case number")
                    settingName: "caseNumber"
                    Layout.fillWidth: true
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Label {
                        Layout.preferredWidth: 250
                        text: qsTr("Shipment date:")
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSmall
                    }

                    NewDateField {
                        shipmentDate: SettingsManager.shipmentDate
                        onShipmentDateChanged: SettingsManager.shipmentDate = shipmentDate
                    }
                }
            }
            CardSection {
                title: qsTr("PC Tablet Components")

                FormField {
                    label: qsTr("PC Tablet Dell 7230:")
                    placeholder: qsTr("PC tablet Latitude Dell 7230")
                    settingName: "pcTabletDell7230"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("AC/DC Power Adapter Dell:")
                    placeholder: qsTr("AC/DC power adapter for Dell 7230")
                    settingName: "acDcPowerAdapterDell"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("DC Charger Adapter Battery:")
                    placeholder: qsTr("DC charger adapter for Dell 7230 from battery")
                    settingName: "dcChargerAdapterBattery"
                    Layout.fillWidth: true
                }
            }

            CardSection {
                title: qsTr("Ultrasonic Equipment")

                FormField {
                    label: qsTr("Ultrasonic Phased Array PULSAR:")
                    placeholder: qsTr("Ultrasonic phased array PULSAR OEM 16/64")
                    settingName: "ultrasonicPhasedArrayPulsar"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("Manual Probe 36°:")
                    placeholder: qsTr("Manual probe 36° RA2.25L16 0.9x10-17")
                    settingName: "manualProbs36"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("Straight Probe 0°:")
                    placeholder: qsTr("Straight probe 0° RA5.0L16 0.6x10-17")
                    settingName: "straightProbs0"
                    Layout.fillWidth: true
                }
            }

            CardSection {
                title: qsTr("Cables and Accessories")

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Label {
                        Layout.preferredWidth: 250
                        text: qsTr("DC Cable from Battery:")
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSmall
                    }

                    SettingCheckBox {
                        settingName: "hasDcCableBattery"
                        text: qsTr("Included")
                        Layout.columnSpan: 1
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Label {
                        Layout.preferredWidth: 250
                        text: qsTr("Ethernet Cables:")
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSmall
                    }

                    SettingCheckBox {
                        settingName: "hasEthernetCables"
                        text: qsTr("Included")
                        Layout.columnSpan: 1
                    }
                }

                FormField {
                    label: qsTr("DC Battery Box:")
                    placeholder: qsTr("DC battery box")
                    settingName: "dcBatteryBox"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("AC/DC Charger Adapter Battery:")
                    placeholder: qsTr("AC/DC charger adapter for battery")
                    settingName: "acDcChargerAdapterBattery"
                    Layout.fillWidth: true
                }
            }

            CardSection {
                title: qsTr("Calibration and Tools")

                FormField {
                    label: qsTr("Calibration Block SO-3R:")
                    placeholder: qsTr("Calibration block SO-3R")
                    settingName: "calibrationBlockSo3r"
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Label {
                        Layout.preferredWidth: 250
                        text: qsTr("Repair Tool Bag:")
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSmall
                    }

                    SettingCheckBox {
                        settingName: "hasRepairToolBag"
                        text: qsTr("Included")
                        Layout.columnSpan: 1
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Label {
                        Layout.preferredWidth: 250
                        text: qsTr("Installed Nameplate:")
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSmall
                    }

                    SettingCheckBox {
                        settingName: "hasInstalledNameplate"
                        text: qsTr("Installed")
                        Layout.columnSpan: 1
                    }
                }
            }

            CardSection {
                title: qsTr("Additional Information")

                FormField {
                    label: qsTr("Notes:")
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
        Dialog {
            id: confirmDialog
            modal: true
            title: qsTr("Save confirmation")
            standardButtons: Dialog.Ok | Dialog.Cancel
            anchors.centerIn: Overlay.overlay
            width: 400

            background: Rectangle {
                color: Theme.colorBgPrimary
                radius: 5
                border.color: Theme.colorBorder
            }
            contentItem: ColumnLayout {
                spacing: 20

                Label {
                    text: qsTr("Are you sure you want to save the settings?\nAfter saving, some of them cannot be changed.")
                    wrapMode: Text.WordWrap
                    color: Theme.colorTextPrimary
                    Layout.fillWidth: true
                }
            }

            onAccepted: {
                root.settingsCompleted();
            }
        }
    }
}
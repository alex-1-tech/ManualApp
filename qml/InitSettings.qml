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
                    Label {
                        Layout.preferredWidth: root.width < 700? 280: 450
                        text: qsTr("Shipment date")
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
                    label: qsTr("PC tablet Latitude Dell 7230")
                    placeholder: qsTr("serial number of PC tablet Latitude Dell 7230")
                    settingName: "pcTabletDell7230"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("AC/DC Power adapter for Dell 7230")
                    placeholder: qsTr("serial number of AC/DC Power adapter for Dell 7230")
                    settingName: "acDcPowerAdapterDell"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("DC Charger adapter for Dell 7230 from battery")
                    placeholder: qsTr("serial number of DC Charger adapter for Dell 7230 from battery")
                    settingName: "dcChargerAdapterBattery"
                    Layout.fillWidth: true
                }
            }

            CardSection {
                title: qsTr("Ultrasonic Equipment")

                FormField {
                    label: qsTr("Ultrasonic phased array PULSAR OEM 16/64 established")
                    placeholder: qsTr("serial number of Ultrasonic phased array PULSAR OEM 16/64 established")
                    settingName: "ultrasonicPhasedArrayPulsar"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("Manual probs 36° RA2.25L16 0.9x10-17")
                    placeholder: qsTr("serial number of Manual probs 36° RA2.25L16 0.9x10-17")
                    settingName: "manualProbs36"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("Straight probs 0° RA5.0L16 0.6x10-17")
                    placeholder: qsTr("serial number of Straight probs 0° RA5.0L16 0.6x10-17")
                    settingName: "straightProbs0"
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Label {
                        Layout.preferredWidth: root.width < 700? 280: 450
                        text: qsTr("DC Cable from Battery")
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
                        Layout.preferredWidth: root.width < 700? 280: 450
                        text: qsTr("Ethernet Cables")
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSmall
                    }

                    SettingCheckBox {
                        settingName: "hasEthernetCables"
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
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("AC/DC Charger adapter for battery 2")
                    placeholder: qsTr("serial number of AC/DC Charger adapter for battery 2")
                    settingName: "acDcChargerAdapterBattery"
                    Layout.fillWidth: true
                }

                
            }

            CardSection {
                title: qsTr("Calibration and Tools")

                FormField {
                    label: qsTr("Calibration bloc SO-3R")
                    placeholder: qsTr("serial number of Calibration bloc SO-3R")
                    settingName: "calibrationBlockSo3r"
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Label {
                        Layout.preferredWidth: root.width < 700? 280: 450
                        text: qsTr("Small repair tool witch bag")
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
                        Layout.preferredWidth: root.width < 700? 280: 450
                        text: qsTr("Installed nameplate with serial number")
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
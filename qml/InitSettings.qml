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
                title: qsTr("Main components")

                FormField {
                    label: qsTr("Probe PA2.25L16 1.1х10-17:")
                    placeholder: qsTr("S/N of left phased array probe")
                    settingName: "firstPhasedArrayConverters"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("Probe PA2.25L16 1.1х10-17:")
                    placeholder: qsTr("S/N of right phased array probe")
                    settingName: "secondPhasedArrayConverters"
                    Layout.fillWidth: true
                }
                FormField {
                    label: qsTr("Battery case:")
                    placeholder: qsTr("Battery case serial number")
                    settingName: "batteryCase"
                    Layout.fillWidth: true
                }
            }

            CardSection {
                title: qsTr("Blocks and modules")

                FormField {
                    label: qsTr("AOS block:")
                    placeholder: qsTr("AOS block serial number")
                    settingName: "aosBlock"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("Flash drive:")
                    placeholder: qsTr("Flash drive serial number")
                    settingName: "flashDrive"
                    Layout.fillWidth: true
                }
                FormField {
                    label: qsTr("CO-3R:")
                    placeholder: qsTr("CO-3R serial number")
                    settingName: "coThreeRMeasure"
                    Layout.fillWidth: true
                }
            }

            CardSection {
                title: qsTr("Certification and checks")

                FormField {
                    label: qsTr("Calibration certificate:")
                    placeholder: qsTr("Calibration certificate number")
                    settingName: "calibrationCertificate"
                    Layout.fillWidth: true
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Label {
                        Layout.preferredWidth: 250
                        text: qsTr("Calibration date:")
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSmall
                    }

                    NewDateField {
                        shipmentDate: SettingsManager.calibrationDate
                        onShipmentDateChanged: SettingsManager.calibrationDate = shipmentDate
                    }
                }
            }

            CardSection {
                title: qsTr("Spare parts kit")

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Label {
                        Layout.preferredWidth: 250
                        text: qsTr("Tablet screws:")
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSmall
                    }

                    SettingCheckBox {
                        settingName: "hasTabletScrews"
                        text: qsTr("Included")
                        Layout.columnSpan: 1
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Label {
                        Layout.preferredWidth: 250
                        text: qsTr("Ethernet cable:")
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSmall
                    }

                    SettingCheckBox {
                        settingName: "hasEthernetCable"
                        text: qsTr("Included")
                        Layout.columnSpan: 1
                    }
                }

                FormField {
                    label: qsTr("Battery charger:")
                    placeholder: qsTr("Battery charger serial number")
                    settingName: "batteryCharger"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("Tablet charger:")
                    placeholder: qsTr("Tablet charger serial number")
                    settingName: "tabletCharger"
                    Layout.fillWidth: true
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Label {
                        Layout.preferredWidth: 250
                        text: qsTr("Tool kit:")
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSmall
                    }

                    SettingCheckBox {
                        settingName: "hasToolKit"
                        text: qsTr("Included")
                        Layout.columnSpan: 1
                    }
                }
            }
            CardSection {
                title: qsTr("Additional components")

                FormField {
                    label: qsTr("Manual angle beam probe:")
                    placeholder: qsTr("Manual angle beam probe serial number")
                    settingName: "manualInclined"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("Normal probe:")
                    placeholder: qsTr("Normal probe serial number")
                    settingName: "straight"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("Photo URL:")
                    placeholder: qsTr("Link to photos")
                    settingName: "photoUrl"
                    Layout.fillWidth: true
                }
            }
            CardSection {
                title: qsTr("Inspection and documentation")

                FormField {
                    label: qsTr("Software check:")
                    placeholder: qsTr("Software version and status")
                    settingName: "softwareCheck"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("Photo/Video URL:")
                    placeholder: qsTr("Link to media materials")
                    settingName: "photoVideoUrl"
                    Layout.fillWidth: true
                }
                FormField {
                    label: qsTr("Weight (kg):")
                    placeholder: qsTr("Total equipment weight")
                    settingName: "weight"
                    Layout.fillWidth: true

                    validator: DoubleValidator {
                        bottom: 0
                        decimals: 2
                    }
                }

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
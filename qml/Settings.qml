pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "components"
import "styles"

ScrollView {
    id: root

    anchors.fill: parent
    contentWidth: availableWidth
    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 20

        RowLayout {
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
        }

        Item {
            Layout.fillHeight: true
            Layout.minimumHeight: 400
        }
    }
}
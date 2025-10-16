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
        CardSection {
            title: qsTr("PC Tablet Components")

            FormField {
                label: qsTr("PC tablet Latitude Dell 7230")
                placeholder: qsTr("serial number of PC tablet Latitude Dell 7230")
                settingName: "pcTabletDell7230"
                Layout.fillWidth: true
            }

            FormField {
                label: qsTr("Installation of software")
                placeholder: qsTr("serial number of Installation of software")
                settingName: "installationOfSoftware"
                Layout.fillWidth: true
            }

            FormField {
                label: qsTr("Personalised name tag")
                placeholder: qsTr("serial number of Personalised name tag")
                settingName: "personalisedNameTag"
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
        }

        Item {
            Layout.fillHeight: true
            Layout.minimumHeight: 400
        }
    }
}
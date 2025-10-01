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
            title: qsTr("Spare parts kit")

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
        }

        Item {
            Layout.fillHeight: true
            Layout.minimumHeight: 400
        }
    }
}
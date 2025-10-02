pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "styles"

ScrollView {
    id: root

    anchors.fill: parent
    contentWidth: availableWidth
    clip: true

    ColumnLayout {
        id: mainColumn
        anchors.fill: parent
        anchors.margins: 10
        spacing: 20

        // Header
        RowLayout {
            Image {
                source: "qrc:///media/icons/icon-about.svg"
                sourceSize.width: 40
                sourceSize.height: 40
                mipmap: true
            }

            Text {
                text: qsTr("About")
                color: Theme.colorTextPrimary
                font.pointSize: 24
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 10

            Text {
                text: qsTr("App version: ")
                color: Theme.colorTextMuted
                font.pointSize: 12
            }

            Text {
                text: DataManager.appVersion()
                color: Theme.colorTextPrimary
                font.pointSize: 12
            }
        }
        // Helper function for date formatting
        function formatDate(date) {
            if (!date || isNaN(date))
                return "";
            const d = new Date(date);
            return isNaN(d.getTime()) ? "" : d.toLocaleDateString(Qt.locale(), "dd.MM.yyyy");
        }

        // Helper function for status display
        function getStatusText(value) {
            return value ? qsTr("+") : qsTr("-");
        }

        // Section: Registration data
        SectionView {
            title: qsTr("Registration data")
            model: [
                {
                    label: qsTr("Serial number:"),
                    value: SettingsManager.serialNumber
                },
                {
                    label: qsTr("Shipment date:"),
                    value: mainColumn.formatDate(SettingsManager.shipmentDate)
                },
                {
                    label: qsTr("Case number:"),
                    value: SettingsManager.caseNumber
                }
            ]
        }

        // Section: Main components
        SectionView {
            title: qsTr("Main components")
            model: [
                {
                    label: qsTr("Probe PA2.25L16 1.1х10-17:"),
                    value: SettingsManager.firstPhasedArrayConverters,
                    hint: qsTr("Left probe S/N")
                },
                {
                    label: qsTr("Probe PA2.25L16 1.1х10-17:"),
                    value: SettingsManager.secondPhasedArrayConverters,
                    hint: qsTr("Right probe S/N")
                },
                {
                    label: qsTr("Battery case:"),
                    value: SettingsManager.batteryCase,
                    hint: qsTr("Case serial number")
                }
            ]
        }

        // Section: Blocks and modules
        SectionView {
            title: qsTr("Blocks and modules")
            model: [
                {
                    label: qsTr("AOS block:"),
                    value: SettingsManager.aosBlock
                },
                {
                    label: qsTr("Flash drive:"),
                    value: SettingsManager.flashDrive
                },
                {
                    label: qsTr("CO-3R:"),
                    value: SettingsManager.coThreeRMeasure
                }
            ]
        }

        // Section: Certification and checks
        SectionView {
            title: qsTr("Certification and checks")
            model: [
                {
                    label: qsTr("Calibration certificate:"),
                    value: SettingsManager.calibrationCertificate
                },
                {
                    label: qsTr("Calibration date:"),
                    value: mainColumn.formatDate(SettingsManager.calibrationDate)
                }
            ]
        }

        // Section: Spare parts kit
        SectionView {
            title: qsTr("Spare parts kit")
            model: [
                {
                    label: qsTr("Tablet screws:"),
                    value: mainColumn.getStatusText(SettingsManager.hasTabletScrews)
                },
                {
                    label: qsTr("Ethernet cable:"),
                    value: mainColumn.getStatusText(SettingsManager.hasEthernetCable)
                },
                {
                    label: qsTr("Battery charger:"),
                    value: SettingsManager.batteryCharger
                },
                {
                    label: qsTr("Tablet charger:"),
                    value: SettingsManager.tabletCharger
                },
                {
                    label: qsTr("Tool kit:"),
                    value: mainColumn.getStatusText(SettingsManager.hasToolKit)
                }
            ]
        }

        // Section: Inspection and documentation
        SectionView {
            title: qsTr("Inspection and documentation")
            model: [
                {
                    label: qsTr("Software check:"),
                    value: SettingsManager.softwareCheck
                },
                {
                    label: qsTr("Photo/video URL:"),
                    value: SettingsManager.photoVideoUrl
                },
                {
                    label: qsTr("Weight (kg):"),
                    value: SettingsManager.weight != "" ? SettingsManager.weight : "0"
                },
                {
                    label: qsTr("Notes:"),
                    value: SettingsManager.notes,
                    isMultiline: true
                }
            ]
        }

        // Section: Additional components
        SectionView {
            title: qsTr("Additional components")
            model: [
                {
                    label: qsTr("Manual angle beam probe:"),
                    value: SettingsManager.manualInclined
                },
                {
                    label: qsTr("Normal probe:"),
                    value: SettingsManager.straight
                },
                {
                    label: qsTr("Photo URL:"),
                    value: SettingsManager.photoUrl
                }
            ]
        }

        // Empty element for bottom padding
        Item {
            Layout.fillHeight: true
            Layout.minimumHeight: 20
        }
    }

    // Component for sections
    component SectionView: ColumnLayout 
    {
        id: section_view

        property string title
        property var model: []

        Layout.fillWidth: true
        Layout.rightMargin: 30
        Layout.leftMargin: 10
        spacing: 10

        Text {
            text: section_view.title
            color: Theme.colorTextPrimary
            font.pointSize: 18
            bottomPadding: 5
        }

        Repeater {
            model: section_view.model

            GridLayout {
                id: grid_layout
                columns: 2
                rowSpacing: 5
                columnSpacing: 20
                Layout.fillWidth: true
                required property var modelData

                Label {
                    text: grid_layout.modelData.label
                    color: Theme.colorTextMuted
                    font.pointSize: Theme.fontSmall
                    font.bold: true
                    Layout.alignment: Qt.AlignTop
                    Layout.minimumWidth: 320
                    Layout.maximumWidth: 320
                }

                // Use conditional component creation
                Loader {
                    id: loader

                    Layout.fillWidth: true
                    sourceComponent: {
                        if (grid_layout.modelData.isMultiline) {
                            return multilineTextComponent;
                        } else {
                            return singlelineTextComponent;
                        }
                    }

                    property var itemData: grid_layout.modelData
                    onLoaded: {
                        if (item){
                            item.itemData = loader.itemData
                        }
                    }
                }
            }
        }
    }

    // Component for single-line text
    Component {
        id: singlelineTextComponent

        TextInput {
            property var itemData: {}

            width: parent.width
            text: itemData.value || itemData.hint || ""
            color: Theme.colorTextPrimary
            font.pointSize: Theme.fontSmall
            readOnly: true
            selectByMouse: true
        }
    }

    // Component for multi-line text
    Component {
        id: multilineTextComponent

        TextArea {
            property var itemData: {}
    
            text: itemData.value || ""
            color: Theme.colorTextPrimary
            font.pointSize: Theme.fontSmall
            wrapMode: Text.WordWrap
            readOnly: true
            background: null
            padding: 0
            leftPadding: 0
            implicitHeight: Math.max(60, contentHeight)
        }
    }
}
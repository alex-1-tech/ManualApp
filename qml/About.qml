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

        // Section: PC Tablet Components
        SectionView {
            title: qsTr("PC Tablet Components")
            model: [
                {
                    label: qsTr("PC Tablet Dell 7230:"),
                    value: SettingsManager.pcTabletDell7230
                },
                {
                    label: qsTr("AC/DC Power Adapter Dell:"),
                    value: SettingsManager.acDcPowerAdapterDell
                },
                {
                    label: qsTr("DC Charger Adapter Battery:"),
                    value: SettingsManager.dcChargerAdapterBattery
                }
            ]
        }

        // Section: Ultrasonic Equipment
        SectionView {
            title: qsTr("Ultrasonic Equipment")
            model: [
                {
                    label: qsTr("Ultrasonic Phased Array PULSAR:"),
                    value: SettingsManager.ultrasonicPhasedArrayPulsar
                },
                {
                    label: qsTr("Manual Probe 36°:"),
                    value: SettingsManager.manualProbs36
                },
                {
                    label: qsTr("Straight Probe 0°:"),
                    value: SettingsManager.straightProbs0
                }
            ]
        }

        // Section: Cables and Accessories
        SectionView {
            title: qsTr("Cables and Accessories")
            model: [
                {
                    label: qsTr("DC Cable from Battery:"),
                    value: mainColumn.getStatusText(SettingsManager.hasDcCableBattery)
                },
                {
                    label: qsTr("Ethernet Cables:"),
                    value: mainColumn.getStatusText(SettingsManager.hasEthernetCables)
                },
                {
                    label: qsTr("DC Battery Box:"),
                    value: SettingsManager.dcBatteryBox
                },
                {
                    label: qsTr("AC/DC Charger Adapter Battery:"),
                    value: SettingsManager.acDcChargerAdapterBattery
                }
            ]
        }

        // Section: Calibration and Tools
        SectionView {
            title: qsTr("Calibration and Tools")
            model: [
                {
                    label: qsTr("Calibration Block SO-3R:"),
                    value: SettingsManager.calibrationBlockSo3r
                },
                {
                    label: qsTr("Repair Tool Bag:"),
                    value: mainColumn.getStatusText(SettingsManager.hasRepairToolBag)
                },
                {
                    label: qsTr("Installed Nameplate:"),
                    value: mainColumn.getStatusText(SettingsManager.hasInstalledNameplate)
                }
            ]
        }

        // Section: Additional Information
        SectionView {
            title: qsTr("Additional Information")
            model: [
                {
                    label: qsTr("Notes:"),
                    value: SettingsManager.notes,
                    isMultiline: true
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
            text: itemData.value || ""
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
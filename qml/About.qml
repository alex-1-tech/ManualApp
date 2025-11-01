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
            Layout.leftMargin: 50
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
        SectionView {
            title: qsTr("")
            model: [
                {
                    "label": qsTr("App version: "),
                    "value": DataManager.appVersion()
                },
                {
                    "label": qsTr("Current model: "),
                    "value": SettingsManager.currentModel === "kalmar32" ? qsTr("KALMAR-32") : qsTr("PHAZAR-32")
                }
            ]
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

        // Section: Registration data (общие для всех моделей)
        SectionView {
            title: qsTr("Registration data")
            model: [
                {
                    "label": qsTr("Serial number"),
                    "value": SettingsManager.serialNumber
                },
                {
                    "label": qsTr("Shipment date"),
                    "value": mainColumn.formatDate(SettingsManager.shipmentDate)
                },
                {
                    "label": qsTr("Case number"),
                    "value": SettingsManager.caseNumber
                }
            ]
        }

        // СЕКЦИИ ДЛЯ KALMAR-32
        ColumnLayout {
            visible: SettingsManager.isKalmar32()
            spacing: 20
            Layout.fillWidth: true

            // Section: PC Tablet Components для Kalmar
            SectionView {
                title: qsTr("PC Tablet Components")
                model: [
                    {
                        "label": qsTr("PC tablet Latitude Dell 7230"),
                        "value": SettingsManager.kalmarSettings.pcTabletDell7230
                    },
                    {
                        "label": qsTr("AC/DC Power adapter for Dell 7230"),
                        "value": SettingsManager.kalmarSettings.acDcPowerAdapterDell
                    },
                    {
                        "label": qsTr("DC Charger adapter for Dell 7230 from battery"),
                        "value": SettingsManager.kalmarSettings.dcChargerAdapterBattery
                    }
                ]
            }

            // Section: Ultrasonic Equipment для Kalmar
            SectionView {
                title: qsTr("Ultrasonic Equipment")
                model: [
                    {
                        "label": qsTr("Ultrasonic phased array PULSAR OEM 16/64 established"),
                        "value": SettingsManager.kalmarSettings.ultrasonicPhasedArrayPulsar
                    },
                    {
                        "label": qsTr("Manual probs 36° RA2.25L16 0.9x10-17"),
                        "value": SettingsManager.kalmarSettings.manualProbs36
                    },
                    {
                        "label": qsTr("Straight probs 0° RA5.0L16 0.6x10-17"),
                        "value": SettingsManager.kalmarSettings.straightProbs0
                    },
                    {
                        "label": qsTr("DC Cable from Battery"),
                        "value": mainColumn.getStatusText(SettingsManager.kalmarSettings.hasDcCableBattery)
                    },
                    {
                        "label": qsTr("Ethernet Cables"),
                        "value": mainColumn.getStatusText(SettingsManager.kalmarSettings.hasEthernetCables)
                    }
                ]
            }

            // Section: Battery and Charging для Kalmar
            SectionView {
                title: qsTr("Battery and Charging")
                model: [
                    {
                        "label": qsTr("DC Battery box established"),
                        "value": SettingsManager.kalmarSettings.dcBatteryBox
                    },
                    {
                        "label": qsTr("AC/DC Charger adapter for battery 2"),
                        "value": SettingsManager.kalmarSettings.acDcChargerAdapterBattery
                    }
                ]
            }

            // Section: Calibration and Tools для Kalmar
            SectionView {
                title: qsTr("Calibration and Tools")
                model: [
                    {
                        "label": qsTr("Calibration bloc SO-3R"),
                        "value": SettingsManager.kalmarSettings.calibrationBlockSo3r
                    },
                    {
                        "label": qsTr("Small repair tool witch bag"),
                        "value": mainColumn.getStatusText(SettingsManager.kalmarSettings.hasRepairToolBag)
                    },
                    {
                        "label": qsTr("Installed nameplate with serial number"),
                        "value": mainColumn.getStatusText(SettingsManager.kalmarSettings.hasInstalledNameplate)
                    }
                ]
            }
        }

        // СЕКЦИИ ДЛЯ PHASAR-32
        ColumnLayout {
            visible: SettingsManager.isPhasar32()
            spacing: 20
            Layout.fillWidth: true

            // Section: PC Tablet Components для Phasar
            SectionView {
                title: qsTr("PC Tablet Components")
                model: [
                    {
                        "label": qsTr("PC tablet Latitude Dell 7230"),
                        "value": SettingsManager.phasarSettings.pcTabletDell7230
                    },
                    {
                        "label": qsTr("Personalised name tag"),
                        "value": SettingsManager.phasarSettings.personalisedNameTag
                    },
                    {
                        "label": qsTr("AC/DC Power adapter for Dell 7230"),
                        "value": SettingsManager.phasarSettings.acDcPowerAdapterDell
                    },
                    {
                        "label": qsTr("DC Charger adapter for Dell 7230 from battery"),
                        "value": SettingsManager.phasarSettings.dcChargerAdapterBattery
                    }
                ]
            }

            // Section: Ultrasonic Equipment для Phasar
            SectionView {
                title: qsTr("Ultrasonic Equipment")
                model: [
                    {
                        "label": qsTr("Ultrasonic phased array PULSAR OEM 16/128 established"),
                        "value": SettingsManager.phasarSettings.ultrasonicPhasedArrayPulsar
                    },
                    {
                        "label": qsTr("Manual probs 36° RA2.25L16 0.9x10-17"),
                        "value": SettingsManager.phasarSettings.manualProbs36
                    },
                    {
                        "label": qsTr("DC Cable from battery box"),
                        "value": mainColumn.getStatusText(SettingsManager.phasarSettings.hasDcCableBattery)
                    },
                    {
                        "label": qsTr("Ethernet cable"),
                        "value": mainColumn.getStatusText(SettingsManager.phasarSettings.hasEthernetCables)
                    }
                ]
            }

            // Section: Additional Equipment для Phasar
            SectionView {
                title: qsTr("Additional Equipment")
                model: [
                    {
                        "label": qsTr("Water tank with a tap"),
                        "value": SettingsManager.phasarSettings.waterTankWithTap
                    },
                    {
                        "label": qsTr("DC Battery box established"),
                        "value": SettingsManager.phasarSettings.dcBatteryBox
                    },
                    {
                        "label": qsTr("AC/DC Charger adapter for battery"),
                        "value": SettingsManager.phasarSettings.acDcChargerAdapterBattery
                    }
                ]
            }

            // Section: Calibration and Tools для Phasar
            SectionView {
                title: qsTr("Calibration and Tools")
                model: [
                    {
                        "label": qsTr("Calibration bloc SO-3R"),
                        "value": SettingsManager.phasarSettings.calibrationBlockSo3r
                    },
                    {
                        "label": qsTr("Small repair tool with bag"),
                        "value": mainColumn.getStatusText(SettingsManager.phasarSettings.hasRepairToolBag)
                    },
                    {
                        "label": qsTr("Installed nameplate with serial number"),
                        "value": mainColumn.getStatusText(SettingsManager.phasarSettings.hasInstalledNameplate)
                    }
                ]
            }
        }

        // Section: Additional Information (общие для всех моделей)
        SectionView {
            title: qsTr("Additional Information")
            model: [
                {
                    "label": qsTr("Notes"),
                    "value": SettingsManager.notes,
                    "isMultiline": true
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
    component SectionView: ColumnLayout {
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
                    Layout.minimumWidth: 450
                    Layout.maximumWidth: 450
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
                        if (item) {
                            item.itemData = loader.itemData;
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
            property var itemData: ({})

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
            property var itemData: ({})

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

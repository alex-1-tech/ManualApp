pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "styles"

Page {
    id: root
    signal modelSelected(string modelType)

    background: Rectangle {
        color: Theme.colorBgPrimary
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 24

        Text {
            text: qsTr("Select Model")
            color: Theme.colorTextPrimary
            font.pointSize: 28
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        ScrollView {
            id: scrollArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Item {
                width: scrollArea.availableWidth
                implicitHeight: contentColumn.implicitHeight

                ColumnLayout {
                    id: contentColumn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.max(scrollArea.availableWidth * 0.7, 600)
                    spacing: 20

                    Repeater {
                        model: SettingsManager.availableModels
                        delegate: ModelSelectionCard {
                            required property string modelData
                            title: {
                                var s = SettingsManager.getSettings(modelData);
                                return s ? s.modelTitle : modelData;
                            }
                            description: {
                                var s = SettingsManager.getSettings(modelData);
                                return s ? s.modelDescription : "";
                            }
                            modelType: modelData
                            variants: {
                                var s = SettingsManager.getSettings(modelData);
                                return s ? s.modelVariants : [];
                            }
                            onSelected: function (modelType, variantData) {
                                SettingsManager.currentModel = modelType;
                                SettingsManager.currentVersion = variantData.version;
                                if (variantData.type_rail)
                                    SettingsManager.railType = variantData.type_rail;
                                SettingsManager.loadCurrentModelScheme();
                                root.modelSelected(modelType);
                            }
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }
}

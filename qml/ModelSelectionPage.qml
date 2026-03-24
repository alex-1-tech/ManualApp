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
        anchors.centerIn: parent
        spacing: 40
        width: Math.min(parent.width * 0.8, 600)

        Text {
            text: qsTr("Select Model")
            color: Theme.colorTextPrimary
            font.pointSize: 28
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        ColumnLayout {
            spacing: 20
            Layout.fillWidth: true

            Repeater {
                id: modelRepeater
                model: SettingsManager.availableModels

                delegate: ModelSelectionCard {
                    required property string modelData
                    
                    title: {
                        var settings = SettingsManager.getSettings(modelData)
                        return settings ? settings.modelTitle : modelData
                    }
                    description: {
                        var settings = SettingsManager.getSettings(modelData)
                        return settings ? settings.modelDescription : ""
                    }
                    modelType: modelData
                    
                    onSelected: function(modelType) {
                        root.modelSelected(modelType)
                    }
                    
                    Layout.fillWidth: true
                }
            }
        }
    }
}
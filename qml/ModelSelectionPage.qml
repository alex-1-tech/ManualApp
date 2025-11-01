pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
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

            ModelSelectionCard {
                title: qsTr("KALMAR-32")
                description: qsTr("phased array rails welding joints")
                modelType: "kalmar32"
                onSelected: function(modelType) {
                    root.modelSelected(modelType)
                }
                Layout.fillWidth: true
            }

            ModelSelectionCard {
                title: qsTr("PHAZAR-32")
                description: qsTr("rail double-stranded phased array")
                modelType: "phasar32"
                onSelected: function(modelType) {
                    root.modelSelected(modelType)
                }
                Layout.fillWidth: true
            }
        }
    }
}

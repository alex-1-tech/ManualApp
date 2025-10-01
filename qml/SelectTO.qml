pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import "styles"

Item {
    id: root

    signal toSelected(string file, string numberTO)

    property var menuItems: [
        {
            name: "Daily maint.",
            to: "TO-1",
            file: "TO1.json"
        },
        {
            name: "Montfly maint.",
            to: "TO-2",
            file: "TO2.json"
        },
        {
            name: "Annual maint.",
            to: "TO-3",
            file: "TO3.json"
        }
    ]

    Column {
        width: parent.width
        spacing: 20
        anchors.centerIn: parent

        Text {
            text: "Select maintence"
            font.pixelSize: 24
            color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Repeater {
            model: root.menuItems
            delegate: Item {
                id: delegateItem
                required property var modelData

                width: 240
                height: 40
                anchors.horizontalCenter: parent.horizontalCenter
                Button {
                    id: button 

                    text: qsTr(delegateItem.modelData.name)
                    font.pixelSize: 18
                    onClicked: root.toSelected(delegateItem.modelData.file, delegateItem.modelData.to)
                    width: parent.width
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter

                    background: Rectangle {
                        color: button.enabled ? (
                            button.pressed ? Theme.colorButtonPrimaryHover : Theme.colorButtonPrimary
                            ) : Theme.colorButtonDisabled
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
            }
        }
    }
}

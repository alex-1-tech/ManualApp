import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    signal toSelected(string file)
    
    property var menuItems: [
        { name: "ТО-1", file: "TO1.json" },
        { name: "ТО-2", file: "TO2.json" },
        { name: "ТО-3", file: "TO3.json" }
    ]
    
    Column {
        width: parent.width
        spacing: 20
        anchors.centerIn: parent

        Text {
            text: "Выберите номер ТО"
            font.pixelSize: 24
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Repeater {
            model: menuItems
            delegate: Button {
                text: "Загрузить " + modelData.name
                onClicked: toSelected(modelData.file)
                width: 240
                height: 40
                anchors.horizontalCenter: parent.horizontalCenter 
            }
        }

        Button {
            text: "Настройки серийных номеров"
            width: 240
            height: 40
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: stackView.push("SettingsScreen.qml")
            
            // background: Rectangle {
            //     color: parent.down ? "#d0d0d0" : "#f0f0f0"
            //     border.color: "#888"
            //     radius: 5
            // }
        }
    }
}
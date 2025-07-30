import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualApp.Core 1.0

Item {    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
    }
    
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16
        width: Math.min(parent.width * 0.9, 600)

        Text {
            text: "Настройки серийных номеров"
            font.pixelSize: 22
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }
        
        ColumnLayout {
            spacing: 5
            Layout.fillWidth: true
            
            Text {
                text: "Серийный номер машины:"
                font.pixelSize: 14
            }
            
            TextField {
                id: machineSerialField
                Layout.fillWidth: true
                text: SettingsManager.machineSerial
                placeholderText: "Введите серийный номер"
                onTextChanged: SettingsManager.machineSerial = text
                
                validator: RegularExpressionValidator {
                    regularExpression: /^[A-Za-z0-9\-_]+$/
                }
            }
        }
        
        ColumnLayout {
            spacing: 5
            Layout.fillWidth: true
            
            Text {
                text: "Серийный номер планшета:"
                font.pixelSize: 14
            }
            
            TextField {
                id: tabletSerialField
                Layout.fillWidth: true
                text: SettingsManager.tabletSerial
                placeholderText: "Введите серийный номер"
                onTextChanged: SettingsManager.tabletSerial = text
            }
        }
        
        ColumnLayout {
            spacing: 5
            Layout.fillWidth: true
            
            Text {
                text: "Серийный номер УЗК:"
                font.pixelSize: 14
            }
            
            TextField {
                id: evbSerialField
                Layout.fillWidth: true
                text: SettingsManager.evbSerial
                placeholderText: "Введите серийный номер"
                onTextChanged: SettingsManager.evbSerial = text
            }
        }
        
        Button {
            text: "Сохранить и вернуться"
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20
            width: 200
            height: 40
            
            onClicked: {
                stackView.pop();
            }
            
            background: Rectangle {
                color: parent.down ? "#4CAF50" : "#8BC34A"
                radius: 5
            }
            
            contentItem: Text {
                text: parent.text
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: true
            }
        }
    }
    
    Button {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 10
        text: "← Назад"
        flat: true
        onClicked: stackView.pop()
    }
    
    Text {
        id: saveStatus
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
        color: "green"
        visible: false
    }
}
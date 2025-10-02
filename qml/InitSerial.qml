pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "styles"

ScrollView {
    id: root

    property string placeholder: qsTr("Enter serial number")
    property string settingName: "serialNumber"
    property string currentValue: ""
    
    signal valueChanged(string value)
    signal settingsCompleted
    signal validationError(string errorMessage)

    clip: true

    background: Rectangle {
        color: Theme.colorBgPrimary
    }

    contentItem: Flickable {
        id: flick
        anchors.fill: parent
        clip: true
        contentWidth: width
        contentHeight: formContainer.implicitHeight
        
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }

        Item {
            width: flick.width
            height: flick.height

            ColumnLayout {
                id: formContainer
                width: Math.min(600, root.width * 0.9)
                anchors.centerIn: parent
                spacing: 25

                Text {
                    text: qsTr("Enter defectoscope serial number")
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 10
                    font.pixelSize: Theme.fontTitle
                    font.bold: true
                    color: Theme.colorTextPrimary
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    TextField {
                        id: serialInput
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        
                        color: Theme.colorTextPrimary
                        font.pixelSize: Theme.fontBody
                        font.family: "Monospace"
                        
                        text: {
                            if (root.settingName && SettingsManager.hasOwnProperty(root.settingName)) {
                                return SettingsManager[root.settingName]
                            }
                            return root.currentValue
                        }
                        
                        placeholderText: root.placeholder
                        placeholderTextColor: Theme.colorTextPlaceholder
                                            
                        selectByMouse: true
                        maximumLength: 50
                        padding: 15
                        
                        onTextChanged: {
                            var newValue = text.trim()
                            serialInput.color = Theme.colorTextPrimary
                            if (root.settingName && SettingsManager.hasOwnProperty(root.settingName)) {
                                SettingsManager[root.settingName] = newValue
                            }
                            root.currentValue = newValue
                            root.valueChanged(newValue)
                        }
                        
                        onAccepted: {
                            if (serialInput.acceptableInput) {
                                confirmDialog.open()
                            }
                        }

                        background: Rectangle {
                            color: Theme.colorBgCard
                            border.color: Theme.colorBorderLight
                            border.width: 1.5
                            radius: 8
                            
                            Behavior on border.color {
                                ColorAnimation { duration: 200 }
                            }
                        }
                    }
                }

                Button {
                    id: saveButton
                    text: qsTr("Save")
                    font.pixelSize: Theme.fontBody
                    font.bold: true
                    
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 45
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 10
                    
                    enabled: serialInput.text.length > 0 && serialInput.acceptableInput
                    
                    onClicked: {
                        if (serialInput.acceptableInput) {
                            confirmDialog.open()
                        }
                    }

                    background: Rectangle {
                        color: {
                            if (!saveButton.enabled) 
                                return Theme.colorButtonSecondaryHover
                            else if (saveButton.pressed) 
                                return Theme.colorButtonPrimaryHover
                            else 
                                return Theme.colorButtonPrimary
                        }
                        radius: Theme.radiusButton
                        
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }

                    contentItem: Text {
                        text: saveButton.text
                        font: saveButton.font
                        color: saveButton.enabled ? Theme.colorPillText : Theme.colorTextMuted
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    id: statusText
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSmall
                    color: Theme.colorSuccess
                    visible: false
                    
                    Connections {
                        target: root
                        function onSettingsCompleted() {
                            statusText.text = qsTr("Serial number saved successfully!")
                            statusText.color = Theme.colorSuccess
                            statusText.visible = true
                            statusTimer.start()
                        }
                        
                        function onValidationError(errorMessage) {
                            statusText.text = errorMessage
                            statusText.color = Theme.colorError
                            statusText.visible = true
                            statusTimer.start()
                        }
                    }
                    
                    Timer {
                        id: statusTimer
                        interval: 3000
                        onTriggered: statusText.visible = false
                    }
                }
            }
        }

        Dialog {
            id: confirmDialog
            modal: true
            title: qsTr("Save Confirmation")
            standardButtons: Dialog.Ok | Dialog.Cancel
            anchors.centerIn: Overlay.overlay
            width: 500
            height: 220

            background: Rectangle {
                color: Theme.colorBgCard
                radius: Theme.radiusCard
                border.color: Theme.colorBorder
                border.width: 1
            }

            header: Label {
                text: confirmDialog.title
                font.pixelSize: Theme.fontSubtitle
                font.bold: true
                color: Theme.colorTextPrimary
                padding: 20
                bottomPadding: 10
            }

            contentItem: ColumnLayout {
                spacing: 15
                width: parent.width

                Label {
                    text: qsTr("Are you sure you want to save the serial number?")
                    wrapMode: Text.WordWrap
                    color: Theme.colorTextPrimary
                    font.pixelSize: Theme.fontBody
                    Layout.fillWidth: true
                }
                
                Label {
                    text: qsTr("Serial number: ") + "<b>" + serialInput.text + "</b>"
                    wrapMode: Text.WordWrap
                    color: Theme.colorTextPrimary
                    font.pixelSize: Theme.fontSmall
                    Layout.fillWidth: true
                    textFormat: Text.RichText
                }
                
                Label {
                    text: qsTr("Important: After saving, it will be impossible to change this data. Please carefully check that you have entered the correct information without any errors.")
                    wrapMode: Text.WordWrap
                    color: Theme.colorWarning
                    font.pixelSize: Theme.fontSmall
                    Layout.fillWidth: true
                    font.italic: true
                }
            }

            onAccepted: {
                root.settingsCompleted()
            }
        }
    }
}

pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../styles"

Popup {
    id: root
    
    signal confirmed()
    signal cancelled()
    
    modal: true
    focus: true
    width: 400
    height: 180
    anchors.centerIn: Overlay.overlay
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Rectangle {
        color: Theme.colorBgPrimary
        radius: 8
        border.color: Theme.colorBorder
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: 20

        Label {
            text: qsTr("Save confirmation")
            font.bold: true
            font.pointSize: Theme.fontSubtitle
            color: Theme.colorTextPrimary
            Layout.fillWidth: true
        }

        Label {
            text: qsTr("Are you sure you want to save the settings?\nAfter saving, some of them cannot be changed.")
            wrapMode: Text.WordWrap
            color: Theme.colorTextSecondary
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Button {
                id: cancelButton
                text: "Cancel"
                Layout.fillWidth: true
                Layout.preferredHeight: 35

                background: Rectangle {
                    color: cancelButton.pressed ? Theme.colorButtonSecondaryHover : Theme.colorButtonSecondary
                    radius: Theme.radiusButton
                }

                contentItem: Text {
                    text: cancelButton.text
                    color: Theme.colorTextPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: Theme.fontSmall
                }

                onClicked: {
                    root.cancelled()
                    root.close()
                }
            }

            Button {
                id: okButton
                text: "OK"
                Layout.fillWidth: true
                Layout.preferredHeight: 35

                background: Rectangle {
                    color: okButton.pressed ? Theme.colorButtonPrimaryHover : Theme.colorButtonPrimary
                    radius: Theme.radiusButton
                }

                contentItem: Text {
                    text: okButton.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: Theme.fontSmall
                }

                onClicked: {
                    root.confirmed()
                    root.close()
                }
            }
        }
    }
}
pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "../styles"

RowLayout {
    id: root

    property string label: ""
    property string text: ""
    property string settingName: ""
    property var modelSettings: SettingsManager
    property bool checked: modelSettings && settingName ? modelSettings[settingName] || false : false

    Layout.fillWidth: true
    spacing: 12

    Rectangle {
        id: checkbox
        Layout.preferredWidth: 24
        Layout.preferredHeight: 24
        radius: 4
        border.color: root.checked ? Theme.colorButtonPrimary : Theme.colorBorder
        border.width: root.checked ? 0 : 1
        color: root.checked ? Theme.colorButtonPrimary : Theme.colorBgPrimary

        // Галочка
        Image {
            anchors.centerIn: parent
            width: 16
            height: 16
            source: "qrc:/media/icons/icon-checkmark.svg"
            visible: root.checked
        }

        // Эффект при наведении
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: Theme.colorButtonPrimary
            opacity: mouseArea.containsMouse ? 0.1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.checked = !root.checked;

                if (root.modelSettings && root.settingName)
                    root.modelSettings[root.settingName] = root.checked;
            }
        }

        // Анимации
        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: 200
            }
        }
        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }

        states: [
            State {
                name: "pressed"
                when: mouseArea.pressed
                PropertyChanges {
                    checkbox.scale: 0.95
                }
            }
        ]
    }

    Label {
        Layout.preferredWidth: parent.width < 700 ? 280 : 450
        Layout.fillWidth: true
        text: root.label
        color: Theme.colorTextPrimary
        font.pointSize: Theme.fontSmall
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
    }
}

pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "../styles"

RowLayout {
    id: root

    property string label: ""
    property string placeholder: ""
    property string settingName: ""
    property bool multiline: false
    property var modelSettings: SettingsManager

    Layout.fillWidth: true
    spacing: 8

    Label {
        Layout.preferredWidth: parent.width < 700 ? 280 : 450
        text: root.label
        color: Theme.colorTextPrimary
        font.pointSize: Theme.fontSmall
        wrapMode: Text.WordWrap
    }

    Loader {
        Layout.fillWidth: true
        sourceComponent: root.multiline ? textAreaComponent : textFieldComponent
    }

    Component {
        id: textFieldComponent

        TextField {
            id: textField
            placeholderText: root.placeholder
            text: root.modelSettings ? (root.modelSettings[root.settingName] || "") : ""

            onTextChanged: {
                if (root.modelSettings && root.settingName && textField.activeFocus)
                        root.modelSettings[root.settingName] = text;
            }


            color: Theme.colorTextPrimary
            placeholderTextColor: Theme.colorTextPlaceholder
            selectionColor: Theme.colorAccent
            selectedTextColor: Theme.colorTextPrimary
            font.pointSize: Theme.fontSmall

            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 30
                color: Theme.colorBgPrimary
                border.color: textField.activeFocus ? Theme.colorButtonPrimary : Theme.colorBorder
                border.width: 1
                radius: 4
            }
        }
    }

    Component {
        id: textAreaComponent

        TextArea {
            id: textArea
            placeholderText: root.placeholder
            text: root.modelSettings ? (root.modelSettings[root.settingName] || "") : ""

            onTextChanged: {
                if (root.modelSettings && root.settingName && textArea.activeFocus)
                        root.modelSettings[root.settingName] = text;
            }
            color: Theme.colorTextPrimary
            placeholderTextColor: Theme.colorTextPlaceholder
            selectionColor: Theme.colorAccent
            selectedTextColor: Theme.colorTextPrimary
            font.pointSize: Theme.fontSmall
            wrapMode: Text.WordWrap

            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 120
                color: Theme.colorBgPrimary
                border.color: textArea.activeFocus ? Theme.colorButtonPrimary : Theme.colorBorder
                border.width: 1
                radius: 4
            }
        }
    }
}

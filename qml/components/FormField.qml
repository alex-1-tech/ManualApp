pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "../styles"

RowLayout {
    id: root
    property alias label: lbl.text
    property string settingName: ""
    property string placeholder: ""
    property bool isDate: false
    property bool multiline: false
    property var validator: null

    signal valueChanged(string newValue)

    Layout.fillWidth: true
    spacing: 8

    Label {
        id: lbl
        Layout.preferredWidth: 350
        elide: Text.ElideRight
        color: Theme.colorTextPrimary
        font.pointSize: Theme.fontSmall
    }

    Loader {
        id: loader
        sourceComponent: root.multiline ? textAreaComp : textFieldComp
        Layout.fillWidth: true
    }

    Component {
        id: textFieldComp
        TextField {
            id: input
            Layout.fillWidth: true
            color: Theme.colorTextPrimary
            font.pointSize: Theme.fontSmall

            text: (root.settingName && SettingsManager.hasOwnProperty(root.settingName)) ? SettingsManager[root.settingName] : ""

            placeholderText: root.placeholder
            placeholderTextColor: Theme.colorTextPlaceholder
            padding: 7
            validator: root.validator

            onTextChanged: {
                if (root.settingName && SettingsManager.hasOwnProperty(root.settingName)) {
                    SettingsManager[root.settingName] = text;
                }
                root.valueChanged(text);
            }

            background: Rectangle {
                color: Qt.rgba(255, 255, 255, .1)
                border.color: Qt.rgba(120, 130, 140, .2)
                radius: 6
            }
        }
    }

    Component {
        id: textAreaComp
        TextArea {
            id: ta
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            implicitHeight: 100
            placeholderText: root.placeholder
            font.pointSize: Theme.fontSmall

            text: (root.settingName && SettingsManager.hasOwnProperty(root.settingName)) ? SettingsManager[root.settingName] : ""

            onTextChanged: {
                if (root.settingName && SettingsManager.hasOwnProperty(root.settingName)) {
                    SettingsManager[root.settingName] = text;
                }
                root.valueChanged(text);
            }

            background: Rectangle {
            color: Qt.rgba(255, 255, 255, .1)
            border.color: Qt.rgba(120, 130, 140, .2)
        }
        }
    }


}

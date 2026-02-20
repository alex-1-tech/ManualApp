pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "../styles"

RowLayout {
    id: root

    property string label: ""
    property string placeholder: "ДД.ММ.ГГГГ"
    property string settingName: ""
    property var modelSettings: SettingsManager
    property date initialDate: new Date()

    Layout.fillWidth: true
    spacing: 8

    Label {
        Layout.preferredWidth: parent.width < 700 ? 280 : 450
        text: root.label
        color: Theme.colorTextPrimary
        font.pointSize: Theme.fontSmall
        wrapMode: Text.WordWrap
    }

    TextField {
        id: dateField

        Layout.fillWidth: true

        text: {
            if (!root.modelSettings || !root.settingName)
                return internal.formatDate(root.initialDate);

            var dateValue = root.modelSettings[root.settingName];
            if (dateValue && dateValue instanceof Date) {
                return internal.formatDate(dateValue);
            }
            return internal.formatDate(root.initialDate);
        }

        placeholderText: root.placeholder
        color: Theme.colorTextPrimary
        placeholderTextColor: Theme.colorTextPlaceholder
        selectionColor: Theme.colorAccent
        selectedTextColor: Theme.colorTextPrimary
        font.pointSize: Theme.fontSmall
        padding: 7

        validator: RegularExpressionValidator {
            regularExpression: /^(0[1-9]|[12][0-9]|3[01])\.(0[1-9]|1[012])\.(19|20)\d\d$/
        }

        background: Rectangle {
            implicitWidth: 200
            implicitHeight: 30
            color: Theme.colorBgPrimary
            border.color: dateField.activeFocus ? Theme.colorButtonPrimary : Theme.colorBorder
            border.width: 1
            radius: 4
        }

        QtObject {
            id: internal

            function formatDate(date) {
                if (!date || isNaN(date.getTime()))
                    return "";

                var day = String(date.getDate()).padStart(2, '0');
                var month = String((date.getMonth() + 1)).padStart(2, '0');
                var year = date.getFullYear();
                return day + "." + month + "." + year;
            }

            function parseDate(dateString) {
                var parts = dateString.split(".");
                if (parts.length === 3) {
                    var day = parseInt(parts[0]);
                    var month = parseInt(parts[1]) - 1;
                    var year = parseInt(parts[2]);
                    return new Date(year, month, day);
                }
                return new Date();
            }
        }

        onEditingFinished: {
            if (text && acceptableInput) {
                var newDate = internal.parseDate(text);

                if (root.modelSettings && root.settingName)
                        root.modelSettings[root.settingName] = newDate;
                root.initialDate = newDate;
            }
        }

        Component.onCompleted: {
            if (root.modelSettings && root.settingName) {
                var dateValue = root.modelSettings[root.settingName];
                if (dateValue && dateValue instanceof Date) {
                    text = internal.formatDate(dateValue);
                }
            } else {
                text = internal.formatDate(root.initialDate);
            }
        }
    }
}

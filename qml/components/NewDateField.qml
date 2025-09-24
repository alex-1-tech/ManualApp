pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../styles"

TextField {
        id: dateField

        property date shipmentDate: new Date()
        property alias selectedDate: internal.selectedDate

        QtObject {
            id: internal
            property date selectedDate: new Date()

            function formatDate(date) {
                if (!date || isNaN(date.getTime()))
                    return "";

                var day = String(date.getDate()).padStart(2, '0');
                var month = String((date.getMonth() + 1)).padStart(2, '0');
                var year = date.getFullYear();
                return day + "." + month + "." + year;
            }
        }

        color: Theme.colorTextPrimary
        font.pointSize: Theme.fontSmall
        padding: 7
        Layout.fillWidth: true
        placeholderText: qsTr("ДД.ММ.ГГГГ")
        placeholderTextColor: Theme.colorTextPlaceholder

        validator: RegularExpressionValidator {
            regularExpression: /^(0[1-9]|[12][0-9]|3[01])\.(0[1-9]|1[012])\.(19|20)\d\d$/
        }

        background: Rectangle {
            color: Qt.rgba(255, 255, 255, .1)
            border.color: Qt.rgba(120, 130, 140, .2)
        }

        onShipmentDateChanged: {
            if (shipmentDate) {
                internal.selectedDate = new Date(shipmentDate);
                text = internal.formatDate(internal.selectedDate);
            } else {
                text = "";
            }
        }

        onEditingFinished: {
            var parts = text.split(".");
            if (parts.length === 3) {
                var day = parseInt(parts[0]);
                var month = parseInt(parts[1]) - 1;
                var year = parseInt(parts[2]);
                internal.selectedDate = new Date(year, month, day);

                shipmentDate = internal.selectedDate;
            }
        }

        Component.onCompleted: {
            if (shipmentDate) {
                internal.selectedDate = new Date(shipmentDate);
                text = internal.formatDate(internal.selectedDate);
            }
        }
    }

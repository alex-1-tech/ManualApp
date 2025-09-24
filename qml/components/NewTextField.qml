pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../styles"

TextField {

    Layout.fillWidth: true
    color: Theme.colorTextPrimary
    font.pointSize: Theme.fontSmall
    padding: 7

    placeholderTextColor: Theme.colorTextPlaceholder

    background: Rectangle {
        color: Qt.rgba(255, 255, 255, .1)
        border.color: Qt.rgba(120, 130, 140, .2)
    }
}

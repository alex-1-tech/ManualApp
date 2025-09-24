pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../styles"

TextArea {
    color: Theme.colorTextPrimary
    font.pointSize: Theme.fontSmall
    padding: 7
    Layout.fillWidth: true
    placeholderTextColor: Theme.colorTextPlaceholder
    wrapMode: Text.WordWrap
    background: Rectangle {
        color: Qt.rgba(255, 255, 255, .1)
        border.color: Qt.rgba(120, 130, 140, .2)
    }
}

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../styles"

Item {
    id: root

    property alias title: header.text
    property int pad: 12
    property color bgColor: Theme.colorBgCard
    property color borderColor: Theme.colorBorder
    property real radius: 6

    default property alias content: contentColumn.data

    Layout.fillWidth: true
    Layout.preferredHeight: contentColumn.implicitHeight + pad*2

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: root.radius
        color: root.bgColor
        border.color: root.borderColor
    }

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: root.pad
        spacing: 12

        Text {
            id: header
            text: ""
            color: Theme.colorTextPrimary
            font.pointSize: 18
        }

        // generate objects
    }
}

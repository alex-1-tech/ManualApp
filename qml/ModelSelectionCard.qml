pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Layouts 1.15
import "styles"

Rectangle {
    id: root

    property string title: ""
    property string description: ""
    property string imageSource: ""
    property string modelType: ""

    signal selected(string modelType)

    height: 140
    radius: Theme.radiusCard
    color: mouseArea.containsMouse ? Theme.colorNavHover : Theme.colorBgCard
    border.color: mouseArea.containsMouse ? Theme.colorBorderHover : Theme.colorBorder
    border.width: 2

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.selected(root.modelType)
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        Rectangle {
            color: Theme.colorAccentMuted
            radius: Theme.radiusCard
            Layout.preferredWidth: 80
            Layout.preferredHeight: 80
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.centerIn: parent
                text: root.title.charAt(0)
                color: Theme.colorTextPrimary
                font.pointSize: Theme.fontTitle
                font.bold: true
            }
        }

        ColumnLayout {
            spacing: 12
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: root.title
                color: Theme.colorTextPrimary
                font.pointSize: Theme.fontSubtitle
                font.bold: true
            }

            Text {
                text: root.description
                color: Theme.colorTextSecondary
                font.pointSize: Theme.fontBody
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
    }
}

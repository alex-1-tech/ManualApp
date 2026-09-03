import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../styles"

Rectangle {
    id: root
    anchors.fill: parent
    color: Theme.colorBgPrimary
    z: 9999

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 30

        BusyIndicator {
            id: busyIndicator
            Layout.alignment: Qt.AlignHCenter
            running: true
            width: 60
            height: 60
        }

        Text {
            text: qsTr("Loading configuration…")
            color: Theme.colorTextPrimary
            font.pointSize: Theme.fontTitle
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: qsTr("Please wait while the application downloads the latest settings")
            color: Theme.colorTextSecondary
            font.pointSize: Theme.fontBody
            Layout.alignment: Qt.AlignHCenter
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
}

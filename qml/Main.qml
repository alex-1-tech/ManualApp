import QtQuick
import QtQuick.Window
import Screens 1.0

Window {
    id: root

    width: 1980
    height: 1020
    visible: true
    title: qsTr("Техническое обслуживание")
    color: "#f9f9f9"

    Loader {
        id: mainLoader

        anchors.fill: parent

        sourceComponent: MainScreen {
        }

    }

}

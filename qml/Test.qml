import QtQuick.Controls 2.15
import ManualAppCorePlugin 1.0

ApplicationWindow {
    id: appWindow

    minimumWidth: 1440
    minimumHeight: 900
    maximumWidth: minimumWidth
    maximumHeight: minimumHeight
    visible: true
    title: qsTr("Техническое обслуживание")

     Component.onCompleted: {
        DataManager.setSettingsManager(SettingsManager)
    }
}
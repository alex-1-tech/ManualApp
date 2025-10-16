pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import ManualAppCorePlugin 1.0
import "styles"

ApplicationWindow {
    id: appWindow

    visibility: Window.Maximized
    minimumWidth: 800
    minimumHeight: 600

    visible: true
    title: qsTr("Техническое обслуживание")
    color: Theme.colorBgPrimary
    property bool firstRun: true

    Component.onCompleted: {
        DataManager.setSettingsManager(SettingsManager)

        firstRun = SettingsManager.isFirstRun
        if (firstRun) {
            contentLoader.sourceComponent = settingsComponent
        } else {
            DataManager.syncReportsWithServer();
            contentLoader.sourceComponent = mainComponent
        }
    }
    onClosing: function () {
        // if(DataManager.startTime != "" && DataManager.startTime != null)
        //     DataManager.save(    false);
        DataManager.setStartTime(null);
    }

    Loader {
        id: contentLoader
        anchors.fill: parent
    }

     Component {
        id: settingsComponent
        InitSettings {
            onSettingsCompleted: {
                SettingsManager.completeFirstRun();
                contentLoader.sourceComponent = mainComponent
            }
        }
    }
    
    Component {
        id: mainComponent
        Main {
        }
    }
}
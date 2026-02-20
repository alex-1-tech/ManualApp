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
    title: qsTr("ManualApp")
    color: Theme.colorBgPrimary
    property bool firstRun: true

    Component.onCompleted: {
        DataManager.setSettingsManager(SettingsManager)

        firstRun = SettingsManager.isFirstRun
        if (firstRun) {
            contentLoader.sourceComponent = modelSelectionComponent
        } else {
            DataManager.syncReportsWithServer();
            DataManager.syncSettingsWithServer();
            contentLoader.sourceComponent = mainComponent
        }
    }

    onClosing: function () {
        DataManager.setStartTime(null);
    }

    Loader {
        id: contentLoader
        anchors.fill: parent
    }

    Component {
        id: modelSelectionComponent
        ModelSelectionPage {
            onModelSelected: function(modelType) {
                SettingsManager.currentModel = modelType
                contentLoader.sourceComponent = settingsComponent
            }
        }
    }

    Component {
        id: settingsComponent
        SettingsForm {
            onSettingsCompleted: {
                SettingsManager.completeFirstRun();
                if(SettingsManager.currentModel == "kalmar32")
                    DataManager.uploadSettingsToDjango(DataManager.djangoBaseUrl() + "/api/kalmar32/");
                else
                    DataManager.uploadSettingsToDjango(DataManager.djangoBaseUrl() + "/api/phasar32/");
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

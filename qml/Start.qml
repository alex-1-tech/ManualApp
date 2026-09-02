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
    property bool hasAllFields: true

    Component.onCompleted: {
        DataManager.setSettingsManager(SettingsManager);
        InstallManager.setAllManagers(DataManager.licenseHandler(), DataManager.networkService(), DataManager.fileService());

        hasAllFields = SettingsManager.currentModel !== "" && SettingsManager.currentSchemaFile !== "" && SettingsManager.currentVersion !== "";
        if(!hasAllFields){
            SettingsManager.isFirstRun = true;
        }
        firstRun = SettingsManager.isFirstRun;
        
        if (firstRun) {
            contentLoader.sourceComponent = modelSelectionComponent;
        } else {
            DataManager.syncSettingsWithServer();
            contentLoader.sourceComponent = mainComponent;
        }
    }

    onClosing: function () {}

    Loader {
        id: contentLoader
        anchors.fill: parent
        active: true
    }

    Component {
        id: modelSelectionComponent
        ModelSelectionPage {
            onModelSelected: function (modelType) {
                SettingsManager.currentModel = modelType;
                contentLoader.sourceComponent = settingsComponent;
            }
        }
    }

    Component {
        id: settingsComponent
        Settings {
            initialMode: true

            onSettingsCompleted: {
                contentLoader.sourceComponent = mainComponent;
            }

            onBackToModelSelection: {
                contentLoader.sourceComponent = modelSelectionComponent;
            }

            onReloadRequested: {
                contentLoader.sourceComponent = undefined;
                contentLoader.sourceComponent = settingsComponent;
            }
        }
    }

    Component {
        id: mainComponent
        Main {}
    }
}

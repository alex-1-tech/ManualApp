pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import ManualAppCorePlugin 1.0
import "styles"
import "components"

ApplicationWindow {
    id: appWindow

    visibility: Window.Maximized
    minimumWidth: 800
    minimumHeight: 600

    visible: true
    title: qsTr("ManualApp")
    color: Theme.colorBgPrimary

    property bool loadingVersions: true
    property bool versionsLoaded: false
    property bool schemesLoaded: false
    property bool appInitialized: false

    LoadingScreen {
        visible: loadingVersions
    }
    Loader {
        id: contentLoader
        anchors.fill: parent
        active: !loadingVersions
        visible: !loadingVersions
    }

    Timer {
        id: timeoutTimer
        interval: 10000
        repeat: false
        onTriggered: {
            if (loadingVersions) {
                console.warn("Loading timeout, proceeding with local data");
                loadingVersions = false;
                if (!appInitialized) {
                    appInitialized = true;
                    initializeApp();
                }
            }
        }
    }

    Component.onCompleted: {
        DataManager.setSettingsManager(SettingsManager);
        SettingsManager.setFileService(DataManager.fileService());
        InstallManager.setAllManagers(DataManager.licenseHandler(), DataManager.networkService(), DataManager.fileService());

        DataManager.fetchVersions();
        DataManager.fetchSchemes();
        timeoutTimer.start();

        DataManager.versionsFetched.connect(onVersionsFetched);
        DataManager.schemesFetched.connect(onSchemesFetched);
    }

    function onVersionsFetched(success, error) {
        if (!success) {
            console.warn("Versions fetch failed: " + error);
        }
        versionsLoaded = true;
        tryInitializeApp();
    }

    function onSchemesFetched(success, error) {
        if (!success) {
            console.warn("Schemes fetch failed: " + error);
        }
        schemesLoaded = true;
        tryInitializeApp();
    }

    function tryInitializeApp() {
        if (appInitialized) return;
        if (versionsLoaded && schemesLoaded) {
            loadingVersions = false;
            timeoutTimer.stop();
            appInitialized = true;
            initializeApp();
        }
    }

    function initializeApp() {
        var hasAllFields = SettingsManager.currentModel !== "" &&
                           SettingsManager.currentSchemaFile !== "" &&
                           SettingsManager.currentVersion !== "";
        if (!hasAllFields) {
            SettingsManager.isFirstRun = true;
        }
        var firstRun = SettingsManager.isFirstRun;

        if (firstRun) {
            contentLoader.sourceComponent = modelSelectionComponent;
        } else {
            DataManager.syncSettingsWithServer();
            contentLoader.sourceComponent = mainComponent;
        }
    }

    onClosing: function () {}

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
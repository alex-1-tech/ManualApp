pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "styles"
import "components"

ScrollView {
    id: root

    clip: true
    anchors.fill: parent

    // ====== State ===========================================================
    property string currentModel: SettingsManager.currentModel
    property string railType: SettingsManager.railType
    property string version: SettingsManager.currentVersion
    property bool isInitialized: false

    // Main model download state
    property bool isMainDownloading: false
    property bool isMainInstallerReady: InstallManager.installerExists(currentModel)
    property double mainDownloadProgress: 0.0
    property string mainStatusMessage: ""
    property string mainUpdateStatus: "" // "new_version_available", "up_to_date", "not_downloaded"
    property date mainLastVersionDate: new Date(0)
    property date mainLatestServerDate: new Date(0)

    // ManualApp specific properties
    property bool isManualAppDownloading: false
    property bool isManualAppInstallerReady: InstallManager.installerExists("manual_app")
    property string manualAppStatusMessage: ""
    property double manualAppDownloadProgress: 0.0
    property string manualAppUpdateStatus: "" // "new_version_available", "up_to_date", "not_downloaded"
    property date manualAppLastVersionDate: SettingsManager.lastUpdateManualAppDate
    property date manualAppLatestServerDate: new Date(0)

    property bool isLoadingDates: false

    // ====== Functions ======================================================
    function isValidDate(date) {
        return date instanceof Date && !isNaN(date.getTime());
    }

    function checkForUpdates() {
        if (root.currentModel === "" || root.railType === "")
            return;

        root.isLoadingDates = true;

        var mainServerDateStr = InstallManager.getLastUpdateDate(DataManager.djangoBaseUrl(), root.currentModel, root.railType, root.version);
        var mainServerDate = mainServerDateStr ? new Date(mainServerDateStr) : new Date(0);

        root.mainLatestServerDate = mainServerDate;
        root.mainLastVersionDate = SettingsManager.lastUpdateSoftwareDate;

        const needMainUpdate = !root.isMainInstallerReady || !isValidDate(root.mainLastVersionDate) || root.mainLastVersionDate < root.mainLatestServerDate;
        root.mainUpdateStatus = needMainUpdate ? (root.isMainInstallerReady ? "new_version_available" : "not_downloaded") : "up_to_date";

        var manualServerDateStr = InstallManager.getLastUpdateDate(DataManager.djangoBaseUrl(), "manual_app", "", "");
        var manualServerDate = manualServerDateStr ? new Date(manualServerDateStr) : new Date(0);

        root.manualAppLatestServerDate = manualServerDate;
        root.manualAppLastVersionDate = SettingsManager.lastUpdateManualAppDate;

        if (!isValidDate(root.manualAppLastVersionDate) || root.manualAppLastVersionDate < root.manualAppLatestServerDate) {
            root.manualAppUpdateStatus = "new_version_available";
        } else {
            root.manualAppUpdateStatus = "up_to_date";
        }

        root.isLoadingDates = false;
    }

    function resetMainDownloadState() {
        root.isMainDownloading = false;
        root.mainDownloadProgress = 0;
        root.isMainInstallerReady = InstallManager.installerExists(root.currentModel);
        root.checkForUpdates();
    }

    function resetManualAppDownloadState() {
        root.isManualAppDownloading = false;
        root.manualAppDownloadProgress = 0;
        root.isManualAppInstallerReady = InstallManager.installerExists("manual_app");
        root.checkForUpdates();
    }

    Component.onCompleted: {
        isInitialized = true;
        checkForUpdates();
    }

    onCurrentModelChanged: {
        if (isInitialized)
            checkForUpdates();
    }

    onRailTypeChanged: {
        if (isInitialized)
            checkForUpdates();
    }

    contentItem: Flickable {
        id: flick
        anchors.fill: parent
        clip: true
        contentHeight: formContainer.implicitHeight
        contentWidth: width

        ColumnLayout {
            id: formContainer
            width: root.width > 1100 ? 1000 : root.width * 0.92
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10
            spacing: 20

            RowLayout {
                Layout.leftMargin: 50
                Image {
                    source: "qrc:///media/icons/icon-servers.svg"
                    sourceSize.width: 40
                    sourceSize.height: 40
                }

                Text {
                    text: qsTr("Software Installation")
                    color: Theme.colorTextPrimary
                    font.pointSize: 24
                }
            }

            // Model Info
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: Theme.colorBgCard
                radius: Theme.radiusCard
                border.color: Theme.colorBorder

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15

                    Text {
                        text: "Current Model:"
                        color: Theme.colorTextMuted
                        font.pointSize: Theme.fontBody
                    }

                    Text {
                        text: SettingsManager.getCurrentSettings().modelTitle
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSubtitle
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    BusyIndicator {
                        visible: root.isLoadingDates
                        running: visible
                        width: 20
                        height: 20
                    }
                }
            }

            InstallSection {
                Layout.fillWidth: true
                sectionTitle: "Download & Install Software"
                updateStatus: root.mainUpdateStatus
                isDownloading: root.isMainDownloading
                isInstallerReady: root.isMainInstallerReady
                downloadProgress: root.mainDownloadProgress
                statusMessage: root.mainStatusMessage || (root.isMainInstallerReady ? "Installer ready" : "Not downloaded")
                idleStatusColor: Theme.colorError
                latestServerDate: root.mainLatestServerDate
                lastVersionDate: root.mainLastVersionDate
                versionRowLabel: "Downloaded version:"
                infoLine1: "Installer: " + SettingsManager.getCurrentSettings().modelInstallerPath
                infoLine2: "Path: " + InstallManager.buildInstallerPath(SettingsManager.currentModel)
                cardHeight: root.currentModel === "kalmar32" ? 250 : 200

                downloadButtonText: root.isMainDownloading ? "Downloading..." : (root.mainUpdateStatus === "new_version_available" ? "Update Now" : (root.isMainInstallerReady ? "Redownload" : "Download"))
                downloadEnabled: !root.isMainDownloading && !InstallManager.isInstalling && !root.isManualAppDownloading

                installButtonText: InstallManager.isInstalling ? "Installing..." : "Run Installer"
                installEnabled: !InstallManager.isInstalling && !root.isMainDownloading && !InstallManager.isDownloading && root.isMainInstallerReady

                extraContent: Component {
                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: root.railType !== ""

                        Text {
                            text: "Rail type: " + root.railType.toUpperCase()
                            color: Theme.colorTextMuted
                            font.pointSize: Theme.fontSmall
                            font.weight: Font.Normal
                        }

                        Text {
                            text: "Version: " + root.version.toUpperCase()
                            color: Theme.colorTextMuted
                            font.pointSize: Theme.fontSmall
                            font.weight: Font.Normal
                        }
                    }
                }

                onDownloadRequested: {
                    var url = DataManager.djangoBaseUrl();
                    root.isMainDownloading = true;
                    root.mainStatusMessage = "Starting download...";
                    root.mainDownloadProgress = 0;
                    InstallManager.downloadInstaller(root.currentModel, url, root.railType, root.version);
                }

                onInstallRequested: {
                    InstallManager.runInstaller(root.currentModel);
                    if (root.mainUpdateStatus === "new_version_available") {
                        SettingsManager.lastUpdateSoftwareDate = root.mainLatestServerDate.toLocaleDateString(Qt.ISODate);
                        root.mainLastVersionDate = root.mainLatestServerDate;
                        root.checkForUpdates();
                    }
                }
            }

            InstallSection {
                Layout.fillWidth: true
                sectionTitle: "Update ManualApp"
                updateStatus: root.manualAppUpdateStatus
                isDownloading: root.isManualAppDownloading
                isInstallerReady: root.isManualAppInstallerReady
                downloadProgress: root.manualAppDownloadProgress
                statusMessage: {
                    if (root.manualAppStatusMessage)
                        return root.manualAppStatusMessage;
                    if (root.manualAppUpdateStatus === "new_version_available")
                        return "Update available";
                    if (root.isManualAppInstallerReady)
                        return "Ready to run";
                    return "The new version is not found";
                }
                idleStatusColor: Theme.colorTextMuted
                latestServerDate: root.manualAppLatestServerDate
                lastVersionDate: root.manualAppLastVersionDate
                versionRowLabel: "Current version date:"
                infoLine1: "Executable: ManualApp.exe"
                infoLine2: "Path: " + InstallManager.buildInstallerPath("manual_app")
                cardHeight: 180

                downloadButtonText: root.isManualAppDownloading ? "Downloading..." : (root.manualAppUpdateStatus === "new_version_available" ? "Update Now" : "Download")
                downloadEnabled: !root.isManualAppDownloading && !InstallManager.isDownloading && !InstallManager.isInstalling

                installButtonText: {
                    if (InstallManager.isInstalling)
                        return "Installing...";
                    if (root.manualAppUpdateStatus === "new_version_available" && root.isManualAppInstallerReady)
                        return "Install Update";
                    return "Run Application";
                }
                installEnabled: root.isManualAppInstallerReady && !InstallManager.isInstalling && !root.isManualAppDownloading && !InstallManager.isDownloading

                onDownloadRequested: {
                    var url = DataManager.djangoBaseUrl();
                    root.isManualAppDownloading = true;
                    root.manualAppStatusMessage = "Starting download...";
                    root.manualAppDownloadProgress = 0;
                    InstallManager.downloadInstaller("manual_app", url, "", "");
                }

                onInstallRequested: {
                    InstallManager.runInstaller("manual_app");
                    if (root.manualAppUpdateStatus === "new_version_available") {
                        root.checkForUpdates();
                    }
                }
            }

            Connections {
                target: InstallManager

                function onDownloadProgressChanged() {
                    if (root.isMainDownloading) {
                        root.mainDownloadProgress = InstallManager.downloadProgress;
                        root.mainStatusMessage = "Downloading: " + Math.round(root.mainDownloadProgress) + "%";
                    }

                    if (root.isManualAppDownloading) {
                        root.manualAppDownloadProgress = InstallManager.downloadProgress;
                        root.manualAppStatusMessage = "Downloading: " + Math.round(root.manualAppDownloadProgress) + "%";
                    }
                }

                function onDownloadFinished(success) {
                    // ===== MAIN MODEL =====
                    if (root.isMainDownloading) {
                        root.isMainDownloading = false;
                        root.isMainInstallerReady = InstallManager.installerExists(root.currentModel);

                        if (success) {
                            root.mainDownloadProgress = 100;
                            root.mainStatusMessage = "Download completed successfully!";

                            if (root.mainLatestServerDate > new Date(0)) {
                                SettingsManager.saveDateIso("lastUpdateSoftwareDate", root.mainLatestServerDate.toISOString());
                            }
                        } else {
                            root.mainDownloadProgress = 0;
                            root.mainStatusMessage = "Download failed!";
                        }

                        root.checkForUpdates();
                    }

                    // ===== MANUAL APP =====
                    if (root.isManualAppDownloading) {
                        root.isManualAppDownloading = false;
                        root.isManualAppInstallerReady = InstallManager.installerExists("manual_app");

                        if (success) {
                            root.manualAppDownloadProgress = 100;
                            root.manualAppStatusMessage = "Download completed successfully!";

                            if (root.manualAppLatestServerDate > new Date(0)) {
                                SettingsManager.saveDateIso("lastUpdateManualAppDate", root.manualAppLatestServerDate.toISOString());
                            }
                        } else {
                            root.manualAppDownloadProgress = 0;
                            root.manualAppStatusMessage = "Download failed!";
                        }

                        root.checkForUpdates();
                    }
                }

                function onErrorOccurred(error) {
                    if (root.isMainDownloading) {
                        root.resetMainDownloadState();
                        root.mainStatusMessage = "Error: " + error;
                    }

                    if (root.isManualAppDownloading) {
                        root.resetManualAppDownloadState();
                        root.manualAppStatusMessage = "Error: " + error;
                    }
                }
            }

            Connections {
                target: InstallManager

                function onInstallerPathChanged() {
                    root.isMainInstallerReady = InstallManager.installerExists(root.currentModel);
                    root.isManualAppInstallerReady = InstallManager.installerExists("manual_app");
                    root.checkForUpdates();
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.colorBorder
                opacity: 0.3
                Layout.topMargin: 10
                Layout.bottomMargin: 10
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "Instructions:"
                    color: Theme.colorTextPrimary
                    font.pointSize: Theme.fontSubtitle
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 220
                    color: Theme.colorBgMuted
                    radius: Theme.radiusCard
                    border.color: Theme.colorBorder

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 5

                        Text {
                            text: "Installation Steps:"
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                            font.bold: true
                        }

                        Text {
                            text: "• Check for updates automatically when model or rail type changes"
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        Text {
                            text: "• Yellow 'Update Available' indicator shows when new version exists"
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        Text {
                            text: "• Click 'Download' or 'Update Now' to get the latest version"
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        Text {
                            text: "• Wait for download to complete (progress bar will show)"
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        Text {
                            text: "• Click 'Run Installer' or 'Install Update' to start installation"
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        Text {
                            text: "• After installation, the date is updated and status changes to 'Up to Date'"
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}

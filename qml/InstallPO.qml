pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "styles"

ScrollView {
    id: root

    clip: true
    anchors.fill: parent

    // ====== State ===========================================================
    property string currentModel: SettingsManager.currentModel
    property string railTypeMode: "irs52"
    property bool isInitialized: false

    // Main model download state
    property bool isMainDownloading: false
    property bool isMainInstallerReady: DataManager.installManager().installerExists(currentModel)
    property bool isMainInstalled: false
    property double mainDownloadProgress: 0.0
    property string mainStatusMessage: ""
    property string mainUpdateStatus: "" // "new_version_available", "up_to_date", "not_downloaded"
    property date mainLastVersionDate: new Date(0)
    property date mainLatestServerDate: new Date(0)

    // ManualApp specific properties
    property bool isManualAppDownloading: false
    property bool isManualAppInstallerReady: DataManager.installManager().installerExists("manual_app")
    property bool isManualAppInstalled: false
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
        if (root.currentModel === "" || root.railTypeMode === "")
            return;

        root.isLoadingDates = true;

        var mainServerDateStr = DataManager.installManager().getLastUpdateDate(DataManager.djangoBaseUrl(), root.currentModel, root.railTypeMode);
        var mainServerDate = mainServerDateStr ? new Date(mainServerDateStr) : new Date(0);

        root.mainLatestServerDate = mainServerDate;
        root.mainLastVersionDate = SettingsManager.lastUpdateSoftwareDate;

        const needMainUpdate = !root.isMainInstallerReady || !isValidDate(root.mainLastVersionDate) || root.mainLastVersionDate < root.mainLatestServerDate;
        root.mainUpdateStatus = needMainUpdate ? (root.isMainInstallerReady ? "new_version_available" : "not_downloaded") : "up_to_date";

        var manualServerDateStr = DataManager.installManager().getLastUpdateDate(DataManager.djangoBaseUrl(), "manual_app", "");
        var manualServerDate = manualServerDateStr ? new Date(manualServerDateStr) : new Date(0);

        root.manualAppLatestServerDate = manualServerDate;
        root.manualAppLastVersionDate = SettingsManager.lastUpdateManualAppDate;

        const needManualAppUpdate = !root.isManualAppInstallerReady || !isValidDate(root.manualAppLastVersionDate) || root.manualAppLastVersionDate < root.manualAppLatestServerDate;
        root.manualAppUpdateStatus = needManualAppUpdate ? (root.isManualAppInstallerReady ? "new_version_available" : "not_downloaded") : "up_to_date";

        root.isLoadingDates = false;
    }

    function saveRailTypeForCurrentModel() {
        if (root.currentModel === "kalmar32") {
            SettingsManager.railType = root.railTypeMode;
        }
    }

    function loadRailTypeForCurrentModel() {
        if (root.currentModel === "kalmar32") {
            var savedType = SettingsManager.railType;
            if (savedType) {
                root.railTypeMode = savedType;
            }
        }
    }

    function resetMainDownloadState() {
        root.isMainDownloading = false;
        root.mainDownloadProgress = 0;
        root.isMainInstallerReady = DataManager.installManager().installerExists(root.currentModel);
        root.checkForUpdates();
    }

    function resetManualAppDownloadState() {
        root.isManualAppDownloading = false;
        root.manualAppDownloadProgress = 0;
        root.isManualAppInstallerReady = DataManager.installManager().installerExists("manual_app");
        root.checkForUpdates();
    }

    Component.onCompleted: {
        loadRailTypeForCurrentModel();
        isInitialized = true;
        checkForUpdates();
    }

    onCurrentModelChanged: {
        loadRailTypeForCurrentModel();
        if (isInitialized) checkForUpdates();
    }

    onRailTypeModeChanged: {
        if (root.currentModel === "kalmar32") {
            saveRailTypeForCurrentModel();
        }
        if (isInitialized) checkForUpdates();
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
                        text: root.currentModel === "kalmar32" ? "KALMAR-32" : "PHASAR-32"
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSubtitle
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // Индикатор загрузки
                    BusyIndicator {
                        visible: root.isLoadingDates
                        running: visible
                        width: 20
                        height: 20
                    }
                }
            }

            // Download & Installation Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Download & Install Software"
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSubtitle
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        visible: root.mainUpdateStatus === "new_version_available"
                        color: Theme.colorUpdate
                        radius: 4
                        height: 24
                        width: 160

                        Text {
                            anchors.centerIn: parent
                            text: "Update Available!"
                            color: "white"
                            font.pointSize: Theme.fontSmall
                            font.bold: true
                        }
                    }

                    Rectangle {
                        visible: root.mainUpdateStatus === "up_to_date"
                        color: Theme.colorSuccess
                        radius: 4
                        height: 24
                        width: 100

                        Text {
                            anchors.centerIn: parent
                            text: "Up to Date"
                            color: "white"
                            font.pointSize: Theme.fontSmall
                            font.bold: true
                        }
                    }
                }

                // Status Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.currentModel === "kalmar32" ? 250 : 200
                    color: Theme.colorBgMuted
                    radius: Theme.radiusCard
                    border.color: Theme.colorBorder

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        anchors.topMargin: 15
                        anchors.bottomMargin: 20
                        spacing: 2

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: root.mainStatusMessage || (root.isMainInstallerReady ? "Installer ready" : "Not downloaded")
                                color: {
                                    if (root.isMainDownloading)
                                        Theme.colorUpdate;
                                    else if (root.mainUpdateStatus === "new_version_available")
                                        Theme.colorUpdate;
                                    else if (root.isMainInstallerReady)
                                        Theme.colorSuccess;
                                    else
                                        Theme.colorError;
                                }
                                font.pointSize: Theme.fontBody
                                font.bold: root.mainUpdateStatus === "new_version_available"
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                        }

                        GridLayout {
                            columns: 2
                            columnSpacing: 20
                            rowSpacing: 5
                            Layout.fillWidth: true

                            Text {
                                text: "Latest server version:"
                                color: Theme.colorTextMuted
                                font.pointSize: Theme.fontSmall
                            }

                            Text {
                                text: root.mainLatestServerDate > new Date(0) ? Qt.formatDate(root.mainLatestServerDate, "yyyy-MM-dd") : "Not available"
                                color: Theme.colorTextPrimary
                                font.pointSize: Theme.fontSmall
                                font.bold: root.mainLastVersionDate < root.mainLatestServerDate
                            }

                            Text {
                                text: "Downloaded version:"
                                color: Theme.colorTextMuted
                                font.pointSize: Theme.fontSmall
                            }

                            Text {
                                text: root.mainLastVersionDate > new Date(0) ? Qt.formatDate(root.mainLastVersionDate, "yyyy-MM-dd") : "Never"
                                color: root.mainLastVersionDate < root.mainLatestServerDate ? Theme.colorUpdate : Theme.colorTextPrimary
                                font.pointSize: Theme.fontSmall
                                font.bold: root.mainLastVersionDate < root.mainLatestServerDate
                            }
                        }

                        ProgressBar {
                            Layout.fillWidth: true
                            visible: root.isMainDownloading
                            value: root.mainDownloadProgress
                            from: 0
                            to: 100
                        }

                        // Rail type mode
                        ColumnLayout {
                            id: railTypeModeSection
                            anchors.margins: 5
                            spacing: 5
                            visible: root.currentModel === "kalmar32"

                            Text {
                                text: "Rail type: "
                                color: Theme.colorTextMuted
                                font.pointSize: Theme.fontSmall
                                font.bold: true
                            }

                            RowLayout {
                                spacing: 10
                                Layout.alignment: Qt.AlignLeft

                                Repeater {
                                    model: ["p65", "irs52", "uic60"]

                                    Rectangle {
                                        id: railTypeCard
                                        required property var modelData

                                        width: 100
                                        height: 30
                                        radius: 4
                                        color: root.railTypeMode === modelData ? Theme.colorButtonPrimary : Theme.colorBgPrimary
                                        border.color: root.railTypeMode === modelData ? Theme.colorButtonPrimary : Theme.colorBorder

                                        Text {
                                            anchors.centerIn: parent
                                            text: railTypeCard.modelData.toUpperCase()
                                            color: root.railTypeMode === railTypeCard.modelData ? "white" : Theme.colorTextMuted
                                            font.pointSize: Theme.fontSmall
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                root.railTypeMode = railTypeCard.modelData;
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            text: "Installer: " + (root.currentModel === "kalmar32" ? "kalmar.exe" : "phasar.exe")
                            color: Theme.colorTextMuted
                            font.pointSize: Theme.fontSmall
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "Path: " + (root.currentModel === "kalmar32" ? DataManager.installManager().buildInstallerPath("kalmar32") : DataManager.installManager().buildInstallerPath("phasar32"))
                            color: Theme.colorTextMuted
                            font.pointSize: Theme.fontSmall
                            Layout.fillWidth: true
                        }
                    }
                }

                // Download & Install Buttons
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: -36
                    spacing: 12
                    z: 2

                    Button {
                        id: downloadButton
                        Layout.preferredWidth: 170
                        Layout.preferredHeight: 42

                        text: {
                            if (root.isMainDownloading)
                                "Downloading...";
                            else if (root.mainUpdateStatus === "new_version_available")
                                "Update Now";
                            else if (root.isMainInstallerReady)
                                "Redownload";
                            else
                                "Download";
                        }

                        enabled: !root.isMainDownloading && !DataManager.installManager().isInstalling && !root.isManualAppDownloading

                        background: Rectangle {
                            color: {
                                if (!parent.enabled)
                                    return Theme.colorButtonDisabled;
                                if (root.mainUpdateStatus === "new_version_available")
                                    return Theme.colorUpdate;
                                return Theme.colorButtonSecondary;
                            }
                            radius: Theme.radiusButton
                        }

                        contentItem: Text {
                            text: downloadButton.text
                            color: "white"
                            font.pointSize: Theme.fontBody
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            var url = DataManager.djangoBaseUrl();

                            root.isMainDownloading = true;
                            root.mainStatusMessage = "Starting download...";
                            root.mainDownloadProgress = 0;

                            DataManager.installManager().downloadInstaller(root.currentModel, url, root.railTypeMode);
                        }
                    }

                    Button {
                        id: installButton
                        Layout.preferredWidth: 170
                        Layout.preferredHeight: 42

                        text: {
                            if (DataManager.installManager().isInstalling)
                                return "Installing...";
                            return "Run Installer";
                        }

                        enabled: !DataManager.installManager().isInstalling && !root.isMainDownloading && !DataManager.installManager().isDownloading && root.isMainInstallerReady

                        background: Rectangle {
                            color: parent.enabled ? (root.mainUpdateStatus === "new_version_available" ? Theme.colorUpdate : Theme.colorButtonPrimary) : Theme.colorButtonDisabled
                            radius: Theme.radiusButton
                        }

                        contentItem: Text {
                            text: installButton.text
                            color: "white"
                            font.pointSize: Theme.fontBody
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            DataManager.installManager().runInstaller(root.currentModel);

                            if (root.mainUpdateStatus === "new_version_available") {
                                SettingsManager.lastUpdateSoftwareDate = root.mainLatestServerDate.toLocaleDateString(Qt.ISODate);

                                root.mainLastVersionDate = root.mainLatestServerDate;
                                root.checkForUpdates();
                            }
                        }
                    }
                }
            }

            // ====== ManualApp Update Section ============================================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Update ManualApp"
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSubtitle
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        visible: root.manualAppUpdateStatus === "new_version_available"
                        color: Theme.colorUpdate
                        radius: 4
                        height: 24
                        width: 160

                        Text {
                            anchors.centerIn: parent
                            text: "Update Available!"
                            color: "white"
                            font.pointSize: Theme.fontSmall
                            font.bold: true
                        }
                    }

                    Rectangle {
                        visible: root.manualAppUpdateStatus === "up_to_date"
                        color: Theme.colorSuccess
                        radius: 4
                        height: 24
                        width: 100

                        Text {
                            anchors.centerIn: parent
                            text: "Up to Date"
                            color: "white"
                            font.pointSize: Theme.fontSmall
                            font.bold: true
                        }
                    }
                }

                // Status Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    color: Theme.colorBgMuted
                    radius: Theme.radiusCard
                    border.color: Theme.colorBorder

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        anchors.topMargin: 15
                        anchors.bottomMargin: 20
                        spacing: 2

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                id: manualAppStatusText
                                text: {
                                    if (root.manualAppStatusMessage)
                                        return root.manualAppStatusMessage;
                                    if (root.manualAppUpdateStatus === "new_version_available")
                                        return "Update available";
                                    if (root.isManualAppInstallerReady)
                                        return "Installer ready";
                                    return "Not downloaded";
                                }

                                color: {
                                    if (root.isManualAppDownloading)
                                        return Theme.colorUpdate;
                                    if (root.manualAppUpdateStatus === "new_version_available")
                                        return Theme.colorUpdate;
                                    if (root.isManualAppInstallerReady)
                                        return Theme.colorSuccess;
                                    return Theme.colorError;
                                }
                                font.pointSize: Theme.fontBody
                                font.bold: root.manualAppUpdateStatus === "new_version_available"
                                Layout.fillWidth: true
                            }
                        }

                        GridLayout {
                            columns: 2
                            columnSpacing: 20
                            rowSpacing: 5
                            Layout.fillWidth: true

                            Text {
                                text: "Latest server version:"
                                color: Theme.colorTextMuted
                                font.pointSize: Theme.fontSmall
                            }

                            Text {
                                text: root.manualAppLatestServerDate > new Date(0) ? Qt.formatDate(root.manualAppLatestServerDate, "yyyy-MM-dd") : "Not available"
                                color: Theme.colorTextPrimary
                                font.pointSize: Theme.fontSmall
                                font.bold: root.manualAppLastVersionDate < root.manualAppLatestServerDate
                            }

                            Text {
                                text: "Installed version:"
                                color: Theme.colorTextMuted
                                font.pointSize: Theme.fontSmall
                            }

                            Text {
                                text: root.manualAppLastVersionDate > new Date(0) ? Qt.formatDate(root.manualAppLastVersionDate, "yyyy-MM-dd") : "Never"
                                color: root.manualAppLastVersionDate < root.manualAppLatestServerDate ? Theme.colorUpdate : Theme.colorTextPrimary
                                font.pointSize: Theme.fontSmall
                                font.bold: root.manualAppLastVersionDate < root.manualAppLatestServerDate
                            }
                        }

                        ProgressBar {
                            id: manualAppDownloadProgress
                            Layout.fillWidth: true
                            visible: root.isManualAppDownloading
                            value: root.manualAppDownloadProgress
                            from: 0
                            to: 100
                        }

                        Text {
                            text: "Installer: ManualApp.exe"
                            color: Theme.colorTextMuted
                            font.pointSize: Theme.fontSmall
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "Path: " + DataManager.installManager().buildInstallerPath("manual_app")
                            color: Theme.colorTextMuted
                            font.pointSize: Theme.fontSmall
                            Layout.fillWidth: true
                        }
                    }
                }

                // Download & Install Buttons
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: -36
                    spacing: 12
                    z: 2

                    Button {
                        id: manualAppDownloadButton
                        Layout.preferredWidth: 170
                        Layout.preferredHeight: 42

                        text: {
                            if (root.isManualAppDownloading)
                                return "Downloading...";
                            if (root.manualAppUpdateStatus === "new_version_available")
                                return "Update Now";
                            if (root.isManualAppInstallerReady)
                                return "Redownload";
                            return "Download";
                        }

                        enabled: !root.isManualAppDownloading && !DataManager.installManager().isDownloading && !DataManager.installManager().isInstalling

                        background: Rectangle {
                            color: {
                                if (!parent.enabled)
                                    return Theme.colorButtonDisabled;
                                if (root.manualAppUpdateStatus === "new_version_available")
                                    return Theme.colorUpdate;
                                return Theme.colorButtonSecondary;
                            }
                            radius: Theme.radiusButton
                        }

                        contentItem: Text {
                            text: manualAppDownloadButton.text
                            color: "white"
                            font.pointSize: Theme.fontBody
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            var url = DataManager.djangoBaseUrl();
                            root.isManualAppDownloading = true;
                            root.manualAppStatusMessage = "Starting download...";
                            root.manualAppDownloadProgress = 0;
                            DataManager.installManager().downloadInstaller("manual_app", url, "");
                        }
                    }

                    Button {
                        id: manualAppInstallButton
                        Layout.preferredWidth: 170
                        Layout.preferredHeight: 42

                        text: {
                            if (DataManager.installManager().isInstalling)
                                return "Installing...";
                            if (root.manualAppUpdateStatus === "new_version_available" && root.isManualAppInstallerReady)
                                return "Install Update";
                            return "Run Installer";
                        }

                        enabled: !DataManager.installManager().isInstalling && !root.isManualAppDownloading && !DataManager.installManager().isDownloading && root.isManualAppInstallerReady

                        background: Rectangle {
                            color: parent.enabled ? (root.manualAppUpdateStatus === "new_version_available" ? Theme.colorUpdate : Theme.colorButtonPrimary) : Theme.colorButtonDisabled
                            radius: Theme.radiusButton
                        }

                        contentItem: Text {
                            text: manualAppInstallButton.text
                            color: "white"
                            font.pointSize: Theme.fontBody
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            DataManager.installManager().runInstaller("manual_app");

                            if (root.manualAppUpdateStatus === "new_version_available") {
                                root.checkForUpdates();
                            }
                        }
                    }
                }
            }

            Connections {
                target: DataManager.installManager()

                function onDownloadProgressChanged() {
                    if (root.isMainDownloading) {
                        root.mainDownloadProgress = DataManager.installManager().downloadProgress;
                        root.mainStatusMessage = "Downloading: " + Math.round(root.mainDownloadProgress) + "%";
                    }

                    if (root.isManualAppDownloading) {
                        root.manualAppDownloadProgress = DataManager.installManager().downloadProgress;
                        root.manualAppStatusMessage = "Downloading: " + Math.round(root.manualAppDownloadProgress) + "%";
                    }
                }

                function onDownloadFinished(success) {
                    // ===== MAIN MODEL =====
                    if (root.isMainDownloading) {
                        root.isMainDownloading = false;
                        root.isMainInstallerReady = DataManager.installManager().installerExists(root.currentModel);

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
                        root.isManualAppInstallerReady = DataManager.installManager().installerExists("manual_app");

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
                target: DataManager.installManager()

                function onInstallerPathChanged() {
                    root.isMainInstallerReady = DataManager.installManager().installerExists(root.currentModel);
                    root.isManualAppInstallerReady = DataManager.installManager().installerExists("manual_app");
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

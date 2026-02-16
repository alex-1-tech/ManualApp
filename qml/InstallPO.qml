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
    property bool isDownloading: DataManager.installManager().isDownloading
    property bool isInstallerReady: DataManager.installManager().installerExists(currentModel)
    property bool isActivating: false
    property bool activationSuccessful: DataManager.installManager().isLicenseActivate && SettingsManager.deviceHWID != ""
    property string mode: "control"
    property string tempHostHWID: SettingsManager.hostHWID
    property string tempDeviceHWID: SettingsManager.deviceHWID
    property string tempLicensePassword: ""

    // ManualApp specific properties
    property bool isManualAppDownloading: false
    property bool isManualAppInstallerReady: DataManager.installManager().installerExists("manual_app")
    property string manualAppStatusMessage: ""
    property double manualAppDownloadProgress: 0.0
    property string manualAppInstallerPath: ""

    // Track current downloading model
    property string currentDownloadingModel: ""

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
                        text: root.currentModel === "kalmar32" ? "KALMAR-32" : "PHAZAR-32"
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSubtitle
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: {
                            if (root.isDownloading && root.currentDownloadingModel === root.currentModel)
                                "Downloading...";
                            else if (root.isInstallerReady)
                                "Ready";
                            else
                                "Not downloaded";
                        }
                        color: {
                            if (root.isDownloading && root.currentDownloadingModel === root.currentModel)
                                Theme.colorWarning;
                            else if (root.isInstallerReady)
                                Theme.colorSuccess;
                            else
                                Theme.colorError;
                        }
                        font.pointSize: Theme.fontBody
                    }
                }
            }

            // Download & Installation Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15

                Text {
                    text: "Download & Install Software"
                    color: Theme.colorTextPrimary
                    font.pointSize: Theme.fontSubtitle
                    font.bold: true
                }

                // Status Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 140
                    color: Theme.colorBgMuted
                    radius: Theme.radiusCard
                    border.color: Theme.colorBorder

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 5

                        Text {
                            text: {
                                if (root.isDownloading && root.currentDownloadingModel === root.currentModel)
                                    return DataManager.installManager().statusMessage;
                                else if (root.isInstallerReady)
                                    return "Ready to install";
                                else
                                    return "Not downloaded";
                            }
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontBody
                            Layout.fillWidth: true
                        }

                        ProgressBar {
                            id: downloadProgress
                            Layout.fillWidth: true
                            visible: root.isDownloading && root.currentDownloadingModel === root.currentModel
                            value: DataManager.installManager().downloadProgress
                            from: 0
                            to: 100
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
                    spacing: 15

                    Button {
                        id: downloadButton
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 50
                        text: {
                            if (root.isDownloading && root.currentDownloadingModel === root.currentModel)
                                "Downloading...";
                            else if (root.isInstallerReady)
                                "Redownload";
                            else
                                "Download Installer";
                        }
                        enabled: {
                            if (root.isDownloading && root.currentDownloadingModel !== root.currentModel)
                                return false;
                            return !root.isDownloading && !DataManager.installManager().isInstalling;
                        }

                        background: Rectangle {
                            color: parent.enabled ? Theme.colorButtonSecondary : Theme.colorButtonDisabled
                            radius: Theme.radiusButton
                        }

                        contentItem: Text {
                            text: downloadButton.text
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontBody
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            var url = DataManager.djangoBaseUrl();
                            root.currentDownloadingModel = root.currentModel;
                            DataManager.installManager().downloadInstaller(root.currentModel, url);
                        }
                    }

                    Button {
                        id: installButton
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 50
                        text: DataManager.installManager().isInstalling ? "Installing..." : "Run Installer"
                        enabled: !DataManager.installManager().isInstalling && !root.isDownloading && root.isInstallerReady

                        background: Rectangle {
                            color: parent.enabled ? Theme.colorButtonPrimary : Theme.colorButtonDisabled
                            radius: Theme.radiusButton
                        }

                        contentItem: Text {
                            text: installButton.text
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontBody
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            DataManager.installManager().runInstaller(root.currentModel);
                        }
                    }
                }
            }

            // ====== ManualApp Update Section ============================================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15

                Text {
                    text: "Update ManualApp"
                    color: Theme.colorTextPrimary
                    font.pointSize: Theme.fontSubtitle
                    font.bold: true
                }

                // Status Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 140
                    color: Theme.colorBgMuted
                    radius: Theme.radiusCard
                    border.color: Theme.colorBorder

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 5

                        Text {
                            id: manualAppStatusText
                            text: root.manualAppStatusMessage || (root.isManualAppInstallerReady ? "Ready" : "Not downloaded")
                            color: {
                                if (root.isManualAppDownloading)
                                    Theme.colorWarning;
                                else if (root.isManualAppInstallerReady)
                                    Theme.colorSuccess;
                                else
                                    Theme.colorError;
                            }
                            font.pointSize: Theme.fontBody
                            Layout.fillWidth: true
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
                    spacing: 15

                    Button {
                        id: manualAppDownloadButton
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 50

                        text: {
                            if (root.isManualAppDownloading)
                                "Downloading...";
                            else if (root.isManualAppInstallerReady)
                                "Redownload";
                            else
                                "Download ManualApp";
                        }
                        enabled: !root.isManualAppDownloading && !DataManager.installManager().isDownloading && !DataManager.installManager().isInstalling

                        background: Rectangle {
                            color: parent.enabled ? Theme.colorButtonSecondary : Theme.colorButtonDisabled
                            radius: Theme.radiusButton
                        }

                        contentItem: Text {
                            text: manualAppDownloadButton.text
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontBody
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            var url = DataManager.djangoBaseUrl();
                            root.isManualAppDownloading = true;
                            root.currentDownloadingModel = "manual_app";
                            root.manualAppStatusMessage = "Starting download...";
                            root.manualAppDownloadProgress = 0;
                            DataManager.installManager().downloadInstaller("manual_app", url);
                        }
                    }

                    Button {
                        id: manualAppInstallButton
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 50
                        text: DataManager.installManager().isInstalling ? "Installing..." : "Run Installer"
                        enabled: !DataManager.installManager().isInstalling && !root.isManualAppDownloading && !DataManager.installManager().isDownloading && root.isManualAppInstallerReady

                        background: Rectangle {
                            color: parent.enabled ? Theme.colorButtonPrimary : Theme.colorButtonDisabled
                            radius: Theme.radiusButton
                        }

                        contentItem: Text {
                            text: manualAppInstallButton.text
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontBody
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            DataManager.installManager().runInstaller("manual_app");
                        }
                    }
                }
            }

            Connections {
                target: DataManager.installManager()

                function onDownloadFinished(success) {
                    if (root.currentDownloadingModel === root.currentModel) {
                        root.currentDownloadingModel = "";
                    }

                    if (root.isManualAppDownloading) {
                        root.isManualAppDownloading = false;
                        root.isManualAppInstallerReady = DataManager.installManager().installerExists("manual_app");

                        if (success) {
                            root.manualAppStatusMessage = "Download completed successfully!";
                            root.manualAppDownloadProgress = 100;
                        } else {
                            root.manualAppStatusMessage = "Download failed!";
                            root.manualAppDownloadProgress = 0;
                        }
                    }
                }

                function onDownloadProgressChanged() {
                    if (root.currentDownloadingModel === root.currentModel) {}

                    if (root.isManualAppDownloading) {
                        root.manualAppDownloadProgress = DataManager.installManager().downloadProgress;
                        root.manualAppStatusMessage = "Downloading: " + Math.round(DataManager.installManager().downloadProgress) + "%";
                    }
                }

                function onIsDownloadingChanged() {
                    if (!DataManager.installManager().isDownloading) {
                        if (root.isManualAppDownloading && root.currentDownloadingModel !== "manual_app") {
                            root.isManualAppDownloading = false;
                            root.manualAppStatusMessage = "Download stopped";
                        }
                        if (root.currentDownloadingModel !== "" && root.currentDownloadingModel !== "manual_app") {
                            root.currentDownloadingModel = "";
                        }
                    }
                }

                function onInstallationFinished(success) {
                    root.isInstallerReady = DataManager.installManager().installerExists(root.currentModel);
                    root.isManualAppInstallerReady = DataManager.installManager().installerExists("manual_app");
                }

                function onErrorOccurred(error) {
                    if (root.isManualAppDownloading) {
                        root.isManualAppDownloading = false;
                        root.manualAppStatusMessage = "Error: " + error;
                        root.manualAppDownloadProgress = 0;
                    }
                    if (root.currentDownloadingModel !== "") {
                        root.currentDownloadingModel = "";
                    }
                }
            }

            Connections {
                target: DataManager.installManager()

                function onInstallerPathChanged() {
                    root.isInstallerReady = DataManager.installManager().installerExists(root.currentModel);
                    root.isManualAppInstallerReady = DataManager.installManager().installerExists("manual_app");
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

            // === СЕКЦИЯ АКТИВАЦИИ ================================================

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15

                Text {
                    text: "Software Activation"
                    color: Theme.colorTextPrimary
                    font.pointSize: Theme.fontSubtitle
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.currentModel === "kalmar32" ? 320 : 380
                    color: Theme.colorBgMuted
                    radius: Theme.radiusCard
                    border.color: Theme.colorBorder

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15

                        // Software Mode
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                text: "Software Mode"
                                color: Theme.colorTextPrimary
                                font.pointSize: Theme.fontSmall
                                font.bold: true
                            }

                            RowLayout {
                                spacing: 10
                                Layout.alignment: Qt.AlignLeft

                                Rectangle {
                                    id: controlModeBtn
                                    width: 100
                                    height: 30
                                    radius: 4
                                    color: root.mode === "control" ? Theme.colorButtonPrimary : Theme.colorBgPrimary
                                    border.color: root.mode === "control" ? Theme.colorButtonPrimary : Theme.colorBorder

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Control"
                                        color: root.mode === "control" ? "white" : Theme.colorTextPrimary
                                        font.pointSize: Theme.fontSmall
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: root.mode = "control"
                                    }
                                }

                                Rectangle {
                                    id: analysisModeBtn
                                    width: 100
                                    height: 30
                                    radius: 4
                                    color: root.mode === "analysis" ? Theme.colorButtonPrimary : Theme.colorBgPrimary
                                    border.color: root.mode === "analysis" ? Theme.colorButtonPrimary : Theme.colorBorder

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Analysis"
                                        color: root.mode === "analysis" ? "white" : Theme.colorTextPrimary
                                        font.pointSize: Theme.fontSmall
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: root.mode = "analysis"
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: Theme.colorBorder
                            opacity: 0.3
                        }

                        // HWID Input Fields
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 15

                            // Host HWID (только для phasar32)
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 5
                                visible: root.currentModel === "phasar32"

                                Text {
                                    text: "Host HWID *"
                                    color: Theme.colorTextPrimary
                                    font.pointSize: Theme.fontSmall
                                    font.bold: true
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    color: Theme.colorBgPrimary
                                    radius: 6
                                    border.color: Theme.colorBorder
                                    border.width: 1

                                    TextInput {
                                        id: hostHwidInputField
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        verticalAlignment: Text.AlignVCenter
                                        color: Theme.colorTextPrimary
                                        font.pointSize: Theme.fontBody
                                        text: root.tempHostHWID
                                        clip: true
                                        enabled: !root.activationSuccessful

                                        onTextChanged: {
                                            root.tempHostHWID = text;
                                        }

                                        Label {
                                            anchors.fill: parent
                                            verticalAlignment: Text.AlignVCenter
                                            text: "Enter Host HWID (required)..."
                                            color: Theme.colorTextMuted
                                            font.pointSize: Theme.fontBody
                                            visible: hostHwidInputField.text === ""
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }

                            // Device HWID (для обеих моделей)
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 5

                                Text {
                                    text: "Device HWID *"
                                    color: Theme.colorTextPrimary
                                    font.pointSize: Theme.fontSmall
                                    font.bold: true
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    color: Theme.colorBgPrimary
                                    radius: 6
                                    border.color: Theme.colorBorder
                                    border.width: 1

                                    TextInput {
                                        id: deviceHwidInputField
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        verticalAlignment: Text.AlignVCenter
                                        color: Theme.colorTextPrimary
                                        font.pointSize: Theme.fontBody
                                        text: root.tempDeviceHWID
                                        clip: true
                                        enabled: !root.activationSuccessful

                                        onTextChanged: {
                                            root.tempDeviceHWID = text;
                                        }

                                        Label {
                                            anchors.fill: parent
                                            verticalAlignment: Text.AlignVCenter
                                            text: "Enter Device HWID (required)..."
                                            color: Theme.colorTextMuted
                                            font.pointSize: Theme.fontBody
                                            visible: deviceHwidInputField.text === ""
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                text: "License Password *"
                                color: Theme.colorTextPrimary
                                font.pointSize: Theme.fontSmall
                                font.bold: true
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                color: Theme.colorBgPrimary
                                radius: 6
                                border.color: Theme.colorBorder
                                border.width: 1

                                TextInput {
                                    id: licensePasswordInputField
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    verticalAlignment: Text.AlignVCenter
                                    color: Theme.colorTextPrimary
                                    font.pointSize: Theme.fontBody
                                    text: root.tempLicensePassword
                                    clip: true
                                    enabled: !root.activationSuccessful

                                    onTextChanged: {
                                        root.tempLicensePassword = text;
                                    }

                                    Label {
                                        anchors.fill: parent
                                        verticalAlignment: Text.AlignVCenter
                                        text: "Enter license password..."
                                        color: Theme.colorTextMuted
                                        font.pointSize: Theme.fontBody
                                        visible: licensePasswordInputField.text === ""
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }

                        Text {
                            text: {
                                if (root.currentModel === "kalmar32") {
                                    "Note: Device HWID is required for KALMAR-32 activation.";
                                } else {
                                    "Note: Both Host HWID and Device HWID are required for PHAZAR-32 activation.";
                                }
                            }
                            color: Theme.colorTextMuted
                            font.pointSize: 9
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }

                        Button {
                            id: activateButton
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 40
                            Layout.alignment: Qt.AlignHCenter
                            text: {
                                if (root.isActivating)
                                    "Activating...";
                                else if (root.activationSuccessful)
                                    "Already Activated";
                                else
                                    "Activate Software";
                            }
                            enabled: {
                                if (root.isActivating || root.activationSuccessful)
                                    return false;

                                if (root.currentModel === "kalmar32") {
                                    return root.tempDeviceHWID.trim() !== "" && root.tempLicensePassword.trim() !== "";
                                } else {
                                    return root.tempHostHWID.trim() !== "" && root.tempDeviceHWID.trim() !== "" && root.tempLicensePassword.trim() !== "";
                                }
                            }

                            background: Rectangle {
                                color: {
                                    if (root.activationSuccessful)
                                        Theme.colorSuccess;
                                    else if (parent.enabled)
                                        Theme.colorButtonPrimary;
                                    else
                                        Theme.colorButtonDisabled;
                                }
                                radius: Theme.radiusButton
                            }

                            contentItem: Text {
                                text: activateButton.text
                                color: root.activationSuccessful ? "white" : (parent.enabled ? Theme.colorTextPrimary : Theme.colorTextMuted)
                                font.pointSize: Theme.fontBody
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                if (!root.activationSuccessful) {
                                    root.activateSoftware();
                                }
                            }
                        }
                    }
                }
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
                            text: "• Click 'Download Installer' to download the software"
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        Text {
                            text: "• Wait for download to complete (progress bar will show)"
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        Text {
                            text: "• Click 'Run Installer' to start installation"
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        Text {
                            text: "• Follow the installation steps in the opened window"
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        Text {
                            text: "• Copy 'Hardware ID' (HWID)"
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        Text {
                            text: "• Restart this application after installation"
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }

            Popup {
                id: confirmDialog
                modal: true
                focus: true
                width: 400
                height: 180
                anchors.centerIn: Overlay.overlay
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                background: Rectangle {
                    color: Theme.colorBgPrimary
                    radius: 8
                    border.color: Theme.colorBorder
                    border.width: 1
                }

                contentItem: ColumnLayout {
                    spacing: 20

                    Label {
                        text: qsTr("Save confirmation")
                        font.bold: true
                        font.pointSize: Theme.fontSubtitle
                        color: Theme.colorTextPrimary
                        Layout.fillWidth: true
                    }

                    Label {
                        text: qsTr("Are you sure you want to save the settings?\nAfter saving, some of them cannot be changed.")
                        wrapMode: Text.WordWrap
                        color: Theme.colorTextSecondary
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Button {
                            id: cancelButton
                            text: "Cancel"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 35

                            background: Rectangle {
                                color: cancelButton.pressed ? Theme.colorButtonSecondaryHover : Theme.colorButtonSecondary
                                radius: Theme.radiusButton
                            }

                            contentItem: Text {
                                text: cancelButton.text
                                color: Theme.colorTextPrimary
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pointSize: Theme.fontSmall
                            }

                            onClicked: confirmDialog.close()
                        }

                        Button {
                            id: okButton
                            text: "OK"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 35

                            background: Rectangle {
                                color: okButton.pressed ? Theme.colorButtonPrimaryHover : Theme.colorButtonPrimary
                                radius: Theme.radiusButton
                            }

                            contentItem: Text {
                                text: okButton.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pointSize: Theme.fontSmall
                            }

                            onClicked: {
                                confirmDialog.close();

                                uploadProgressPopup.open();
                                uploadProgressPopup.uploadInProgress = true;

                                SettingsManager.saveModelSettings();

                                var uploadUrl = "";
                                if (SettingsManager.currentModel == "kalmar32") {
                                    uploadUrl = DataManager.djangoBaseUrl() + "/api/kalmar32/";
                                } else {
                                    uploadUrl = DataManager.djangoBaseUrl() + "/api/phasar32/";
                                }

                                DataManager.uploadSettingsToDjango(uploadUrl);
                            }
                        }
                    }
                }
            }

            Popup {
                id: uploadProgressPopup
                modal: true
                focus: true
                width: 400
                height: 220
                anchors.centerIn: Overlay.overlay
                closePolicy: Popup.NoAutoClose

                background: Rectangle {
                    color: Theme.colorBgPrimary
                    radius: 8
                    border.color: Theme.colorBorder
                    border.width: 1
                }

                property bool uploadComplete: false
                property bool uploadSuccess: false
                property bool uploadInProgress: false

                onOpened: {
                    if (uploadProgressPopup.uploadComplete) {
                        retryTimer.start();
                        return;
                    }

                    uploadProgressPopup.uploadComplete = false;
                    uploadProgressPopup.uploadSuccess = false;
                    uploadProgressPopup.uploadInProgress = true;
                    resetTimer.start();
                }

                onClosed: {
                    resetTimer.stop();
                    retryTimer.stop();
                    uploadProgressPopup.uploadInProgress = false;
                }

                Timer {
                    id: resetTimer
                    interval: 10000
                    repeat: false
                    onTriggered: {
                        if (uploadProgressPopup.uploadInProgress && !uploadProgressPopup.uploadComplete) {
                            uploadProgressPopup.uploadInProgress = false;
                            uploadProgressPopup.uploadComplete = true;
                            uploadProgressPopup.uploadSuccess = false;
                            retryTimer.start();
                        }
                    }
                }

                Timer {
                    id: retryTimer
                    interval: 3000
                    repeat: false
                    onTriggered: {
                        uploadProgressPopup.close();
                    }
                }

                Connections {
                    target: DataManager

                    function onErrorOccurred(errorMsg) {
                        if (uploadProgressPopup.uploadInProgress && !uploadProgressPopup.uploadComplete) {
                            uploadProgressPopup.uploadInProgress = false;
                            uploadProgressPopup.uploadComplete = true;
                            uploadProgressPopup.uploadSuccess = false;
                            retryTimer.start();
                        } else {
                            console.log("QML: ignoring errorOccurred (not current upload or already completed)");
                        }
                    }

                    function onSettingsUploadFinished(success) {
                        if (uploadProgressPopup.uploadInProgress && !uploadProgressPopup.uploadComplete) {
                            uploadProgressPopup.uploadInProgress = false;
                            resetTimer.stop();
                            uploadProgressPopup.uploadComplete = true;
                            uploadProgressPopup.uploadSuccess = success;
                            retryTimer.start();
                        } else {
                            if (!uploadProgressPopup.uploadComplete) {
                                uploadProgressPopup.uploadComplete = true;
                                uploadProgressPopup.uploadSuccess = success;
                            } else {
                                console.log("QML: settingsUploadFinished ignored (already completed)");
                            }
                        }
                    }

                    function onLoadingChanged() {
                    }
                }

                contentItem: ColumnLayout {
                    spacing: 20

                    Label {
                        text: uploadProgressPopup.uploadComplete ? (uploadProgressPopup.uploadSuccess ? qsTr("Upload Successful") : qsTr("Upload Failed")) : qsTr("Uploading Settings")
                        font.bold: true
                        font.pointSize: Theme.fontSubtitle
                        color: uploadProgressPopup.uploadComplete ? (uploadProgressPopup.uploadSuccess ? Theme.colorSuccess : Theme.colorError) : Theme.colorTextPrimary
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    ProgressBar {
                        id: progressBar
                        Layout.fillWidth: true
                        Layout.preferredHeight: 8
                        visible: !uploadProgressPopup.uploadComplete
                        indeterminate: true

                        background: Rectangle {
                            color: Theme.colorTextSecondary
                            radius: 4
                        }

                        contentItem: Item {
                            implicitHeight: 8

                            Rectangle {
                                width: progressBar.visualPosition * parent.width
                                height: parent.height
                                radius: 4
                                color: Theme.colorButtonPrimary

                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    running: progressBar.visible
                                    NumberAnimation {
                                        from: 0.3
                                        to: 1.0
                                        duration: 800
                                        easing.type: Easing.InOutQuad
                                    }
                                    NumberAnimation {
                                        from: 1.0
                                        to: 0.3
                                        duration: 800
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                            }
                        }
                    }

                    Item {
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 60
                        Layout.alignment: Qt.AlignHCenter
                        visible: uploadProgressPopup.uploadComplete

                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: uploadProgressPopup.uploadSuccess ? Theme.colorSuccess : Theme.colorError

                            Text {
                                anchors.centerIn: parent
                                text: uploadProgressPopup.uploadSuccess ? "✓" : "!"
                                color: "white"
                                font.pointSize: 24
                                font.bold: true
                            }
                        }
                    }

                    Label {
                        text: uploadProgressPopup.uploadComplete ? (uploadProgressPopup.uploadSuccess ? qsTr("Settings have been successfully uploaded to the server.") : qsTr("Failed to upload settings. Please check your connection and try again.")) : qsTr("Please wait while settings are being uploaded...")
                        wrapMode: Text.WordWrap
                        color: Theme.colorTextSecondary
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Button {
                        id: closeStatusButton
                        text: uploadProgressPopup.uploadComplete ? "Close" : "Cancel"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 35
                        visible: uploadProgressPopup.uploadComplete || !DataManager.isLoading

                        background: Rectangle {
                            color: closeStatusButton.pressed ? Theme.colorButtonPrimaryHover : Theme.colorButtonPrimary
                            radius: Theme.radiusButton
                        }

                        contentItem: Text {
                            text: closeStatusButton.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pointSize: Theme.fontSmall
                        }

                        onClicked: uploadProgressPopup.close()
                    }
                }
            }
        }
    }

    function activateSoftware() {
        if (root.isActivating || root.activationSuccessful)
            return;
        root.isActivating = true;

        SettingsManager.hostHWID = root.tempHostHWID.trim();
        SettingsManager.deviceHWID = root.tempDeviceHWID.trim();
        var licensePassword = root.tempLicensePassword.trim();

        var uploadUrl = DataManager.djangoBaseUrl() + "/api/activate/" + SettingsManager.serialNumber + "/";

        DataManager.installManager().activate(root.currentModel, SettingsManager.hostHWID, SettingsManager.deviceHWID, root.mode, uploadUrl, licensePassword);
    }

    Connections {
        target: DataManager.installManager()

        function onActivationSucceeded() {
            root.isActivating = false;
            root.activationSuccessful = true;
            DataManager.installManager().setIsLicenseActivate(true);
        }

        function onActivationFailed(error) {
            root.isActivating = false;
            root.activationSuccessful = false;
        }
    }
}

pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "../styles"

Popup {
    id: root

    property bool uploadComplete: false
    property bool uploadSuccess: false
    property bool uploadInProgress: false
    property string errorMessage: ""
    property var pendingResult: null

    signal uploadStarted
    signal uploadFinished(bool success, string error)
    signal popupClosed

    modal: true
    focus: true
    width: 400
    height: 280
    anchors.centerIn: Overlay.overlay
    closePolicy: Popup.NoAutoClose

    background: Rectangle {
        color: Theme.colorBgPrimary
        radius: 8
        border.color: Theme.colorBorder
        border.width: 1
    }

    function reset() {
        uploadComplete = false;
        uploadSuccess = false;
        uploadInProgress = false;
        errorMessage = "";
        // pendingResult = null;
        resetTimer.stop();
        retryTimer.stop();
    }

    function startUpload() {
        if (uploadInProgress) {
            console.log("startUpload: upload already in progress — ignoring");
            return;
        }
        reset();
        uploadInProgress = true;
        resetTimer.start();
        uploadStarted();

        if (pendingResult !== null) {
            handleResult(pendingResult.success, pendingResult.error);
            pendingResult = null;
        }
    }

    function handleResult(success, error) {
        uploadInProgress = false;
        uploadComplete = true;
        uploadSuccess = success;
        errorMessage = error || "";

        if (success && errorMessage) {
            console.log("WARNING: Success with error message, treating as failure");
            uploadSuccess = false;
        }

        resetTimer.stop();
        retryTimer.start();

        uploadFinished(uploadSuccess, errorMessage);
    }

    onOpened: {
        startUpload();
    }

    onClosed: {
        popupClosed();
    }

    Timer {
        id: resetTimer
        interval: 10000
        repeat: false
        onTriggered: {
            if (root.uploadInProgress && !root.uploadComplete) {
                console.log("Upload timeout");
                root.handleResult(false, qsTr("Upload timeout. Please check your connection."));
            }
        }
    }

    Timer {
        id: retryTimer
        interval: 3000
        repeat: false
        onTriggered: {
            root.close();
        }
    }

    Connections {
        target: DataManager

        function onErrorOccurred(errorMsg) {
            console.log("ErrorOccurred received:", errorMsg);

            var errorText = typeof errorMsg === 'string' ? errorMsg : (Array.isArray(errorMsg) ? errorMsg.join(', ') : JSON.stringify(errorMsg));

            if (root.uploadInProgress && !root.uploadComplete) {
                root.handleResult(false, errorText);
            } else if (!root.uploadComplete) {
                console.log("Storing error for later:", errorText);
                root.pendingResult = {
                    success: false,
                    error: errorText
                };
            }
        }

        function onSettingsUploadFinished(success) {
            if (root.pendingResult && !root.pendingResult.success) {
                console.log("Ignoring SettingsUploadFinished because error already exists");
                return;
            }

            if (root.uploadInProgress && !root.uploadComplete) {
                if (root.errorMessage) {
                    console.log("Using existing error message instead of success");
                    root.handleResult(false, root.errorMessage);
                } else {
                    root.handleResult(success, success ? "" : qsTr("Failed to upload settings to server."));
                }
            } else if (!root.uploadComplete) {
                root.pendingResult = {
                    success: success,
                    error: success ? "" : qsTr("Failed to upload settings to server.")
                };
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: 20

        Label {
            text: {
                if (!root.uploadComplete) {
                    return qsTr("Uploading Settings");
                } else {
                    return root.uploadSuccess ? qsTr("Upload Successful") : qsTr("Upload Failed");
                }
            }
            font.bold: true
            font.pointSize: Theme.fontSubtitle
            color: {
                if (!root.uploadComplete) {
                    return Theme.colorTextPrimary;
                } else {
                    return root.uploadSuccess ? Theme.colorSuccess : Theme.colorError;
                }
            }
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        ProgressBar {
            id: progressBar
            Layout.fillWidth: true
            Layout.preferredHeight: 8
            visible: !root.uploadComplete
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
            visible: root.uploadComplete

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: root.uploadSuccess ? Theme.colorSuccess : Theme.colorError

                Text {
                    anchors.centerIn: parent
                    text: root.uploadSuccess ? "✓" : "✗"
                    color: "white"
                    font.pointSize: 32
                    font.bold: true
                }
            }
        }

        ColumnLayout {
            spacing: 8
            visible: root.uploadComplete
            Layout.fillWidth: true

            Label {
                text: root.uploadSuccess ? qsTr("Settings have been successfully uploaded to the server.") : qsTr("Failed to upload settings.")
                wrapMode: Text.WordWrap
                color: Theme.colorTextSecondary
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                visible: !root.uploadSuccess && root.errorMessage !== ""
                Layout.fillWidth: true
                Layout.preferredHeight: errorText.implicitHeight + 20
                color: Theme.colorBgPrimary
                radius: 4

                Label {
                    id: errorText
                    text: root.errorMessage
                    wrapMode: Text.WordWrap
                    color: Theme.colorError
                    font.pixelSize: 12
                    anchors.fill: parent
                    anchors.margins: 10
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Label {
            text: qsTr("Please wait while settings are being uploaded...")
            wrapMode: Text.WordWrap
            color: Theme.colorTextSecondary
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            visible: !root.uploadComplete
        }

        Button {
            id: closeStatusButton
            text: root.uploadComplete ? "Close" : "Cancel"
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.topMargin: 10
            enabled: root.uploadComplete || !DataManager.isLoading

            background: Rectangle {
                color: closeStatusButton.enabled ? (closeStatusButton.pressed ? Theme.colorButtonPrimaryHover : Theme.colorButtonPrimary) : Theme.colorButtonDisabled
                radius: Theme.radiusButton
            }

            contentItem: Text {
                text: closeStatusButton.text
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: Theme.fontSmall
                font.bold: true
            }

            onClicked: {
                root.close();
            }
        }
    }
}

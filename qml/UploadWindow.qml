import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import ManualAppCorePlugin 1.0
import "styles"

Item {
    id: root

    property var stackView
    anchors.margins: 20

    Column {
        id: contentColumn
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        BusyIndicator {
            anchors.horizontalCenter: parent.horizontalCenter
            running: uploadProcess.running
            Material.accent: Theme.colorButtonPrimary
        }

        Text {
            id: statusText
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            bottomPadding: 2
            topPadding: 2
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Preparing upload...")
            font.pixelSize: 20
            color: Theme.colorTextPrimary
        }

        ProgressBar {
            id: uploadProgress
            width: parent.width
            topPadding: 2
            from: 0
            to: 4
            value: 0
            Material.accent: Theme.colorButtonPrimary
        }

        Text {
            id: progressText
            topPadding: 2
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Step %1 of 4").arg(uploadProgress.value)
            font.pixelSize: 14
            color: Theme.colorTextPrimary
        }

        Button {
            id: closeButton
            text: qsTr("Close")
            visible: false
            enabled: false
            onClicked: {
                root.stackView.clear();
                root.stackView.push("Dashboard.qml", StackView.Immediate);
            }
            anchors.horizontalCenter: parent.horizontalCenter
            topPadding: 10
        }
    }

    SequentialAnimation {
        id: uploadProcess
        running: false
        property bool hasError: false

        ScriptAction {
            script: {
                statusText.text = qsTr("Saving data locally...");
                DataManager.save(false);
                uploadProgress.value = 1;
            }
        }
        PauseAnimation {
            duration: 1000
        }

        ScriptAction {
            script: {
                if (!uploadProcess.hasError) {
                    statusText.text = qsTr("Uploading settings to server...");
                    DataManager.uploadSettingsToDjango(DataManager.djangoBaseUrl() + "/api/kalmar32/");
                    uploadProgress.value = 2;
                }
            }
        }
        PauseAnimation {
            duration: 1000
        }

        ScriptAction {
            script: {
                if (!uploadProcess.hasError) {
                    statusText.text = qsTr("Uploading report to server...");
                    DataManager.uploadReportToDjango(DataManager.djangoBaseUrl() + "/api/report/");
                    uploadProgress.value = 3;
                }
            }
        }
        PauseAnimation {
            duration: 1000
        }

        ScriptAction {
            script: {
                if (!uploadProcess.hasError) {
                    statusText.text = qsTr("Finalizing upload...");
                    DataManager.setStartTime(null);
                    DataManager.setCurrentNumberTO(null);
                    uploadProgress.value = 4;
                }
            }
        }
        PauseAnimation {
            duration: 1000
        }

        ScriptAction {
            script: {
                if (!uploadProcess.hasError) {
                    statusText.text = qsTr("Upload completed successfully!");
                    progressText.text = qsTr("All steps completed");
                    closeButton.visible = true;
                    closeButton.enabled = true;
                }
            }
        }
    }

    Connections {
        target: DataManager
        function onErrorOccurred(errorMessage) {
            statusText.text = qsTr("Error: %1").arg(errorMessage);
            uploadProcess.hasError = true;
            uploadProcess.stop();
            closeButton.visible = true;
            closeButton.enabled = true;
        }
    }

    Component.onCompleted: uploadProcess.start()
}

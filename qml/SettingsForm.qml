pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "styles"
import "models"
import "components"

ScrollView {
    id: root

    clip: true

    signal settingsCompleted

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
                Layout.fillWidth: true
                spacing: 15

                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: 20
                    color: Theme.colorButtonPrimary

                    Text {
                        text: SettingsManager.getCurrentSettings().modelTitle[0]
                        color: "white"
                        font.pointSize: 16
                        font.bold: true
                        anchors.centerIn: parent
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true

                    Text {
                        text: qsTr(SettingsManager.getCurrentSettings().modelTitle + " Configuration")
                        color: Theme.colorTextPrimary
                        font.pointSize: 24
                        font.bold: true
                    }

                    Text {
                        text: qsTr("Current model: %1").arg(SettingsManager.currentModel)
                        color: Theme.colorTextSecondary
                        font.pointSize: Theme.fontSmall
                    }
                }
            }

            DynamicFormRenderer {
                id: mainRenderer
                property var currentModel: SettingsManager.currentModel

                config: SettingsManager.getModelSettings(currentModel).getSectionsMetadata()
                modelSettings: SettingsManager.getSettings(currentModel)
                isInitialMode: true
            }

            Button {
                id: button
                text: qsTr("Save")
                font.pixelSize: 18
                onClicked: confirmPopup.open()
                Layout.preferredWidth: 240
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignHCenter

                background: Rectangle {
                    color: button.enabled ? (button.pressed ? Theme.colorButtonPrimaryHover : Theme.colorButtonPrimary) : Theme.colorButtonDisabled
                    radius: 4
                }

                contentItem: Text {
                    text: button.text
                    font.pixelSize: 18
                    color: "white"
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.minimumHeight: 400
            }
        }

        ConfirmSavePopup {
            id: confirmPopup

            onConfirmed: {
                uploadPopup.open();
                SettingsManager.saveModelSettings();

                var uploadUrl = DataManager.djangoBaseUrl() + "/api/" + SettingsManager.currentModel + "/";
                DataManager.uploadSettingsToDjango(uploadUrl);
            }

            onCancelled: {
                console.log("Save cancelled by user");
            }
        }

        SettingsUploadPopup {
            id: uploadPopup

            onUploadFinished: function (success, error) {
                if (error != "") {
                    console.log("Upload finished with result:", success, " Error:", error);
                }
            }

            onPopupClosed: {
                if (uploadPopup.uploadSuccess) {
                    SettingsManager.completeFirstRun();
                    root.settingsCompleted();
                } else {
                    console.log("Upload failed or was cancelled, staying on settings page");
                }
            }
        }
    }
}

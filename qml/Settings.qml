pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "components"
import "models"
import "styles"

ScrollView {
    id: root

    clip: true
    anchors.fill: parent

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

            // Заголовок
            RowLayout {
                Layout.leftMargin: 50
                Image {
                    source: "qrc:///media/icons/icon-settings.svg"
                    sourceSize.width: 40
                    sourceSize.height: 40
                }

                Text {
                    text: qsTr("Settings")
                    color: Theme.colorTextPrimary
                    font.pointSize: 24
                }
            }

            DynamicFormRenderer {
                id: mainRenderer
                property var currentModel: SettingsManager.currentModel

                config: SettingsManager.getModelSettings(currentModel).getSectionsMetadata()
                modelSettings: SettingsManager.getSettings(currentModel);
                isInitialMode: false
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
                var uploadUrl = DataManager.djangoBaseUrl() +  "/api/" + SettingsManager.currentModel + "/";
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
        }
    }
}

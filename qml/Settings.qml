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

    property bool initialMode: false

    signal settingsCompleted
    signal backToModelSelection
    signal reloadRequested

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

                RowLayout {
                    id: initialHeader

                    Layout.fillWidth: true
                    Layout.leftMargin: 50
                    spacing: 15
                    Image {
                        source: "qrc:///media/icons/icon-settings.svg"
                        sourceSize.width: 40
                        sourceSize.height: 40
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
                            text: {
                                var versionText = SettingsManager.currentVersion || "";
                                var railText = SettingsManager.railType || "";
                                if (railText !== "") {
                                    return qsTr("Current version: %1 (%2)").arg(versionText).arg(railText.toUpperCase());
                                } else {
                                    return qsTr("Current version: %1").arg(versionText);
                                }
                            }
                            color: Theme.colorTextSecondary
                            font.pointSize: Theme.fontSmall
                        }
                    }

                    ColumnLayout {
                        visible: SettingsManager.currentModel === "phasarsl"
                        spacing: 10
                        Layout.fillWidth: true

                        Button {
                            text: "Migrate settings from PHASAR-01"
                            Layout.fillWidth: true
                            onClicked: {
                                if (SettingsManager.migrateFromPhasar01ToPhasarSL()) {
                                    console.log("Migration successful");
                                    SettingsManager.loadCurrentModelScheme();
                                    root.reloadRequested();
                                } else {
                                    console.log("Migration failed or no data");
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                visible: root.initialMode
                Layout.fillWidth: true
                spacing: 15

                Label {
                    text: "Schema:"
                    color: Theme.colorTextPrimary
                    font.pointSize: Theme.fontBody
                }

                SchemaComboBox {
                    id: schemaCombo
                    Layout.fillWidth: true

                    schemaModel: SettingsManager.getAvailableSchemaFiles(SettingsManager.currentModel)
                    currentModel: SettingsManager.currentModel
                    currentSchemaFile: SettingsManager.currentSchemaFile

                    onSchemaSelected: function (filePath) {
                        SettingsManager.loadSchemaFile(SettingsManager.currentModel, filePath);

                        if (mainRenderer) {
                            mainRenderer.config = SettingsManager.getModelSettings(SettingsManager.currentModel).getSectionsMetadata();
                            mainRenderer.modelSettings = SettingsManager.getSettings(SettingsManager.currentModel);
                        }
                    }
                }
            }

            DynamicFormRenderer {
                id: mainRenderer
                property var currentModel: SettingsManager.currentModel

                config: SettingsManager.getModelSettings(currentModel).getSectionsMetadata()
                modelSettings: SettingsManager.getSettings(currentModel)
                isInitialMode: root.initialMode
            }
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 5
                spacing: 20

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    id: backButton
                    text: qsTr("← Back to models")
                    font.pixelSize: 18
                    onClicked: root.backToModelSelection()
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 40
                    visible: root.initialMode
                    background: Rectangle {
                        color: backButton.down ? Theme.colorButtonSecondaryHover : "transparent"
                        border.color: Theme.colorButtonSecondary
                        border.width: 1
                        radius: 4
                    }

                    contentItem: Text {
                        text: backButton.text
                        font.pixelSize: 18
                        color: Theme.colorTextPrimary
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    id: button
                    text: qsTr("Save")
                    font.pixelSize: 18
                    onClicked: confirmPopup.open()
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 40

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
                    Layout.fillWidth: true
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
                if (root.initialMode) {
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

    Connections {
        target: SettingsManager
        function onCurrentModelChanged() {
            schemaCombo.schemaModel = SettingsManager.getAvailableSchemaFiles(SettingsManager.currentModel);
            schemaCombo.currentModel = SettingsManager.currentModel;
            schemaCombo.currentSchemaFile = SettingsManager.currentSchemaFile;
            if (mainRenderer) {
                mainRenderer.config = SettingsManager.getModelSettings(SettingsManager.currentModel).getSectionsMetadata();
                mainRenderer.modelSettings = SettingsManager.getSettings(SettingsManager.currentModel);
            }
        }
    }

    Component.onCompleted: {
        if (!SettingsManager.currentSchemaFile) {
            var files = SettingsManager.getAvailableSchemaFiles(SettingsManager.currentModel);
            if (files.length > 0) {
                SettingsManager.loadSchemaFile(SettingsManager.currentModel, files[0]);
            }
        }
        if (mainRenderer) {
            mainRenderer.config = SettingsManager.getModelSettings(SettingsManager.currentModel).getSectionsMetadata();
            mainRenderer.modelSettings = SettingsManager.getSettings(SettingsManager.currentModel);
        }
    }
}

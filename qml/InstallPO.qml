pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "styles"

Item {
    id: root

    // ====== State ===========================================================
    property string currentModel: SettingsManager.currentModel

    // ====== UI ==============================================================
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Header
        RowLayout {
            spacing: 12
            Layout.leftMargin: 50

            Text {
                text: "Software Installation"
                color: Theme.colorTextPrimary
                font.pointSize: 24
                font.bold: true
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
                    text: InstallManager.installerExists(root.currentModel) ? "Ready" : "Installer not found"
                    color: InstallManager.installerExists(root.currentModel) ? Theme.colorSuccess : Theme.colorError
                    font.pointSize: Theme.fontBody
                }
            }
        }

        // Installation Section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 15

            Text {
                text: "Install Software"
                color: Theme.colorTextPrimary
                font.pointSize: Theme.fontSubtitle
                font.bold: true
            }

            // Status Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: Theme.colorBgMuted
                radius: Theme.radiusCard
                border.color: Theme.colorBorder

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 5

                    Text {
                        text: InstallManager.statusMessage
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontBody
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "Installer: " + (root.currentModel === "kalmar32" ? "kalmar.exe" : "phasar.exe")
                        color: Theme.colorTextMuted
                        font.pointSize: Theme.fontSmall
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "Path: " + InstallManager.installerPath
                        color: Theme.colorTextMuted
                        font.pointSize: Theme.fontSmall
                        Layout.fillWidth: true
                    }
                }
            }

            // Install Button
            Button {
                id: install_button
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 200
                Layout.preferredHeight: 50
                text: InstallManager.isInstalling ? "Installing..." : "Run Installer"
                enabled: !InstallManager.isInstalling && InstallManager.installerExists(root.currentModel)

                background: Rectangle {
                    color: parent.enabled ? Theme.colorButtonPrimary : Theme.colorButtonDisabled
                    radius: Theme.radiusButton

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }

                contentItem: Text {
                    text: install_button.text
                    color: Theme.colorTextPrimary
                    font.pointSize: Theme.fontBody
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    InstallManager.runInstaller(root.currentModel);
                }
            }
        }

        // Simple Instructions
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
                Layout.preferredHeight: 140
                color: Theme.colorBgMuted
                radius: Theme.radiusCard
                border.color: Theme.colorBorder

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 8

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
                        text: "• Wait for the installation to complete"
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSmall
                    }

                    Text {
                        text: "• Restart this application after installation"
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSmall
                    }

                    Text {
                        text: "• If installer doesn't start, run it manually from /media/apps/"
                        color: Theme.colorWarning
                        font.pointSize: Theme.fontSmall
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }

    Connections {
        target: InstallManager
        function onInstallationStarted() {
            console.log("Installation started successfully");
        }
        
        function onInstallationFinished(success) {
            console.log("Installation finished, success:", success);
        }
        
        function onErrorOccurred(error) {
            console.error("Installation error:", error);
        }
    }
}
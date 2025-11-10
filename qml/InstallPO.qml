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
    property bool isDownloading: InstallManager.isDownloading
    property bool isInstallerReady: InstallManager.installerExists
    
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
                    text: {
                        if (root.isDownloading) "Downloading..."
                        else if (root.isInstallerReady) "Ready"
                        else "Not downloaded"
                    }
                    color: {
                        if (root.isDownloading) Theme.colorWarning
                        else if (root.isInstallerReady) Theme.colorSuccess
                        else Theme.colorError
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
                        text: InstallManager.statusMessage
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontBody
                        Layout.fillWidth: true
                    }

                    ProgressBar {
                        id: downloadProgress
                        Layout.fillWidth: true
                        visible: root.isDownloading
                        value: InstallManager.downloadProgress
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
                        text: "Path: " + InstallManager.installerPath
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
                        if (root.isDownloading) "Downloading..."
                        else if (root.isInstallerReady) "Redownload"
                        else "Download Installer"
                    }
                    enabled: !root.isDownloading && !InstallManager.isInstalling

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
                        InstallManager.downloadInstaller(root.currentModel);
                    }
                }

                Button {
                    id: installButton
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 50
                    text: InstallManager.isInstalling ? "Installing..." : "Run Installer"
                    enabled: !InstallManager.isInstalling && !root.isDownloading && root.isInstallerReady

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
                        InstallManager.runInstaller(root.currentModel);
                    }
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
                Layout.preferredHeight: 190
                color: Theme.colorBgMuted
                radius: Theme.radiusCard
                border.color: Theme.colorBorder

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 8

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
    }
}
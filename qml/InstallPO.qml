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
    property string downloadUrl: currentModel === "kalmar32" ?
        "https://www.dropbox.com/scl/fo/v1lkl7tcgj0hhreob6lf6/AINWP749-a0tC_y7wa2K4s8?rlkey=qr2z0ylejuoiku8ido0ac61mq&e=1&st=knaxnyu6&dl=0" :
        "https://www.dropbox.com/scl/fo/v1lkl7tcgj0hhreob6lf6/AINWP749-a0tC_y7wa2K4s8?rlkey=qr2z0ylejuoiku8ido0ac61mq&e=1&st=knaxnyu6&dl=0"

    property string statusMessage: "Ready to download"
    property bool isDownloading: false

    // ====== Functions =======================================================
    function downloadAndInstall() {
        if (isDownloading) return;

        isDownloading = true;
        statusMessage = "Opening download link in browser...";

        // Просто открываем ссылку в браузере - пользователь скачает и запустит вручную
        Qt.openUrlExternally(downloadUrl);

        // Имитируем процесс установки
        timer.start();
    }

    Timer {
        id: timer
        interval: 3000
        onTriggered: {
            root.isDownloading = false;
            root.statusMessage = "Download completed! Please run the installer manually.";
        }
    }

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

                Item { Layout.fillWidth: true }

                Text {
                    text: "Ready"
                    color: Theme.colorSuccess
                    font.pointSize: Theme.fontBody
                }
            }
        }

        // Download Section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 15

            Text {
                text: "Download Software"
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
                        text: root.statusMessage
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontBody
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "File: " + (root.currentModel === "kalmar32" ? "kalmar_software_setup.exe" : "Phazar-Installer-version.exe")
                        color: Theme.colorTextMuted
                        font.pointSize: Theme.fontSmall
                        Layout.fillWidth: true
                    }
                }
            }

            // Download Button
            Button {
                id: download_button
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 200
                Layout.preferredHeight: 50
                text: root.isDownloading ? "Downloading..." : "Download Software"
                enabled: !root.isDownloading

                background: Rectangle {
                    color: parent.enabled ? Theme.colorButtonPrimary : Theme.colorButtonDisabled
                    radius: Theme.radiusButton

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }

                contentItem: Text {
                    text: download_button.text
                    color: Theme.colorTextPrimary
                    font.pointSize: Theme.fontBody
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    root.downloadAndInstall();
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
                        text: "• Click 'Download Software' to get the installer"
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSmall
                    }

                    Text {
                        text: "• Run the downloaded .exe file"
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSmall
                    }

                    Text {
                        text: "• Follow the installation steps"
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSmall
                    }

                    Text {
                        text: "• Restart this application after installation"
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSmall
                    }

                    Text {
                        text: ""
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSmall
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}

pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "../styles"

ColumnLayout {
    id: root

    Layout.fillWidth: true
    spacing: 15

    property string sectionTitle: ""
    property string updateStatus: ""        // "new_version_available" | "up_to_date" | "not_downloaded"
    property bool isDownloading: false
    property bool isInstallerReady: false
    property double downloadProgress: 0
    property string statusMessage: ""
    property color idleStatusColor: Theme.colorError

    property date latestServerDate: new Date(0)
    property date lastVersionDate: new Date(0)
    property string versionRowLabel: "Downloaded version:"

    property string infoLine1: ""
    property string infoLine2: ""
    property int cardHeight: 200

    property string downloadButtonText: "Download"
    property string installButtonText: "Run Installer"
    property bool downloadEnabled: true
    property bool installEnabled: true

    property Component extraContent: null

    signal downloadRequested
    signal installRequested

    RowLayout {
        Layout.fillWidth: true

        Text {
            text: root.sectionTitle
            color: Theme.colorTextPrimary
            font.pointSize: Theme.fontSubtitle
            font.bold: true
        }

        Item {
            Layout.fillWidth: true
        }

        Rectangle {
            visible: root.updateStatus === "new_version_available"
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
            visible: root.updateStatus === "up_to_date"
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

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: root.cardHeight
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

            Text {
                text: root.statusMessage
                Layout.fillWidth: true
                color: {
                    if (root.isDownloading)
                        return Theme.colorUpdate;
                    if (root.updateStatus === "new_version_available")
                        return Theme.colorUpdate;
                    if (root.isInstallerReady)
                        return Theme.colorSuccess;
                    return root.idleStatusColor;
                }
                font.pointSize: Theme.fontBody
                font.bold: root.updateStatus === "new_version_available"
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
                    text: root.latestServerDate > new Date(0) ? Qt.formatDate(root.latestServerDate, "yyyy-MM-dd") : "Not available"
                    color: Theme.colorTextPrimary
                    font.pointSize: Theme.fontSmall
                    font.bold: root.lastVersionDate < root.latestServerDate
                }

                Text {
                    text: root.versionRowLabel
                    color: Theme.colorTextMuted
                    font.pointSize: Theme.fontSmall
                }

                Text {
                    text: root.lastVersionDate > new Date(0) ? Qt.formatDate(root.lastVersionDate, "yyyy-MM-dd") : "Never"
                    color: root.lastVersionDate < root.latestServerDate ? Theme.colorUpdate : Theme.colorTextPrimary
                    font.pointSize: Theme.fontSmall
                    font.bold: root.lastVersionDate < root.latestServerDate
                }
            }

            ProgressBar {
                Layout.fillWidth: true
                visible: root.isDownloading
                value: root.downloadProgress
                from: 0
                to: 100
            }

            Loader {
                Layout.fillWidth: true
                sourceComponent: root.extraContent
            }

            Text {
                visible: root.infoLine1 !== ""
                text: root.infoLine1
                color: Theme.colorTextMuted
                font.pointSize: Theme.fontSmall
                Layout.fillWidth: true
            }

            Text {
                visible: root.infoLine2 !== ""
                text: root.infoLine2
                color: Theme.colorTextMuted
                font.pointSize: Theme.fontSmall
                Layout.fillWidth: true
            }
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: -36
        spacing: 12
        z: 2

        Button {
            id: downloadBtn
            Layout.preferredWidth: 170
            Layout.preferredHeight: 42
            text: root.downloadButtonText
            enabled: root.downloadEnabled

            background: Rectangle {
                color: {
                    if (!downloadBtn.enabled)
                        return Theme.colorButtonDisabled;
                    if (root.updateStatus === "new_version_available")
                        return Theme.colorUpdate;
                    return Theme.colorButtonSecondary;
                }
                radius: Theme.radiusButton
            }

            contentItem: Text {
                text: downloadBtn.text
                color: "white"
                font.pointSize: Theme.fontBody
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: root.downloadRequested()
        }

        Button {
            id: installBtn
            Layout.preferredWidth: 170
            Layout.preferredHeight: 42
            text: root.installButtonText
            enabled: root.installEnabled

            background: Rectangle {
                color: installBtn.enabled ? (root.updateStatus === "new_version_available" ? Theme.colorUpdate : Theme.colorButtonPrimary) : Theme.colorButtonDisabled
                radius: Theme.radiusButton
            }

            contentItem: Text {
                text: installBtn.text
                color: "white"
                font.pointSize: Theme.fontBody
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: root.installRequested()
        }
    }
}

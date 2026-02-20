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
    property bool isActivating: false
    property bool activationSuccessful: SettingsManager.isLicenseActivate && SettingsManager.deviceHWID != ""
    property string mode: "control"
    property string tempHostHWID: SettingsManager.hostHWID
    property string tempDeviceHWID: SettingsManager.deviceHWID
    property string tempLicensePassword: ""

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
                    source: "qrc:///media/icons/icon-activate.svg"
                    sourceSize.width: 40
                    sourceSize.height: 40
                }

                Text {
                    text: qsTr("Software Activation")
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
                        text: root.currentModel === "kalmar32" ? "KALMAR-32" : "PHASAR-32"
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSubtitle
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // Activation Status
                    Rectangle {
                        width: root.activationSuccessful ? 110 : 130
                        height: 30
                        radius: 15
                        color: root.activationSuccessful ? Theme.colorSuccess : Theme.colorError

                        Text {
                            anchors.centerIn: parent
                            text: root.activationSuccessful ? "Activated" : "Not Activated"
                            color: "white"
                            font.pointSize: Theme.fontSmall
                            font.bold: true
                        }
                    }
                }
            }

            // === СЕКЦИЯ АКТИВАЦИИ ================================================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15

                Text {
                    text: "Activation Details"
                    color: Theme.colorTextPrimary
                    font.pointSize: Theme.fontSubtitle
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.currentModel === "kalmar32" ? 295 : 400
                    color: Theme.colorBgMuted
                    radius: Theme.radiusCard
                    border.color: Theme.colorBorder

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        anchors.topMargin: root.currentModel === "kalmar32" ? 5 : 20
                        spacing: 20

                        // Software Mode
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            visible: root.currentModel == "phasar32"

                            Text {
                                text: "Software Mode"
                                color: Theme.colorTextPrimary
                                font.pointSize: Theme.fontBody
                                font.bold: true
                            }

                            RowLayout {
                                spacing: 10
                                Layout.alignment: Qt.AlignLeft

                                Rectangle {
                                    id: controlModeBtn
                                    width: 100
                                    height: 35
                                    radius: 4
                                    color: root.mode === "control" ? Theme.colorButtonPrimary : Theme.colorBgPrimary
                                    border.color: root.mode === "control" ? Theme.colorButtonPrimary : Theme.colorBorder

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Control"
                                        color: root.mode === "control" ? "white" : Theme.colorTextPrimary
                                        font.pointSize: Theme.fontBody
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: !root.activationSuccessful
                                        onClicked: root.mode = "control"
                                    }
                                }

                                Rectangle {
                                    id: analysisModeBtn
                                    width: 100
                                    height: 35
                                    radius: 4
                                    color: root.mode === "analysis" ? Theme.colorButtonPrimary : Theme.colorBgPrimary
                                    border.color: root.mode === "analysis" ? Theme.colorButtonPrimary : Theme.colorBorder

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Analysis"
                                        color: root.mode === "analysis" ? "white" : Theme.colorTextPrimary
                                        font.pointSize: Theme.fontBody
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: !root.activationSuccessful
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
                                spacing: 8
                                visible: root.currentModel === "phasar32"

                                Text {
                                    text: "Host HWID *"
                                    color: Theme.colorTextPrimary
                                    font.pointSize: Theme.fontBody
                                    font.bold: true
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 45
                                    color: Theme.colorBgPrimary
                                    radius: 6
                                    border.color: Theme.colorBorder
                                    border.width: 1

                                    TextInput {
                                        id: hostHwidInputField
                                        anchors.fill: parent
                                        anchors.margins: 12
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
                                            anchors.leftMargin: 12
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
                                spacing: 8

                                Text {
                                    text: "Device HWID *"
                                    color: Theme.colorTextPrimary
                                    font.pointSize: Theme.fontBody
                                    font.bold: true
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 45
                                    color: Theme.colorBgPrimary
                                    radius: 6
                                    border.color: Theme.colorBorder
                                    border.width: 1

                                    TextInput {
                                        id: deviceHwidInputField
                                        anchors.fill: parent
                                        anchors.margins: 12
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
                                            anchors.leftMargin: 12
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
                            spacing: 8

                            Text {
                                text: "License Password *"
                                color: Theme.colorTextPrimary
                                font.pointSize: Theme.fontBody
                                font.bold: true
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 45
                                color: Theme.colorBgPrimary
                                radius: 6
                                border.color: Theme.colorBorder
                                border.width: 1

                                TextInput {
                                    id: licensePasswordInputField
                                    anchors.fill: parent
                                    anchors.margins: 12
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
                                        anchors.leftMargin: 12
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
                                    "Note: Device HWID is required for KALMAR-32 activation. You can find HWID in the installed software.";
                                } else {
                                    "Note: Both Host HWID and Device HWID are required for PHASAR-32 activation. You can find these in the installed software.";
                                }
                            }
                            color: Theme.colorTextMuted
                            font.pointSize: 10
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }

                        Button {
                            id: activateButton
                            Layout.preferredWidth: 220
                            Layout.preferredHeight: 45
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: 10

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
                                color: "white"
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

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.colorBorder
                opacity: 0.3
                Layout.topMargin: 10
                Layout.bottomMargin: 10
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "How to get HWID:"
                    color: Theme.colorTextPrimary
                    font.pointSize: Theme.fontSubtitle
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 210
                    color: Theme.colorBgMuted
                    radius: Theme.radiusCard
                    border.color: Theme.colorBorder

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 5

                        Text {
                            text: "Steps to get Hardware ID:"
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                            font.bold: true
                        }

                        Text {
                            text: "1. Install the software first (go to 'Install' section)"
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        Text {
                            text: "2. Launch the installed software"
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        Text {
                            text: "3. Find and copy the Hardware ID(s) from the software"
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        Text {
                            text: "4. Paste them in the fields above and enter license password"
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        Text {
                            text: "5. Click 'Activate Software' to complete activation"
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
            SettingsManager.licenseActivationSucceeded();
        }

        function onActivationFailed(error) {
            root.isActivating = false;
            root.activationSuccessful = false;

            console.log("Activation failed:", error);
        }
    }
}

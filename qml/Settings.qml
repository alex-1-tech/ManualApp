pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "components"
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
            CardSection {
                title: qsTr("Registration data")
                FormField {
                    label: qsTr("Invoice")
                    placeholder: qsTr("Invoice number")
                    settingName: "invoice"
                    Layout.fillWidth: true
                }
                FormField {
                    label: qsTr("Packet list")
                    placeholder: qsTr("Document number")
                    settingName: "packetList"
                    Layout.fillWidth: true
                }
            }

            // ПОЛЯ ДЛЯ KALMAR-32
            ColumnLayout {
                visible: SettingsManager.isKalmar32()
                spacing: 20
                Layout.fillWidth: true

                CardSection {
                    title: qsTr("PC Tablet Components")

                    FormField {
                        label: qsTr("PC tablet Latitude Dell 7230")
                        placeholder: qsTr("serial number")
                        settingName: "pcTabletDell7230"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("AC/DC Power adapter for Dell 7230")
                        placeholder: qsTr("serial number")
                        settingName: "acDcPowerAdapterDell"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("DC Charger adapter for Dell 7230 from battery")
                        placeholder: qsTr("serial number")
                        settingName: "dcChargerAdapterBattery"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }
                }

                CardSection {
                    title: qsTr("Ultrasonic Equipment")

                    FormField {
                        label: qsTr("Ultrasonic phased array PULSAR OEM 16/64 established")
                        placeholder: qsTr("Serial number")
                        settingName: "ultrasonicPhasedArrayPulsar"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Left probs PA2.25L16 1.1x10-17")
                        placeholder: qsTr("0000 MM.YEAR")
                        settingName: "leftProbs"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Right probs PA2.25L16 1.1x10-17")
                        placeholder: qsTr("0000 MM.YEAR")
                        settingName: "rightProbs"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Manual probs PA2.25L16 0.9x10-17")
                        placeholder: qsTr("0000 MM.YEAR")
                        settingName: "manualProbs"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Straight probs RA5.0L16 0.6x10-12")
                        placeholder: qsTr("0000 MM.YEAR")
                        settingName: "straightProbs"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Label {
                            Layout.preferredWidth: root.width < 700 ? 280 : 450
                            text: qsTr("DC Cable from Battery")
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        ModelSettingCheckBox {
                            settingName: "hasDcCableBattery"
                            modelSettings: SettingsManager.kalmarSettings
                            text: qsTr("Included")
                            Layout.columnSpan: 1
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Label {
                            Layout.preferredWidth: root.width < 700 ? 280 : 450
                            text: qsTr("Ethernet Cables")
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        ModelSettingCheckBox {
                            settingName: "hasEthernetCables"
                            modelSettings: SettingsManager.kalmarSettings
                            text: qsTr("Included")
                            Layout.columnSpan: 1
                        }
                    }
                }

                CardSection {
                    title: qsTr("Battery and Charging")

                    FormField {
                        label: qsTr("DC Battery box established")
                        placeholder: qsTr("Serial number")
                        settingName: "dcBatteryBox"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Label {
                            Layout.preferredWidth: root.width < 700 ? 280 : 450
                            text: qsTr("AC/DC Charger adapter for battery")
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        ModelSettingCheckBox {
                            settingName: "hasAcDcChargerAdapterBattery"
                            modelSettings: SettingsManager.kalmarSettings
                            text: qsTr("Included")
                            Layout.columnSpan: 1
                        }
                    }
                }

                CardSection {
                    title: qsTr("Calibration and Tools")

                    FormField {
                        label: qsTr("Calibration bloc SO-3R")
                        placeholder: qsTr("Serial number")
                        settingName: "calibrationBlockSo3r"
                        modelSettings: SettingsManager.kalmarSettings
                        Layout.fillWidth: true
                    }
                }

                // Network settings
                CardSection {
                    title: qsTr("Network settings")

                    FormField {
                        label: qsTr("Wifi router address")
                        placeholder: qsTr("IP or hostname of the router")
                        settingName: "wifiRouterAddress"
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Windows password")
                        placeholder: qsTr("Enter Windows user password")
                        settingName: "windowsPassword"
                        Layout.fillWidth: true
                    }
                }
            }

            // ПОЛЯ ДЛЯ PHASAR-32
            ColumnLayout {
                visible: SettingsManager.isPhasar32()
                spacing: 20
                Layout.fillWidth: true

                CardSection {
                    title: qsTr("PC Tablet Components")

                    FormField {
                        label: qsTr("PC tablet Latitude Dell 7230")
                        placeholder: qsTr("Serial number")
                        settingName: "pcTabletDell7230"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("AC/DC Power adapter for Dell 7230")
                        placeholder: qsTr("Serial number")
                        settingName: "acDcPowerAdapterDell"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("DC Charger adapter for Dell 7230 from battery")
                        placeholder: qsTr("Serial number")
                        settingName: "dcChargerAdapterBattery"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }
                }

                CardSection {
                    title: qsTr("Ultrasonic Equipment")

                    FormField {
                        label: qsTr("Ultrasonic phased array PULSAR OEM 16/128 established")
                        placeholder: qsTr("Serial number")
                        settingName: "ultrasonicPhasedArrayPulsar"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("DCN P112-2,5-F")
                        placeholder: qsTr("0000 MM.YEAR")
                        settingName: "dcn"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("AB-back PA2,5L16 1,1x10-17-F")
                        placeholder: qsTr("0000 MM.YEAR")
                        settingName: "abBack"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("GF combo 2PA2,5L16 0,6x10-10-F")
                        placeholder: qsTr("0000 MM.YEAR")
                        settingName: "gfCombo"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("FF combo 2PA2,5L16 0,6x10-10-F")
                        placeholder: qsTr("0000 MM.YEAR")
                        settingName: "ffCombo"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("AB-front PA2,5L16 1,1x10-17-F")
                        placeholder: qsTr("0000 MM.YEAR")
                        settingName: "abFront"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Flange 50 P112-0,6-50-F")
                        placeholder: qsTr("0000 MM.YEAR")
                        settingName: "flange50"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Manual probs PA2.25L16 0.9x10-17")
                        placeholder: qsTr("0000 MM.YEAR")
                        settingName: "manualProbs"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Label {
                            Layout.preferredWidth: root.width < 700 ? 280 : 450
                            text: qsTr("DC Cable from Battery")
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        ModelSettingCheckBox {
                            settingName: "hasDcCableBattery"
                            modelSettings: SettingsManager.phasarSettings
                            text: qsTr("Included")
                            Layout.columnSpan: 1
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Label {
                            Layout.preferredWidth: root.width < 700 ? 280 : 450
                            text: qsTr("Ethernet Cables")
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        ModelSettingCheckBox {
                            settingName: "hasEthernetCables"
                            modelSettings: SettingsManager.phasarSettings
                            text: qsTr("Included")
                            Layout.columnSpan: 1
                        }
                    }
                }

                CardSection {
                    title: qsTr("Additional Equipment")

                    FormField {
                        label: qsTr("Water tank with a tap")
                        placeholder: qsTr("Water tank details")
                        settingName: "waterTankWithTap"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("DC Battery box established")
                        placeholder: qsTr("Serial number")
                        settingName: "dcBatteryBox"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Label {
                            Layout.preferredWidth: root.width < 700 ? 280 : 450
                            text: qsTr("AC/DC Charger adapter for battery")
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        ModelSettingCheckBox {
                            settingName: "hasAcDcChargerAdapterBattery"
                            modelSettings: SettingsManager.phasarSettings
                            text: qsTr("Included")
                            Layout.columnSpan: 1
                        }
                    }
                }

                CardSection {
                    title: qsTr("Calibration and Tools")

                    FormField {
                        label: qsTr("Calibration bloc SO-3R")
                        placeholder: qsTr("Serial number")
                        settingName: "calibrationBlockSo3r"
                        modelSettings: SettingsManager.phasarSettings
                        Layout.fillWidth: true
                    }
                }

                // Network settings
                CardSection {
                    title: qsTr("Network settings")

                    FormField {
                        label: qsTr("Wifi router address")
                        placeholder: qsTr("IP or hostname of the router")
                        settingName: "wifiRouterAddress"
                        Layout.fillWidth: true
                    }

                    FormField {
                        label: qsTr("Windows password")
                        placeholder: qsTr("Enter Windows user password")
                        settingName: "windowsPassword"
                        Layout.fillWidth: true
                    }
                }
            }

            Button {
                id: button
                text: qsTr("Save")
                font.pixelSize: 18
                onClicked: confirmDialog.open()
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

        // Диалог подтверждения сохранения
        Popup {
            id: confirmDialog
            modal: true
            focus: true
            width: 400
            height: 180
            anchors.centerIn: Overlay.overlay
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            background: Rectangle {
                color: Theme.colorBgPrimary
                radius: 8
                border.color: Theme.colorBorder
                border.width: 1
            }

            contentItem: ColumnLayout {
                spacing: 20

                Label {
                    text: qsTr("Save confirmation")
                    font.bold: true
                    font.pointSize: Theme.fontSubtitle
                    color: Theme.colorTextPrimary
                    Layout.fillWidth: true
                }

                Label {
                    text: qsTr("Are you sure you want to save the settings?\nAfter saving, some of them cannot be changed.")
                    wrapMode: Text.WordWrap
                    color: Theme.colorTextSecondary
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Button {
                        id: cancelButton
                        text: "Cancel"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 35

                        background: Rectangle {
                            color: cancelButton.pressed ? Theme.colorButtonSecondaryHover : Theme.colorButtonSecondary
                            radius: Theme.radiusButton
                        }

                        contentItem: Text {
                            text: cancelButton.text
                            color: Theme.colorTextPrimary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pointSize: Theme.fontSmall
                        }

                        onClicked: confirmDialog.close()
                    }

                    Button {
                        id: okButton
                        text: "OK"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 35

                        background: Rectangle {
                            color: okButton.pressed ? Theme.colorButtonPrimaryHover : Theme.colorButtonPrimary
                            radius: Theme.radiusButton
                        }

                        contentItem: Text {
                            text: okButton.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pointSize: Theme.fontSmall
                        }

                        onClicked: {
                            confirmDialog.close();

                            uploadProgressPopup.open();
                            uploadProgressPopup.uploadInProgress = true;

                            SettingsManager.saveModelSettings();

                            var uploadUrl = "";
                            if (SettingsManager.currentModel == "kalmar32") {
                                uploadUrl = DataManager.djangoBaseUrl() + "/api/kalmar32/";
                            } else {
                                uploadUrl = DataManager.djangoBaseUrl() + "/api/phasar32/";
                            }

                            DataManager.uploadSettingsToDjango(uploadUrl);
                        }
                    }
                }
            }
        }

        Popup {
            id: uploadProgressPopup
            modal: true
            focus: true
            width: 400
            height: 220
            anchors.centerIn: Overlay.overlay
            closePolicy: Popup.NoAutoClose

            background: Rectangle {
                color: Theme.colorBgPrimary
                radius: 8
                border.color: Theme.colorBorder
                border.width: 1
            }

            property bool uploadComplete: false
            property bool uploadSuccess: false
            property bool uploadInProgress: false

            onOpened: {
                if (uploadProgressPopup.uploadComplete) {
                    retryTimer.start();
                    return;
                }

                uploadProgressPopup.uploadComplete = false;
                uploadProgressPopup.uploadSuccess = false;
                uploadProgressPopup.uploadInProgress = true;
                resetTimer.start();
            }

            onClosed: {
                resetTimer.stop();
                retryTimer.stop();
                uploadProgressPopup.uploadInProgress = false;
            }

            Timer {
                id: resetTimer
                interval: 10000 // 10 секунд таймаут
                repeat: false
                onTriggered: {
                    if (uploadProgressPopup.uploadInProgress && !uploadProgressPopup.uploadComplete) {
                        uploadProgressPopup.uploadInProgress = false;
                        uploadProgressPopup.uploadComplete = true;
                        uploadProgressPopup.uploadSuccess = false;
                        retryTimer.start();
                    }
                }
            }

            Timer {
                id: retryTimer
                interval: 3000
                repeat: false
                onTriggered: {
                    uploadProgressPopup.close();
                }
            }

            Connections {
                target: DataManager

                function onErrorOccurred(errorMsg) {
                    if (uploadProgressPopup.uploadInProgress && !uploadProgressPopup.uploadComplete) {
                        uploadProgressPopup.uploadInProgress = false;
                        uploadProgressPopup.uploadComplete = true;
                        uploadProgressPopup.uploadSuccess = false;
                        retryTimer.start();
                    } else {
                        console.log("QML: ignoring errorOccurred (not current upload or already completed)");
                    }
                }

                function onSettingsUploadFinished(success) {
                    if (uploadProgressPopup.uploadInProgress && !uploadProgressPopup.uploadComplete) {
                        uploadProgressPopup.uploadInProgress = false;
                        resetTimer.stop();
                        uploadProgressPopup.uploadComplete = true;
                        uploadProgressPopup.uploadSuccess = success;
                        retryTimer.start();
                    } else {
                        if (!uploadProgressPopup.uploadComplete) {
                            uploadProgressPopup.uploadComplete = true;
                            uploadProgressPopup.uploadSuccess = success;
                        } else {
                            console.log("QML: settingsUploadFinished ignored (already completed)");
                        }
                    }
                }

                function onLoadingChanged() {
                // Резерв — не меняем финальный статус здесь.
                }
            }

            contentItem: ColumnLayout {
                spacing: 20

                Label {
                    text: uploadProgressPopup.uploadComplete ? (uploadProgressPopup.uploadSuccess ? qsTr("Upload Successful") : qsTr("Upload Failed")) : qsTr("Uploading Settings")
                    font.bold: true
                    font.pointSize: Theme.fontSubtitle
                    color: uploadProgressPopup.uploadComplete ? (uploadProgressPopup.uploadSuccess ? Theme.colorSuccess : Theme.colorError) : Theme.colorTextPrimary
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                ProgressBar {
                    id: progressBar
                    Layout.fillWidth: true
                    Layout.preferredHeight: 8
                    visible: !uploadProgressPopup.uploadComplete
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
                    visible: uploadProgressPopup.uploadComplete

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: uploadProgressPopup.uploadSuccess ? Theme.colorSuccess : Theme.colorError

                        Text {
                            anchors.centerIn: parent
                            text: uploadProgressPopup.uploadSuccess ? "✓" : "!"
                            color: "white"
                            font.pointSize: 24
                            font.bold: true
                        }
                    }
                }

                Label {
                    text: uploadProgressPopup.uploadComplete ? (uploadProgressPopup.uploadSuccess ? qsTr("Settings have been successfully uploaded to the server.") : qsTr("Failed to upload settings. Please check your connection and try again.")) : qsTr("Please wait while settings are being uploaded...")
                    wrapMode: Text.WordWrap
                    color: Theme.colorTextSecondary
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Button {
                    id: closeStatusButton
                    text: uploadProgressPopup.uploadComplete ? "Close" : "Cancel"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    visible: uploadProgressPopup.uploadComplete || !DataManager.isLoading

                    background: Rectangle {
                        color: closeStatusButton.pressed ? Theme.colorButtonPrimaryHover : Theme.colorButtonPrimary
                        radius: Theme.radiusButton
                    }

                    contentItem: Text {
                        text: closeStatusButton.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: Theme.fontSmall
                    }

                    onClicked: uploadProgressPopup.close()
                }
            }
        }
    }
}

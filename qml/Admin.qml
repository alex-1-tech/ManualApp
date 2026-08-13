pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "styles"

ScrollView {
    id: root
    anchors.fill: parent
    clip: true

    contentItem: Flickable {
        id: flick
        anchors.fill: parent
        clip: true
        contentHeight: mainColumn.implicitHeight
        contentWidth: width

        ColumnLayout {
            id: mainColumn
            width: root.width > 1100 ? 1000 : root.width * 0.92
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10
            spacing: 20

            RowLayout {
                Layout.leftMargin: 50
                Image {
                    source: "qrc:///media/icons/icon-settings.svg"
                    sourceSize.width: 40
                    sourceSize.height: 40
                }

                Text {
                    text: qsTr("Administrator Panel")
                    color: Theme.colorTextPrimary
                    font.pointSize: 24
                    font.bold: true
                }

                Item {
                    Layout.fillWidth: true
                }

                // Индикатор админ-режима
                Rectangle {
                    width: 100
                    height: 30
                    radius: 15
                    color: Theme.colorSuccess

                    Text {
                        anchors.centerIn: parent
                        text: "ADMIN"
                        color: "white"
                        font.bold: true
                        font.pointSize: 10
                    }
                }
            }

            // ===== Системная информация =====
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: Theme.colorBgCard
                radius: Theme.radiusCard
                border.color: Theme.colorBorder
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 10

                    Text {
                        text: qsTr("System Information")
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSubtitle
                        font.bold: true
                    }

                    GridLayout {
                        columns: 4
                        columnSpacing: 20
                        rowSpacing: 8
                        Layout.fillWidth: true

                        Text {
                            text: qsTr("App Version:")
                            color: Theme.colorTextMuted
                            font.pointSize: Theme.fontSmall
                        }
                        Text {
                            text: DataManager.appVersion()
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                        }

                        Text {
                            text: qsTr("Admin Mode:")
                            color: Theme.colorTextMuted
                            font.pointSize: Theme.fontSmall
                        }
                        Text {
                            text: AdminManager.adminMode ? qsTr("ACTIVE") : qsTr("INACTIVE")
                            color: AdminManager.adminMode ? Theme.colorSuccess : Theme.colorError
                            font.bold: true
                            font.pointSize: Theme.fontSmall
                        }
                    }
                }
            }

            // ===== Управление моделями =====
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 210
                color: Theme.colorBgCard
                radius: Theme.radiusCard
                border.color: Theme.colorBorder
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    Text {
                        text: qsTr("Model Management")
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSubtitle
                        font.bold: true
                    }

                    RowLayout {
                        spacing: 15
                        Layout.fillWidth: true

                        Text {
                            text: qsTr("Current Model:")
                            color: Theme.colorTextMuted
                            font.pointSize: Theme.fontBody
                        }
                        Text {
                            text: SettingsManager.currentModel.toUpperCase()
                            color: Theme.colorAccent
                            font.bold: true
                            font.pointSize: Theme.fontBody
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    Text {
                        text: qsTr("Available Models:")
                        color: Theme.colorTextMuted
                        font.pointSize: Theme.fontSmall
                    }

                    Flow {
                        spacing: 10
                        Layout.fillWidth: true

                        Repeater {
                            model: SettingsManager.availableModels

                            delegate: Button {
                                id: modelButton
                                required property var modelData

                                text: modelData.toUpperCase()
                                enabled: modelData !== SettingsManager.currentModel

                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 36

                                background: Rectangle {
                                    color: modelButton.enabled ? (modelButton.down ? Theme.colorButtonPrimaryHover : Theme.colorButtonSecondary) : Theme.colorButtonDisabled
                                    radius: Theme.radiusButton
                                }

                                contentItem: Text {
                                    text: modelButton.text
                                    color: modelButton.enabled ? Theme.colorTextPrimary : Theme.colorTextMuted
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pointSize: Theme.fontSmall
                                }

                                onClicked: {
                                    confirmModelSwitch.openDialog(modelData);
                                }
                            }
                        }
                    }
                }
            }

            // ===== Управление приложением =====
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 180
                color: Theme.colorBgCard
                radius: Theme.radiusCard
                border.color: Theme.colorBorder
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    Text {
                        text: qsTr("Application Control")
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSubtitle
                        font.bold: true
                    }

                    GridLayout {
                        columns: 2
                        columnSpacing: 20
                        rowSpacing: 12
                        Layout.fillWidth: true

                        Text {
                            text: qsTr("First Run Flag:")
                            color: Theme.colorTextMuted
                            font.pointSize: Theme.fontBody
                        }
                        Text {
                            text: SettingsManager.isFirstRun ? qsTr("NOT COMPLETED") : qsTr("COMPLETED")
                            color: SettingsManager.isFirstRun ? Theme.colorWarning : Theme.colorSuccess
                            font.bold: true
                            font.pointSize: Theme.fontBody
                        }
                    }

                    RowLayout {
                        spacing: 12
                        Layout.fillWidth: true

                        Button {
                            text: qsTr("Reset First Run Flag")
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40

                            background: Rectangle {
                                color: parent.down ? Theme.colorWarning : Theme.colorButtonSecondary
                                radius: Theme.radiusButton
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pointSize: Theme.fontSmall
                                font.bold: true
                            }

                            onClicked: {
                                confirmResetFirstRun.open();
                            }
                        }

                        Button {
                            text: qsTr("Force Sync Settings")
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40

                            background: Rectangle {
                                color: parent.down ? Theme.colorButtonPrimaryHover : Theme.colorButtonPrimary
                                radius: Theme.radiusButton
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pointSize: Theme.fontSmall
                                font.bold: true
                            }

                            onClicked: {
                                DataManager.syncSettingsWithServer();
                                notificationSuccess.show(qsTr("Settings sync triggered"));
                            }
                        }
                    }
                }
            }

            // ===== Лицензия =====
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                color: Theme.colorBgCard
                radius: Theme.radiusCard
                border.color: Theme.colorBorder
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    Text {
                        text: qsTr("License Management")
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSubtitle
                        font.bold: true
                    }

                    RowLayout {
                        spacing: 12
                        Layout.fillWidth: true

                        Button {
                            text: qsTr("Clear License")
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40

                            background: Rectangle {
                                color: parent.down ? Qt.darker(Theme.colorError) : Theme.colorError
                                radius: Theme.radiusButton
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pointSize: Theme.fontSmall
                                font.bold: true
                            }

                            onClicked: {
                                confirmClearLicense.open();
                            }
                        }

                        Button {
                            text: qsTr("Show License Info")
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40

                            background: Rectangle {
                                color: parent.down ? Theme.colorButtonPrimaryHover : Theme.colorButtonPrimary
                                radius: Theme.radiusButton
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pointSize: Theme.fontSmall
                                font.bold: true
                            }

                            onClicked: {
                                if (DataManager.licenseHandler) {
                                    console.log("go open");
                                    licenseInfoDialog.open();
                                } else {
                                    notificationInfo.show(qsTr("License handler not available"));
                                }
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.minimumHeight: 20
            }
        }
    }

    // ===== Диалог подтверждения смены модели =====
    Dialog {
        id: confirmModelSwitch
        modal: true
        width: 400
        height: 240
        anchors.centerIn: Overlay.overlay

        property string targetModel: ""

        background: Rectangle {
            color: Theme.colorBgPrimary
            radius: 8
            border.color: Theme.colorBorder
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 20

            Text {
                text: qsTr("Switch Model")
                font.pointSize: Theme.fontSubtitle
                font.bold: true
                color: Theme.colorTextPrimary
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: qsTr("to %1?\nThis will reload application settings.").arg(confirmModelSwitch.targetModel.toUpperCase())
                color: Theme.colorTextSecondary
                font.pointSize: Theme.fontBody
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            RowLayout {
                spacing: 12
                Layout.fillWidth: true

                Button {
                    text: qsTr("Cancel")
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40

                    background: Rectangle {
                        color: parent.down ? Theme.colorButtonSecondaryHover : Theme.colorButtonSecondary
                        radius: Theme.radiusButton
                    }

                    contentItem: Text {
                        text: parent.text
                        color: Theme.colorTextPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: Theme.fontSmall
                    }

                    onClicked: confirmModelSwitch.close()
                }

                Button {
                    text: qsTr("Switch")
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40

                    background: Rectangle {
                        color: parent.down ? Theme.colorButtonPrimaryHover : Theme.colorButtonPrimary
                        radius: Theme.radiusButton
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: Theme.fontSmall
                        font.bold: true
                    }

                    onClicked: {
                        SettingsManager.currentModel = confirmModelSwitch.targetModel;
                        notificationSuccess.show(qsTr("Switched to model: %1").arg(confirmModelSwitch.targetModel.toUpperCase()));
                        confirmModelSwitch.close();
                    }
                }
            }
        }

        function openDialog(modelName) {
            targetModel = modelName;
            open();
        }
    }

    // ===== Диалог подтверждения сброса флага =====
    Dialog {
        id: confirmResetFirstRun
        modal: true
        width: 400
        height: 270
        anchors.centerIn: Overlay.overlay

        background: Rectangle {
            color: Theme.colorBgPrimary
            radius: 8
            border.color: Theme.colorBorder
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 20

            Text {
                text: qsTr("Reset First Run Flag")
                font.pointSize: Theme.fontSubtitle
                font.bold: true
                color: Theme.colorTextPrimary
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: qsTr("This will reset the first run flag.\nOn next application start, setup wizard will appear.\nContinue?")
                color: Theme.colorTextSecondary
                font.pointSize: Theme.fontBody
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            RowLayout {
                spacing: 12
                Layout.fillWidth: true

                Button {
                    text: qsTr("Cancel")
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40

                    background: Rectangle {
                        color: parent.down ? Theme.colorButtonSecondaryHover : Theme.colorButtonSecondary
                        radius: Theme.radiusButton
                    }

                    contentItem: Text {
                        text: parent.text
                        color: Theme.colorTextPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: Theme.fontSmall
                    }

                    onClicked: confirmResetFirstRun.close()
                }

                Button {
                    text: qsTr("Reset")
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40

                    background: Rectangle {
                        color: parent.down ? Qt.darker(Theme.colorWarning) : Theme.colorWarning
                        radius: Theme.radiusButton
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: Theme.fontSmall
                        font.bold: true
                    }

                    onClicked: {
                        SettingsManager.isFirstRun = true;
                        notificationSuccess.show(qsTr("First run flag reset. Restart app to see setup wizard."));
                        confirmResetFirstRun.close();
                    }
                }
            }
        }
    }

    // ===== Диалог подтверждения очистки лицензии =====
    Dialog {
        id: confirmClearLicense
        modal: true
        width: 400
        height: 240
        anchors.centerIn: Overlay.overlay

        background: Rectangle {
            color: Theme.colorBgPrimary
            radius: 8
            border.color: Theme.colorBorder
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 20

            Text {
                text: qsTr("Clear License")
                font.pointSize: Theme.fontSubtitle
                font.bold: true
                color: Theme.colorTextPrimary
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: qsTr("This will clear the saved license from settings.\nContinue?")
                color: Theme.colorTextSecondary
                font.pointSize: Theme.fontBody
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            RowLayout {
                spacing: 12
                Layout.fillWidth: true

                Button {
                    text: qsTr("Cancel")
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40

                    background: Rectangle {
                        color: parent.down ? Theme.colorButtonSecondaryHover : Theme.colorButtonSecondary
                        radius: Theme.radiusButton
                    }

                    contentItem: Text {
                        text: parent.text
                        color: Theme.colorTextPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: Theme.fontSmall
                    }

                    onClicked: confirmClearLicense.close()
                }

                Button {
                    text: qsTr("Clear")
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40

                    background: Rectangle {
                        color: parent.down ? Qt.darker(Theme.colorError) : Theme.colorError
                        radius: Theme.radiusButton
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: Theme.fontSmall
                        font.bold: true
                    }

                    onClicked: {
                        if (DataManager.licenseHandler()) {
                            DataManager.licenseHandler().clearLicense();
                            notificationSuccess.show(qsTr("License cleared successfully"));
                        }
                        confirmClearLicense.close();
                    }
                }
            }
        }
    }

    // ===== Уведомление об успехе =====
    Rectangle {
        id: notificationSuccess
        anchors.centerIn: parent
        width: 300
        height: 50
        color: Theme.colorSuccess
        radius: 8
        opacity: 0
        z: 1000

        property string messageText: ""

        Text {
            anchors.centerIn: parent
            text: notificationSuccess.messageText
            color: "white"
            font.bold: true
            font.pointSize: Theme.fontSmall
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            width: parent.width - 20
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
            }
        }

        function show(message) {
            messageText = message;
            opacity = 1;
            hideTimer.start();
        }

        Timer {
            id: hideTimer
            interval: 2000
            onTriggered: notificationSuccess.opacity = 0
        }
    }

    // ===== Информационное уведомление =====
    Rectangle {
        id: notificationInfo
        anchors.centerIn: parent
        width: 300
        height: 50
        color: Theme.colorButtonPrimary
        radius: 8
        opacity: 0
        z: 1000

        property string messageText: ""

        Text {
            anchors.centerIn: parent
            text: notificationInfo.messageText
            color: "white"
            font.bold: true
            font.pointSize: Theme.fontSmall
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            width: parent.width - 20
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
            }
        }

        function show(message) {
            messageText = message;
            opacity = 1;
            hideTimerInfo.start();
        }

        Timer {
            id: hideTimerInfo
            interval: 2000
            onTriggered: notificationInfo.opacity = 0
        }
    }

    // ===== Диалог информации о лицензии =====
    Dialog {
        id: licenseInfoDialog
        modal: true
        width: 600
        height: 520
        anchors.centerIn: Overlay.overlay

        property var licenseData: ({})

        background: Rectangle {
            color: Theme.colorBgPrimary
            radius: 12
            border.color: Theme.colorBorder
            border.width: 1
        }

        onOpened: {
            console.log("opened");
            if (DataManager.licenseHandler) {
                licenseData = DataManager.licenseHandler().getLicenseInfoForDisplay();
                console.log("READ ", licenseData);
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            // Заголовок
            RowLayout {
                spacing: 12
                Layout.fillWidth: true

                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: licenseInfoDialog.licenseData.isActive ? Theme.colorSuccess : (licenseInfoDialog.licenseData.hasLicense ? Theme.colorError : Theme.colorWarning)

                    Text {
                        anchors.centerIn: parent
                        text: licenseInfoDialog.licenseData.isActive ? "✓" : (licenseInfoDialog.licenseData.hasLicense ? "✗" : "!")
                        color: "white"
                        font.bold: true
                        font.pointSize: 18
                    }
                }

                ColumnLayout {
                    spacing: 4
                    Layout.fillWidth: true

                    Text {
                        text: qsTr("License Information")
                        font.pointSize: Theme.fontSubtitle
                        font.bold: true
                        color: Theme.colorTextPrimary
                    }

                    Text {
                        text: licenseInfoDialog.licenseData.hasLicense ? (licenseInfoDialog.licenseData.isActive ? qsTr("License is ACTIVE") : qsTr("License is INACTIVE")) : qsTr("No license installed")
                        color: licenseInfoDialog.licenseData.isActive ? Theme.colorSuccess : (licenseInfoDialog.licenseData.hasLicense ? Theme.colorError : Theme.colorWarning)
                        font.pointSize: Theme.fontSmall
                        font.bold: true
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: "×"
                    width: 32
                    height: 32
                    padding: 0

                    background: Rectangle {
                        color: parent.down ? Theme.colorButtonSecondaryHover : "transparent"
                        radius: 16
                    }

                    contentItem: Text {
                        text: parent.text
                        color: Theme.colorTextMuted
                        font.pointSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: licenseInfoDialog.close()
                }
            }

            Rectangle {
                height: 1
                Layout.fillWidth: true
                color: Theme.colorBorder
            }

            // Лицензионный ключ (с возможностью копирования)
            ColumnLayout {
                spacing: 8
                Layout.fillWidth: true

                Text {
                    text: qsTr("License Key")
                    color: Theme.colorTextMuted
                    font.pointSize: Theme.fontSmall
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 80
                    color: Theme.colorBgSecondary
                    radius: 8
                    border.color: Theme.colorBorder
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        TextEdit {
                            id: licenseKeyText
                            Layout.fillWidth: true
                            text: licenseInfoDialog.licenseData.hasLicense ? (licenseInfoDialog.licenseData.license_key || "") : qsTr("No license key")
                            color: Theme.colorTextPrimary
                            font.pointSize: Theme.fontSmall
                            font.family: "Courier New, monospace"
                            wrapMode: Text.Wrap
                            readOnly: true
                            selectByMouse: true
                        }

                        Button {
                            text: qsTr("Copy")
                            enabled: licenseInfoDialog.licenseData.hasLicense && licenseInfoDialog.licenseData.license_key

                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 36

                            background: Rectangle {
                                color: parent.down ? Theme.colorButtonPrimaryHover : Theme.colorButtonPrimary
                                radius: Theme.radiusButton
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pointSize: Theme.fontSmall
                                font.bold: true
                            }

                            onClicked: {
                                licenseKeyText.selectAll();
                                licenseKeyText.copy();
                                copyNotification.show(qsTr("License key copied!"));
                            }
                        }
                    }
                }
            }

            // Информация о лицензии в виде сетки
            ColumnLayout {
                spacing: 8
                Layout.fillWidth: true

                Text {
                    text: qsTr("License Details")
                    color: Theme.colorTextMuted
                    font.pointSize: Theme.fontSmall
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 280
                    color: Theme.colorBgSecondary
                    radius: 8
                    border.color: Theme.colorBorder
                    border.width: 1

                    Flickable {
                        anchors.fill: parent
                        anchors.margins: 12
                        contentHeight: detailsColumn.implicitHeight
                        clip: true

                        ColumnLayout {
                            id: detailsColumn
                            width: parent.width - 20
                            spacing: 12

                            // Product
                            RowLayout {
                                spacing: 12
                                Layout.fillWidth: true

                                Text {
                                    text: qsTr("Product:")
                                    color: Theme.colorTextMuted
                                    font.pointSize: Theme.fontSmall
                                    Layout.preferredWidth: 120
                                }

                                Text {
                                    text: licenseData.product ? licenseData.product.toUpperCase() : "-"
                                    color: Theme.colorAccent
                                    font.pointSize: Theme.fontSmall
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                            }

                            // Company
                            RowLayout {
                                spacing: 12
                                Layout.fillWidth: true

                                Text {
                                    text: qsTr("Company:")
                                    color: Theme.colorTextMuted
                                    font.pointSize: Theme.fontSmall
                                    Layout.preferredWidth: 120
                                }

                                Text {
                                    text: licenseData.company_name || "-"
                                    color: Theme.colorTextPrimary
                                    font.pointSize: Theme.fontSmall
                                    Layout.fillWidth: true
                                }
                            }

                            // Version
                            RowLayout {
                                spacing: 12
                                Layout.fillWidth: true

                                Text {
                                    text: qsTr("Version:")
                                    color: Theme.colorTextMuted
                                    font.pointSize: Theme.fontSmall
                                    Layout.preferredWidth: 120
                                }

                                Text {
                                    text: licenseData.ver || "1.0"
                                    color: Theme.colorTextPrimary
                                    font.pointSize: Theme.fontSmall
                                    Layout.fillWidth: true
                                }
                            }

                            Rectangle {
                                height: 1
                                Layout.fillWidth: true
                                color: Theme.colorBorder
                            }

                            // Expiration
                            RowLayout {
                                spacing: 12
                                Layout.fillWidth: true

                                Text {
                                    text: qsTr("Expiration Date:")
                                    color: Theme.colorTextMuted
                                    font.pointSize: Theme.fontSmall
                                    Layout.preferredWidth: 120
                                }

                                Text {
                                    text: licenseData.expDateFormatted || "-"
                                    color: licenseData.isExpired ? Theme.colorError : Theme.colorTextPrimary
                                    font.pointSize: Theme.fontSmall
                                    font.bold: licenseData.isExpired
                                    Layout.fillWidth: true
                                }
                            }

                            // Days remaining
                            RowLayout {
                                spacing: 12
                                Layout.fillWidth: true
                                visible: !licenseData.isExpired && licenseData.daysRemaining >= 0

                                Text {
                                    text: qsTr("Days Remaining:")
                                    color: Theme.colorTextMuted
                                    font.pointSize: Theme.fontSmall
                                    Layout.preferredWidth: 120
                                }

                                Text {
                                    text: licenseData.daysRemaining === -1 ? "-" : licenseData.daysRemaining.toString()
                                    color: licenseData.daysRemaining < 30 ? Theme.colorWarning : Theme.colorSuccess
                                    font.pointSize: Theme.fontSmall
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                            }

                            Rectangle {
                                height: 1
                                Layout.fillWidth: true
                                color: Theme.colorBorder
                            }

                            // Device HWID
                            RowLayout {
                                spacing: 12
                                Layout.fillWidth: true

                                Text {
                                    text: qsTr("Device HWID:")
                                    color: Theme.colorTextMuted
                                    font.pointSize: Theme.fontSmall
                                    Layout.preferredWidth: 120
                                }

                                Text {
                                    text: licenseData.device_hwid || "-"
                                    color: Theme.colorTextPrimary
                                    font.pointSize: Theme.fontSmall
                                    font.family: "Courier New, monospace"
                                    Layout.fillWidth: true
                                    wrapMode: Text.Wrap
                                }
                            }

                            // Host HWID
                            RowLayout {
                                spacing: 12
                                Layout.fillWidth: true

                                Text {
                                    text: qsTr("Host HWID:")
                                    color: Theme.colorTextMuted
                                    font.pointSize: Theme.fontSmall
                                    Layout.preferredWidth: 120
                                }

                                Text {
                                    text: licenseData.host_hwid || "-"
                                    color: Theme.colorTextPrimary
                                    font.pointSize: Theme.fontSmall
                                    font.family: "Courier New, monospace"
                                    Layout.fillWidth: true
                                    wrapMode: Text.Wrap
                                }
                            }

                            // Features (если есть)
                            Rectangle {
                                height: 1
                                Layout.fillWidth: true
                                color: Theme.colorBorder
                                visible: licenseData.features && Object.keys(licenseData.features).length > 0
                            }

                            Text {
                                text: qsTr("Features:")
                                color: Theme.colorTextMuted
                                font.pointSize: Theme.fontSmall
                                font.bold: true
                                visible: licenseData.features && Object.keys(licenseData.features).length > 0
                            }

                            Repeater {
                                model: licenseData.features ? Object.keys(licenseData.features) : []

                                delegate: RowLayout {
                                    spacing: 12
                                    Layout.fillWidth: true
                                    Layout.leftMargin: 20

                                    required property string modelData

                                    Text {
                                        text: modelData.replace(/_/g, " ").replace(/\b\w/g, c => c.toUpperCase()) + ":"
                                        color: Theme.colorTextMuted
                                        font.pointSize: Theme.fontSmall
                                        Layout.preferredWidth: 100
                                    }

                                    Text {
                                        text: licenseData.features[modelData] ? "✓ Enabled" : "✗ Disabled"
                                        color: licenseData.features[modelData] ? Theme.colorSuccess : Theme.colorError
                                        font.pointSize: Theme.fontSmall
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                height: 1
                Layout.fillWidth: true
                color: Theme.colorBorder
            }

            // Кнопка закрытия
            Button {
                text: qsTr("Close")
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                background: Rectangle {
                    color: parent.down ? Theme.colorButtonSecondaryHover : Theme.colorButtonSecondary
                    radius: Theme.radiusButton
                }

                contentItem: Text {
                    text: parent.text
                    color: Theme.colorTextPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: Theme.fontSmall
                }

                onClicked: licenseInfoDialog.close()
            }
        }
    }

    // Уведомление о копировании
    Rectangle {
        id: copyNotification
        anchors.centerIn: parent
        width: 250
        height: 48
        color: Theme.colorSuccess
        radius: 24
        opacity: 0
        z: 1001

        property string messageText: ""

        Text {
            anchors.centerIn: parent
            text: copyNotification.messageText
            color: "white"
            font.bold: true
            font.pointSize: Theme.fontSmall
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }

        function show(message) {
            messageText = message;
            opacity = 1;
            copyHideTimer.start();
        }

        Timer {
            id: copyHideTimer
            interval: 1500
            onTriggered: copyNotification.opacity = 0
        }
    }
}

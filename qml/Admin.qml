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
                                    color: modelButton.enabled ? 
                                           (modelButton.down ? Theme.colorButtonPrimaryHover : Theme.colorButtonSecondary) : 
                                           Theme.colorButtonDisabled
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
                                    confirmModelSwitch.open(modelData)
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
                                confirmResetFirstRun.open()
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
                                DataManager.syncSettingsWithServer()
                                notificationSuccess.show(qsTr("Settings sync triggered"))
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
                                confirmClearLicense.open()
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
                                if (DataManager.licenseHandler()) {
                                    var info = DataManager.licenseHandler().license()
                                    console.log("License info:", JSON.stringify(info, null, 2))
                                    notificationInfo.show(qsTr("License info printed to console"))
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
        height: 180
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
                text: qsTr("Switch to model: %1?\nThis will reload application settings.").arg(confirmModelSwitch.targetModel.toUpperCase())
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
                        SettingsManager.currentModel = confirmModelSwitch.targetModel
                        notificationSuccess.show(qsTr("Switched to model: %1").arg(confirmModelSwitch.targetModel.toUpperCase()))
                        confirmModelSwitch.close()
                    }
                }
            }
        }
        
        function open(modelName) {
            targetModel = modelName
            open()
        }
    }
    
    // ===== Диалог подтверждения сброса флага =====
    Dialog {
        id: confirmResetFirstRun
        modal: true
        width: 400
        height: 180
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
                        SettingsManager.isFirstRun = true
                        notificationSuccess.show(qsTr("First run flag reset. Restart app to see setup wizard."))
                        confirmResetFirstRun.close()
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
        height: 180
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
                            DataManager.licenseHandler().clearLicense()
                            notificationSuccess.show(qsTr("License cleared successfully"))
                        }
                        confirmClearLicense.close()
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
            messageText = message
            opacity = 1
            hideTimer.start()
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
            messageText = message
            opacity = 1
            hideTimerInfo.start()
        }
        
        Timer {
            id: hideTimerInfo
            interval: 2000
            onTriggered: notificationInfo.opacity = 0
        }
    }
}
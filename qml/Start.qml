pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import ManualAppCorePlugin 1.0
import "styles"

ApplicationWindow {
    id: appWindow

    visibility: Window.Maximized
    minimumWidth: 800
    minimumHeight: 600

    visible: true
    title: qsTr("Техническое обслуживание")
    color: Theme.colorBgPrimary

    property bool firstRun: true
    property bool waitingForSettings: false
    property string settingsError: ""

    Component.onCompleted: {
        DataManager.setSettingsManager(SettingsManager);
        firstRun = SettingsManager.isFirstRun;
        if (firstRun) {
            contentLoader.sourceComponent = settingsComponent;
        } else {
            DataManager.syncReportsWithServer();
            contentLoader.sourceComponent = mainComponent;
        }
    }

    onClosing: function () {
        DataManager.setStartTime(null);
    }

    Loader {
        id: contentLoader
        anchors.fill: parent
    }
    Connections {
        target: DataManager

        function onLoadingChanged() {
            if (appWindow.waitingForSettings) {
                appWindow.waitingForSettings = false;
                if (!DataManager.error || DataManager.error === "") {
                    contentLoader.sourceComponent = mainComponent;
                } else {
                    appWindow.settingsError = DataManager.error;
                    settingsErrorDialog.open();
                }
            }
        }

        function onErrorChanged() {
            if (appWindow.waitingForSettings) {
                appWindow.waitingForSettings = false;
                if (DataManager.error && DataManager.error !== "") {
                    appWindow.settingsError = DataManager.error;
                    settingsErrorDialog.open();
                } else {
                    contentLoader.sourceComponent = mainComponent;
                }
            }
        }
    }

    Component {
        id: settingsComponent
        InitSerial {
            id: initserial

            onSettingsCompleted: {
                SettingsManager.completeFirstRun();

                var serialNumber = initserial.currentValue;
                DataManager.setCurrentSettings("http://127.0.0.1:8000/api/kalmar32/" + serialNumber + "/get_settings");
                appWindow.waitingForSettings = true;
            }
        }
    }

    Component {
        id: mainComponent
        Main {}
    }

    Rectangle {
        anchors.fill: parent
        visible: appWindow.waitingForSettings
        color: "#80000000"
        z: 999

        Column {
            anchors.centerIn: parent
            spacing: 12
            width: parent.width * 0.6

            BusyIndicator {
                running: true
                width: 48
                height: 48
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                text: qsTr("Загрузка настроек... Пожалуйста, подождите.")
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                width: parent.width * 0.9
            }
        }
    }

    Dialog {
        id: settingsErrorDialog
        title: qsTr("Ошибка загрузки настроек")
        modal: true
        width: Math.min(appWindow.width * 0.8, 640)

        standardButtons: Dialog.Ok | Dialog.Retry

        onAccepted: {
            settingsErrorDialog.close();
        }
        onRejected: {
            if (SettingsManager.serialNumber && SettingsManager.serialNumber !== "") {
                appWindow.waitingForSettings = true;
                DataManager.setCurrentSettings("http://127.0.0.1:8000/api/kalmar32/" + SettingsManager.serialNumber + "/get_settings");
            } else {
                settingsErrorDialog.close();
            }
        }

        contentItem: Column {
            width: settingsErrorDialog.width * 0.96
            spacing: 8
            padding: 12

            Label {
                wrapMode: Text.WordWrap
                text: appWindow.settingsError || DataManager.error || qsTr("Неизвестная ошибка")
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}

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
    title: qsTr("ManualApp")
    color: Theme.colorBgPrimary
    property bool firstRun: true

    Component.onCompleted: {
        DataManager.setSettingsManager(SettingsManager)

        firstRun = SettingsManager.isFirstRun
        if (firstRun) {
            // При первом запуске показываем выбор модели
            contentLoader.sourceComponent = modelSelectionComponent
        } else {
            DataManager.syncReportsWithServer();
            contentLoader.sourceComponent = mainComponent
        }
    }

    onClosing: function () {
        // if(DataManager.startTime != "" && DataManager.startTime != null)
        //     DataManager.save(false);
        DataManager.setStartTime(null);
    }

    Loader {
        id: contentLoader
        anchors.fill: parent
    }

    // Компонент выбора модели
    Component {
        id: modelSelectionComponent
        ModelSelectionPage {
            onModelSelected: function(modelType) {
                // Сохраняем выбранную модель
                SettingsManager.currentModel = modelType
                // Переходим к настройкам оборудования
                contentLoader.sourceComponent = settingsComponent
            }
        }
    }

    // Компонент начальных настроек оборудования
    Component {
        id: settingsComponent
        SettingsForm {
            onSettingsCompleted: {
                SettingsManager.completeFirstRun();
                if(SettingsManager.currentModel == "kalmar32")
                    DataManager.uploadSettingsToDjango(DataManager.djangoBaseUrl() + "/api/kalmar32/");
                else
                    DataManager.uploadSettingsToDjango(DataManager.djangoBaseUrl() + "/api/phasar32/");
                contentLoader.sourceComponent = mainComponent
            }
            // onBackRequested: {
            //     // Возврат к выбору модели
            //     contentLoader.sourceComponent = modelSelectionComponent
            // }
        }
    }

    // Основной компонент приложения
    Component {
        id: mainComponent
        Main {
        }
    }
}

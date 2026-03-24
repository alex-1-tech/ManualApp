pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "models"

ScrollView {
    id: root

    anchors.fill: parent
    contentWidth: availableWidth
    clip: true

    ColumnLayout {
        width: root.availableWidth
        spacing: 0
    
        AboutRenderer {
            currentModel: SettingsManager.currentModel
            modelSettings: SettingsManager.getSettings(currentModel);
        }
    }
}
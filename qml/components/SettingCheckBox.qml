pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import ManualAppCorePlugin 1.0
import "../styles"

CheckBox {
    property string settingName: ""
    checked: SettingsManager[settingName]
    onCheckedChanged: SettingsManager[settingName] = checked

    font.pointSize: Theme.fontSmall
}

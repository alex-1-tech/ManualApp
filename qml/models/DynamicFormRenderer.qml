pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "../components"
import "../styles"

ColumnLayout {
    id: root

    property var config: null
    property var modelSettings: null
    property bool isInitialMode: false
    property bool showConditionalSections: true

    spacing: 20
    Layout.fillWidth: true

    Repeater {
        model: root.config ? root.config : []

        delegate: ColumnLayout {
            id: sectionDelegate
            required property var modelData
            Layout.fillWidth: true

            property var sectionData: modelData
            property bool sectionVisible: true

            property bool isRegistrationSection: sectionData.title === "Registration data"

            ColumnLayout {
                visible: sectionDelegate.sectionVisible
                width: parent.width
                spacing: 0

                CardSection {
                    title: sectionDelegate.sectionData.title

                    Repeater {
                        model: {
                            if (!sectionDelegate.sectionData.fields)
                                return [];
                            return sectionDelegate.sectionData.fields;
                        }

                        delegate: Loader {
                            id: fieldLoader
                            required property var modelData
                            Layout.fillWidth: true

                            property var fieldData: modelData
                            property var settingsModel: root.modelSettings
                            property bool isRegistrationField: sectionDelegate.isRegistrationSection
                            property bool readOnly: !root.isInitialMode && isRegistrationField

                            sourceComponent: {
                                if (!fieldData)
                                    return null;
                                if (fieldData.cppName == "notes") {
                                    return textAreaComponent;
                                }
                                switch (fieldData.type) {
                                case "date":
                                    return dateFieldComponent;
                                case "boolean":
                                    return checkboxFieldComponent;
                                case "string":
                                default:
                                    return textFieldComponent;
                                }
                            }

                            onLoaded: {
                                if (item) {
                                    if (item.hasOwnProperty('label')) {
                                        item.label = fieldData.label || "";
                                    }
                                    if (item.hasOwnProperty('helpText')) {
                                        item.helpText = fieldData.helpText || "";
                                    }
                                    if (item.hasOwnProperty('settingName')) {
                                        item.settingName = fieldData.cppName || "";
                                    }
                                    if (item.hasOwnProperty('modelSettings')) {
                                        item.modelSettings = settingsModel;
                                    }

                                    if (item.hasOwnProperty('readOnly')) {
                                        item.readOnly = readOnly;
                                    }

                                    if (fieldData.type === "boolean" && item.hasOwnProperty('text')) {
                                        item.text = fieldData.checkboxText || "";
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: textFieldComponent

        FormField {
            Layout.fillWidth: true
        }
    }

    Component {
        id: dateFieldComponent

        RowLayout {
            id: dateFieldLayout
            spacing: 12
            Layout.fillWidth: true

            property string label
            property string placeholder
            property string settingName
            property var modelSettings
            property bool readOnly

            ModelSettingDate {
                label: dateFieldLayout.label
                placeholder: dateFieldLayout.placeholder
                settingName: dateFieldLayout.settingName
                modelSettings: dateFieldLayout.modelSettings
                initialDate: {
                    if (modelSettings && modelSettings.getValue) {
                        var v = modelSettings.getValue(dateFieldLayout.settingName);
                        return v ? v : new Date();
                    }
                    return new Date();
                }
                readOnly: dateFieldLayout.readOnly
            }
        }
    }

    Component {
        id: checkboxFieldComponent

        RowLayout {
            id: checkboxFieldLayout
            spacing: 12
            Layout.fillWidth: true

            property string label
            property string text
            property string settingName
            property var modelSettings

            Label {
                Layout.preferredWidth: Math.min(450, root.width * 0.3)
                Layout.maximumWidth: 450
                Layout.minimumWidth: 200
                Layout.fillWidth: true
                text: checkboxFieldLayout.label
                color: Theme.colorTextPrimary
                font.pointSize: Theme.fontSmall
                wrapMode: Text.WordWrap
                maximumLineCount: 3
                elide: Text.ElideNone
                verticalAlignment: Text.AlignVCenter
            }

            ModelSettingCheckBox {
                Layout.fillWidth: true
                Layout.preferredWidth: 200
                settingName: checkboxFieldLayout.settingName
                modelSettings: checkboxFieldLayout.modelSettings
                // text: checkboxFieldLayout.text
            }
        }
    }

    Component {
        id: textAreaComponent

        FormField {
            Layout.fillWidth: true
            multiline: true
        }
    }
}

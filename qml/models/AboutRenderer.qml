pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "../styles"

ScrollView {
    id: root

    contentWidth: availableWidth
    clip: true

    Layout.fillWidth: true
    Layout.leftMargin: 40
    Layout.topMargin: 10

    property string currentModel: SettingsManager.currentModel
    property var modelSettings: null

    function formatDate(value) {
        if (!value)
            return "";

        const d = new Date(value);
        if (isNaN(d.getTime()))
            return "";

        return d.toLocaleDateString(Qt.locale(), "dd.MM.yyyy");
    }

    function formatValue(field, settingsObject) {
        if (!field || !settingsObject)
            return "";

        let value = settingsObject.getValue ? settingsObject.getValue(field.name) : "";

        if (field.type === "checkbox") {
            return value ? qsTr("+") : qsTr("-");
        }

        if (field.type === "date") {
            return formatDate(value);
        }

        return value || "";
    }

    ColumnLayout {
        id: mainColumn
        spacing: 20

        // ===== HEADER =====
        RowLayout {
            Layout.leftMargin: 50

            Image {
                source: "qrc:///media/icons/icon-about.svg"
                sourceSize.width: 40
                sourceSize.height: 40
                mipmap: true
            }

            Text {
                text: qsTr("About")
                color: Theme.colorTextPrimary
                font.pointSize: 24
            }
        }

        // ===== APP INFO =====
        SectionView {
            title: ""

            model: [
                {
                    "label": qsTr("App version"),
                    "value": DataManager.appVersion()
                },
                {
                    "label": qsTr("Current model"),
                    "value": root.currentModel.toUpperCase()
                }
            ]
        }

        // ===== MODEL SPECIFIC =====
        AboutSectionRenderer {
            config: SettingsManager.getModelSettings(root.currentModel).getSectionsMetadata()
            settingsObject: root.modelSettings
        }

        Item {
            Layout.fillHeight: true
            Layout.minimumHeight: 20
        }
    }

    // ============================================================
    // SECTION RENDERER
    // ============================================================

    component AboutSectionRenderer: ColumnLayout {
        id: aboutSection
        property var config
        property var settingsObject

        Layout.fillWidth: true
        spacing: 20

        Repeater {
            model: aboutSection.config ? aboutSection.config : []
            ColumnLayout {
                id: aboutRepeater

                required property var modelData
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: qsTr(aboutRepeater.modelData.title)
                    color: Theme.colorTextPrimary
                    font.pointSize: 18
                }

                Repeater {
                    model: aboutRepeater.modelData.fields ? aboutRepeater.modelData.fields : []

                    GridLayout {
                        id: aboutGrid

                        columns: 2
                        columnSpacing: 20
                        rowSpacing: 5
                        Layout.fillWidth: true
                        required property var modelData

                        Label {
                            text: qsTr(aboutGrid.modelData.label)
                            color: Theme.colorTextMuted
                            font.pointSize: Theme.fontSmall
                            font.bold: true
                            Layout.minimumWidth: 450
                            Layout.maximumWidth: 450
                            Layout.alignment: Qt.AlignTop
                        }

                        Loader {
                            Layout.fillWidth: true

                            sourceComponent: {
                                if (aboutGrid.modelData.type === "textarea")
                                    return multilineComponent;
                                else
                                    return singlelineComponent;
                            }

                            property var fieldData: aboutGrid.modelData
                            property var settingsObj: aboutSection.settingsObject

                            onLoaded: {
                                if (item) {
                                    item.textValue = root.formatValue(fieldData, settingsObj);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ============================================================
    // TEXT COMPONENTS
    // ============================================================

    Component {
        id: singlelineComponent

        TextInput {
            property string textValue: ""
            text: textValue
            readOnly: true
            selectByMouse: true
            color: Theme.colorTextPrimary
            font.pointSize: Theme.fontSmall
            width: parent.width
        }
    }

    Component {
        id: multilineComponent

        TextArea {
            property string textValue: ""
            text: textValue
            readOnly: true
            wrapMode: Text.WordWrap
            background: null
            padding: 0
            leftPadding: 0
            color: Theme.colorTextPrimary
            font.pointSize: Theme.fontSmall
            implicitHeight: Math.max(60, contentHeight)
        }
    }

    // ============================================================
    // SIMPLE SECTION VIEW (for header block)
    // ============================================================

    component SectionView: ColumnLayout {
        id: simpltSectionView
    
        property string title
        property var model: []

        Layout.fillWidth: true
        spacing: 10

        Text {
            visible: simpltSectionView.title !== ""
            text: simpltSectionView.title
            color: Theme.colorTextPrimary
            font.pointSize: 18
        }

        Repeater {
            model: model

            GridLayout {
                id: simpleGridLayout

                columns: 2
                columnSpacing: 20
                rowSpacing: 5
                Layout.fillWidth: true
                required property var modelData

                Label {
                    text: simpleGridLayout.modelData.label
                    color: Theme.colorTextMuted
                    font.pointSize: Theme.fontSmall
                    font.bold: true
                    Layout.minimumWidth: 450
                    Layout.maximumWidth: 450
                }

                TextInput {
                    text: simpleGridLayout.modelData.value || ""
                    readOnly: true
                    selectByMouse: true
                    color: Theme.colorTextPrimary
                    font.pointSize: Theme.fontSmall
                    width: parent.width
                }
            }
        }
    }
}

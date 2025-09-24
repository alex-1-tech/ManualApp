pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "styles"
import "components"

ScrollView {
    id: root

    clip: true

    signal settingsCompleted

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
                Layout.alignment: Qt.AlignHCenter
                Text {
                    text: qsTr("Введите характеристики")
                    color: Theme.colorTextPrimary
                    font.pointSize: 24
                }
            }
            CardSection {
                title: qsTr("Registration data")

                FormField {
                    label: qsTr("Серийный номер:")
                    placeholder: qsTr("Уникальный серийный номер оборудования")
                    settingName: "serialNumber"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("Номер кейса:")
                    placeholder: qsTr("Номер кейса для хранения оборудования")
                    settingName: "caseNumber"
                    Layout.fillWidth: true
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Label {
                        Layout.preferredWidth: 350
                        text: qsTr("Дата отгрузки:")
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSmall
                    }

                    NewDateField {
                        shipmentDate: SettingsManager.shipmentDate
                        onShipmentDateChanged: SettingsManager.shipmentDate = shipmentDate
                    }
                }
            }
            CardSection {
                title: qsTr("Main components")

                FormField {
                    label: qsTr("Преобразователь РА2.25L16 1.1х10-17:")
                    placeholder: qsTr("S/n первого преобразователя на фазированной решетке")
                    settingName: "firstPhasedArrayConverters"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("Преобразователь РА2.25L16 1.1х10-17:")
                    placeholder: qsTr("S/n второго преобразователя на фазированной решетке")
                    settingName: "secondPhasedArrayConverters"
                    Layout.fillWidth: true
                }
                FormField {
                    label: qsTr("Корпус АКБ:")
                    placeholder: qsTr("Серийный номер корпуса аккумулятора")
                    settingName: "batteryCase"
                    Layout.fillWidth: true
                }
            }

            CardSection {
                title: qsTr("Blocks and modules")

                FormField {
                    label: qsTr("Блок АОС:")
                    placeholder: qsTr("Серийный номер блока АОС")
                    settingName: "aosBlock"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("Флеш-накопитель:")
                    placeholder: qsTr("Серийный номер флеш-накопителя")
                    settingName: "flashDrive"
                    Layout.fillWidth: true
                }
                FormField {
                    label: qsTr("CO3R measure:")
                    placeholder: qsTr("Измеренное значение CO3R")
                    settingName: "coThreeRMeasure"
                    Layout.fillWidth: true
                }
            }

            CardSection {
                title: qsTr("Certification and checks")

                FormField {
                    label: qsTr("Сертификат калибровки:")
                    placeholder: qsTr("Номер сертификата калибровки")
                    settingName: "calibrationCertificate"
                    Layout.fillWidth: true
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Label {
                        Layout.preferredWidth: 350
                        text: qsTr("Дата калибровки:")
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSmall
                    }

                    NewDateField {
                        shipmentDate: SettingsManager.calibrationDate
                        onShipmentDateChanged: SettingsManager.calibrationDate = shipmentDate
                    }
                }
            }

            CardSection {
                title: qsTr("Spare parts kit")

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Label {
                        Layout.preferredWidth: 350
                        text: qsTr("Винты для планшета:")
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSmall
                    }

                    SettingCheckBox {
                        settingName: "hasTabletScrews"
                        text: qsTr("Присутствуют")
                        Layout.columnSpan: 1
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Label {
                        Layout.preferredWidth: 350
                        text: qsTr("Ethernet кабель:")
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSmall
                    }

                    SettingCheckBox {
                        settingName: "hasEthernetCable"
                        text: qsTr("Присутствует")
                        Layout.columnSpan: 1
                    }
                }

                FormField {
                    label: qsTr("Зарядное АКБ:")
                    placeholder: qsTr("Серийный номер зарядного АКБ")
                    settingName: "batteryCharger"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("Зарядное планшета:")
                    placeholder: qsTr("Серийный номер зарядного планшета")
                    settingName: "tabletCharger"
                    Layout.fillWidth: true
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Label {

                        Layout.preferredWidth: 350
                        text: qsTr("Инструментальный набор:")
                        color: Theme.colorTextPrimary
                        font.pointSize: Theme.fontSmall
                    }

                    SettingCheckBox {
                        settingName: "hasToolKit"
                        text: qsTr("Присутствует")
                        Layout.columnSpan: 1
                    }
                }
            }
            CardSection {
                title: qsTr("Additional components")

                FormField {
                    label: qsTr("Ручной наклонный преобразователь:")
                    placeholder: qsTr("Серийный номер manual inclined")
                    settingName: "manualInclined"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("Прямой преобразователь:")
                    placeholder: qsTr("Серийный номер straight")
                    settingName: "straight"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("Фото URL:")
                    placeholder: qsTr("Ссылка на фотографии")
                    settingName: "photoUrl"
                    Layout.fillWidth: true
                }
            }
            CardSection {
                title: qsTr("Inspection and documentation")

                FormField {
                    label: qsTr("Проверка ПО:")
                    placeholder: qsTr("Версия и статус ПО")
                    settingName: "softwareCheck"
                    Layout.fillWidth: true
                }

                FormField {
                    label: qsTr("Фото/видео URL:")
                    placeholder: qsTr("Ссылка на медиаматериалы")
                    settingName: "photoVideoUrl"
                    Layout.fillWidth: true
                }
                FormField {
                    label: qsTr("Вес (кг):")
                    placeholder: qsTr("Общий вес оборудования")
                    settingName: "weight"
                    Layout.fillWidth: true

                    validator: DoubleValidator {
                        bottom: 0
                        decimals: 2
                    }
                }

                FormField {
                    label: qsTr("Заметки:")
                    placeholder: qsTr("Дополнительные заметки и комментарии")
                    settingName: "notes"
                    Layout.fillWidth: true
                    multiline: true
                }
            }

            Button {
                id: button

                text: qsTr("Сохранить")
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
                Layout.minimumHeight: 20
            }
        }
        Dialog {
            id: confirmDialog
            modal: true
            title: qsTr("Подтверждение сохранения")
            standardButtons: Dialog.Ok | Dialog.Cancel
            anchors.centerIn: Overlay.overlay
            width: 400

            background: Rectangle {
                color: Theme.colorBgPrimary
                radius: 5
                border.color: Theme.colorBorder
            }
            contentItem: ColumnLayout {
                spacing: 20

                Label {
                    text: qsTr("Вы точно уверены, что хотите сохранить настройки?\nПосле сохранения некоторые из них будет уже невозможно изменить.")
                    wrapMode: Text.WordWrap
                    color: Theme.colorTextPrimary
                    Layout.fillWidth: true
                }
            }

            onAccepted: {
                root.settingsCompleted();
            }
        }
    }
}

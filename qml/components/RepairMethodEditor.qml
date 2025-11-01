import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../styles"

Rectangle {
    id: root

    property alias text: textEdit.text 
    property alias placeholderEditText: placeholderEdit.text
    property bool enabled: true

    signal textEditChanged(string text)

    Layout.fillWidth: true
    Layout.preferredHeight: 100
    color: Theme.colorNavActive
    border.color: textEdit.text ? Theme.colorAccent: Theme.colorTextLight
    border.width: 1
    radius: 4

    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.margins: 8
        contentWidth: width
        contentHeight: textEdit.implicitHeight
        clip: true

        TextEdit {
            id: textEdit
            width: flickable.width
            height: Math.max(implicitHeight, flickable.height)
            wrapMode: TextEdit.WordWrap
            font.pixelSize: 14
            selectByMouse: true
            color: Theme.colorTextPrimary
            enabled: root.enabled

            onTextChanged: {
                root.textEditChanged(text)
                    if (implicitHeight > flickable.height) {
                        Qt.callLater(function () {
                            flickable.contentY = implicitHeight - flickable.height;
                        });
                    }
                
            }
        }

        ScrollBar.vertical: ScrollBar {
            id: scrollBar
            policy: textEdit.implicitHeight > flickable.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
        }
    }

    Text {
        id: placeholderEdit
        anchors.fill: parent
        anchors.margins: 8
        color: Theme.colorTextPlaceholder
        font: textEdit.font
        verticalAlignment: Text.AlignTop
        visible: !textEdit.text
    }
}

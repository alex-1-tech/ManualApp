pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "../styles"

ComboBox {
    id: root

    property var schemaModel: []
    property string currentSchemaFile: ""
    property string currentModel: ""

    signal schemaSelected(string filePath)
    property var textFormatter: function(item) {
        var fileName = typeof item === "string" ? item : (item && item.fileName ? item.fileName : String(item));
        return SettingsManager.getSchemaTitle(root.currentModel, fileName);
    }

    model: root.schemaModel

    displayText: {
        if (!model || model.length === 0 || currentIndex < 0)
            return "Select Schema";
        var item = model[currentIndex];
        return item ? root.textFormatter(item) : "Select Schema";
    }

    currentIndex: {
        if (!model || model.length === 0)
            return -1;
        if (!root.currentSchemaFile)
            return 0;
        for (var i = 0; i < model.length; i++) {
            var item = model[i];
            var fileName = typeof item === "string" ? item : (item && item.fileName ? item.fileName : String(item));
            if (fileName === root.currentSchemaFile)
                return i;
        }
        return 0;
    }

    onCurrentIndexChanged: {
        if (currentIndex < 0 || !model || !model[currentIndex])
            return;
        var item = model[currentIndex];
        var fileName = typeof item === "string" ? item : (item && item.fileName ? item.fileName : String(item));
        if (root.currentSchemaFile === fileName)
            return;
        root.currentSchemaFile = fileName;
        root.schemaSelected(fileName);
    }

    contentItem: Text {
        text: root.displayText
        color: Theme.colorTextPrimary
        font.pointSize: Theme.fontBody
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        leftPadding: 12
        rightPadding: root.indicator.width + root.spacing
    }

    background: Rectangle {
        implicitHeight: 40
        color: Theme.colorSurface
        border.color: root.pressed || root.popup.visible
                      ? Theme.colorButtonPrimary
                      : Theme.colorBorder
        border.width: 1
        radius: 4
    }

    indicator: Canvas {
        id: arrow
        x: root.width - width - root.rightPadding
        y: root.topPadding + (root.availableHeight - height) / 2
        width: 12
        height: 8

        Connections {
            target: root
            function onPressedChanged() { arrow.requestPaint(); }
        }

        onPaint: {
            var ctx = getContext("2d");
            if (!ctx) return;
            ctx.reset();
            ctx.moveTo(0, 0);
            ctx.lineTo(width, 0);
            ctx.lineTo(width / 2, height);
            ctx.closePath();
            ctx.fillStyle = Theme.colorTextPrimary;
            ctx.fill();
        }
    }

   delegate: ItemDelegate {
        id: delegateItem
        required property var modelData
        required property int index

        width: ListView.view ? ListView.view.width : root.width
        highlighted: root.highlightedIndex === index

        contentItem: Text {
            text: delegateItem.modelData === undefined || delegateItem.modelData === null
                  ? ""
                  : root.textFormatter(delegateItem.modelData)
            color: delegateItem.highlighted ? "white" : Theme.colorTextPrimary
            font.pointSize: Theme.fontBody
            verticalAlignment: Text.AlignVCenter
            leftPadding: 12
        }

        background: Rectangle {
            color: delegateItem.highlighted ? Theme.colorButtonPrimary : Theme.colorSurface
        }
    }

    popup: Popup {
        y: root.height + 2
        width: root.width
        implicitHeight: Math.min(contentItem.implicitHeight, 300)
        padding: 1

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: root.popup.visible ? root.delegateModel : null
            currentIndex: root.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator {}
        }

        background: Rectangle {
            color: Theme.colorSurface
            border.color: Theme.colorBorder
            radius: 4
        }
    }
}
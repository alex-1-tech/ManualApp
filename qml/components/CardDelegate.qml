pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../styles"

Frame {
    id: root

    property string key: ""
    property string title: ""
    property string freqHint: ""
    property int count: 0
    property string lastDate: ""
    property var datesStr: []
    property var datesIso: []
    property string nextTO: ""
    property int interval: 0

    signal reportRequested(string categoryKey, string dateIso)

    width: ListView.view ? ListView.view.width - 2 : 600
    leftPadding: 16
    rightPadding: 16
    topPadding: 12
    bottomPadding: 12

    background: Rectangle {
        radius: Theme.radiusCard
        color: Theme.colorBgMuted
        border.color: Theme.colorBorder
        border.width: 1
    }

    Accessible.name: title + " — " + count + " records"

    function parseToArray(x) {
        if (!x)
            return [];
        if (Array.isArray(x))
            return x.slice();
        if (typeof x === "string") {
            try {
                var parsed = JSON.parse(x);
                return Array.isArray(parsed) ? parsed : Object.values(parsed);
            } catch (e) {
                return [];
            }
        }
        var out = [];
        try {
            for (var i = 0; i < x.length; ++i)
                out.push(x[i]);
        } catch (e) {}
        return out;
    }

    property var datesStrArray: parseToArray(datesStr)
    property var datesIsoArray: parseToArray(datesIso)

    onDatesStrChanged: datesStrArray = parseToArray(datesStr)
    onDatesIsoChanged: datesIsoArray = parseToArray(datesIso)

    property color nextTOColor: (nextTO.indexOf("Overdue") !== -1) ? Theme.colorError : (nextTO.indexOf("Today") !== -1) ? Theme.colorSuccess : Theme.colorAccent

    ColumnLayout {
        width: parent.width
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Label {
                text: root.title
                font.pixelSize: Theme.fontSubtitle
                font.bold: true
                color: Theme.colorTextPrimary
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Rectangle {
                radius: Theme.radiusPill
                color: Theme.colorPillBg
                implicitHeight: 26
                implicitWidth: countLabel.implicitWidth + 16
                Label {
                    id: countLabel
                    anchors.centerIn: parent
                    text: root.count
                    font.pixelSize: Theme.fontBody
                    color: Theme.colorPillText
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Label {
                text: root.freqHint
                font.pixelSize: Theme.fontBody
                color: Theme.colorTextSecondary
            }

            Label {
                text: "Next: " + root.nextTO
                font.pixelSize: Theme.fontBody
                color: root.nextTOColor
                font.bold: root.nextTO.indexOf("Overdue") !== -1 || root.nextTO.indexOf("Today") !== -1
            }
        }

        Label {
            text: "Last: " + root.lastDate
            font.pixelSize: Theme.fontBody
            color: Theme.colorTextMuted
        }

        Flow {
            Layout.fillWidth: true
            spacing: 8
            visible: root.datesStrArray && root.datesStrArray.length > 0

            Repeater {
                model: root.datesStrArray
                delegate: Button {
                    id: control
                    required property int index
                    required property var modelData

                    text: modelData
                    font.pixelSize: Theme.fontBody
                    padding: 8
                    hoverEnabled: true
                    Accessible.name: "Report for " + text

                    contentItem: Label {
                        text: control.text
                        font.pixelSize: Theme.fontBody
                        color: control.down || control.checked || parent.activeFocus ? Theme.colorTextPrimary : Theme.colorTextPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    background: Rectangle {
                        implicitHeight: 30
                        radius: Theme.radiusPill
                        border.width: 1
                        border.color: parent.activeFocus ? Theme.colorAccent : (control.hovered ? Theme.colorBorderHover : Theme.colorBorderLight)
                        color: control.down || control.checked || parent.activeFocus ? Theme.colorAccent : Theme.colorBgMuted
                    }

                    ToolTip.visible: hovered
                    ToolTip.text: "Open report for " + text

                    focusPolicy: Qt.StrongFocus

                    onClicked: {
                        var iso = (root.datesIsoArray && root.datesIsoArray.length > index) ? root.datesIsoArray[index] : "";
                        root.reportRequested(root.key, iso);
                    }
                }
            }
        }

        Label {
            visible: !root.datesStrArray || root.datesStrArray.length === 0
            text: "No records for selected filter"
            font.pixelSize: Theme.fontBody
            color: Theme.colorTextLight
            font.italic: true
        }
    }
}

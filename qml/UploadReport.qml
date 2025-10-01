import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import QtQuick.Dialogs
import QtQuick.Window 2.15
import "styles"

ColumnLayout {
    id: root

    spacing: 5

    property string selectedFolderPath: ""
    property bool isProcessing: false
    property string mode

    property var stackView
    property var toSelectionScreen

    function createArchiveFromFolder() {
        folderDialog.open();
    }

    function proceedToCreateArchive() {
        if (selectedFolderPath === "") {
            console.warn("Folder not selected");
            return;
        }

        isProcessing = true;

        var timer = Qt.createQmlObject('import QtQuick 2.0; Timer {}', parent);
        timer.interval = 50;
        timer.repeat = false;
        timer.triggered.connect(function () {
            var success = DataManager.createArchive(selectedFolderPath, mode); // Pass mode
            isProcessing = false;

            if (success) {
                if (mode == "before") {
                    stackView.push("Services.qml", {
                        stackView: stackView,
                        toSelectionScreen: toSelectionScreen
                    }, StackView.Immediate);
                } else {
                    stackView.push("UploadWindow.qml", {
                        stackView: stackView
                    }, StackView.Immediate);
                }
            }

            timer.destroy();
        });
        timer.start();
    }

    FolderDialog {
        id: folderDialog
        title: root.mode === "before" ? "Select folder with BEFORE maintenance recording" : "Select folder with AFTER maintenance recording"
        onAccepted: {
            var selectedPath = selectedFolder.toString();
            if (Qt.platform.os === "windows") {
                root.selectedFolderPath = selectedPath.replace("file:///", "");
            } else {
                root.selectedFolderPath = selectedPath.replace("file://", "/");
            }
        }
    }

    Dialog {
        id: errorDialog
        title: "Error"
        modal: true
        standardButtons: Dialog.Ok
        property string text: ""
        Label {
            text: errorDialog.text
        }
    }

    BusyIndicator {
        id: busyIndicator
        running: root.isProcessing
        Layout.alignment: Qt.AlignHCenter
        visible: root.isProcessing
    }

    Column {
        spacing: 10
        Layout.alignment: Qt.AlignHCenter

        visible: !root.isProcessing

        Text {
            text: root.mode === "before" ? "Upload reference rail recording (BEFORE maintenance)" : "Upload reference rail recording (AFTER maintenance)"
            font.pixelSize: 24
            color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: qsTr("(select folder with measurements)")
            font.pixelSize: 18
            color: Theme.colorTextPlaceholder
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button {
            text: "Select recording"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: root.createArchiveFromFolder()
        }

        Text {
            visible: root.selectedFolderPath !== ""
            text: "Selected: " + root.selectedFolderPath
            color: Theme.colorSuccess
            font.pixelSize: 16
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button {
            visible: root.selectedFolderPath !== ""
            text: root.mode === "before" ? "Proceed to maintenance" : "Complete maintenance"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: root.proceedToCreateArchive()
        }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Cancel")

            onClicked: {
                if (root.mode == "before") {
                    DataManager.revoke();
                    root.stackView.clear();
                    root.stackView.push(root.toSelectionScreen);
                } else {
                    root.stackView.pop(StackView.Immediate);
                }
            }
        }
    }

    Text {
        visible: DataManager.error && DataManager.error.length > 0
        text: DataManager.error || ""
        color: Theme.colorError
        font.pixelSize: 14
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        Layout.fillWidth: true
    }
}
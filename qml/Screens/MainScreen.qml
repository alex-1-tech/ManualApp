import QtQuick 2.15
import QtQuick.Controls 2.15
import ManualApp.Core 1.0

Item {

    StackView {
        id: stackView

        anchors.fill: parent
        initialItem: toSelectionScreen
    }

    Component {
        id: toSelectionScreen

        TOSelectionScreen {
            onToSelected: function (file) {
                DataManager.setStartTime(Qt.formatDateTime(new Date(), "ddMMyyyy_hhmm"));
                DataManager.save(true);
                if (DataManager.load(":/media/jsons/" + file))
                    stackView.push("ServicesScreen.qml");
            }
        }
    }
}

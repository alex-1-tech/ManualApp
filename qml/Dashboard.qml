pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import ManualAppCorePlugin 1.0

Item {

    StackView {
        id: stackView

        anchors.fill: parent
        initialItem: toSelectionScreen
    }

    Component {
        id: toSelectionScreen

        SelectTO {
            onToSelected: function (file, numberTO) {
                DataManager.setStartTime(Qt.formatDateTime(new Date(), "yyyy-MM-dd"));
                DataManager.setCurrentNumberTO(numberTO);
                DataManager.save(true);
                if (DataManager.load(":/media/jsons/" + file))
                    if(numberTO == "TO-2"){
                        stackView.push("UploadReport.qml", {
                            mode: "before",
                            stackView: stackView,
                            toSelectionScreen: toSelectionScreen
                        }, StackView.Immediate);
                    } else {
                        stackView.push("Services.qml", {
                            stackView: stackView,
                            toSelectionScreen: toSelectionScreen
                        }, StackView.Immediate);
                    }
            }
        }
    }
}

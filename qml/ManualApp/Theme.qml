pragma Singleton
import QtQuick

QtObject {
    readonly property color textColor: "#333333"
    readonly property color buttonNormal: "#4a86e8"
    readonly property color buttonPressed: "#3a6ea5"
    readonly property color buttonText: "#ffffff"
    readonly property color borderColor: "#2e5cb8"

    readonly property font headerFont: Qt.font({
        family: "Arial",
        pixelSize: 48,
        bold: true
    })
    
    readonly property font titleFont: Qt.font({
        family: "Arial",
        pixelSize: 36,
        bold: true
    })
    
    readonly property font buttonFont: Qt.font({
        family: "Arial",
        pixelSize: 22,
        bold: true
    })
    
    readonly property font infoFont: Qt.font({
        family: "Arial",
        pixelSize: 24
    })
}
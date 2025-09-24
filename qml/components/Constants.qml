import QtQuick 2.15

QtObject {
    id: constants

    readonly property var categoryOrder: ({
            "TO-1": 1,
            "TO-2": 2,
            "TO-3": 3
        })
    readonly property var titlesMap: ({
            "TO-1": "Daily Maintenance",
            "TO-2": "Monthly Maintenance",
            "TO-3": "Semi-Annual Maintenance"
        })
    readonly property var freqMap: ({
            "TO-1": "every day",
            "TO-2": "every month",
            "TO-3": "every six months"
        })
    readonly property var intervals: ({
            "TO-1": 1,
            "TO-2": 30,
            "TO-3": 180
        })
}
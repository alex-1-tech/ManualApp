function getStatusText(status) {
    switch (status) {
        case 0:
            return qsTr("Not started");
        case 1:
            return qsTr("Completed");
        case 2:
            return qsTr("Damage found");
        case 3:
            return qsTr("Skipped");
        default:
            return qsTr("Unknown");
    }
}

function getFixStatusText(fixStatus) {
    switch (fixStatus) {
        case 0:
            return qsTr("Fixed");
        case 1:
            return qsTr("Postponed");
        case 2:
            return qsTr("Not required");
        case 3:
            return qsTr("Not fixed");
        default:
            return qsTr("Unknown");
    }
}
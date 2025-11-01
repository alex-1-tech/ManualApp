pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import "utils/DateUtils.js" as DateUtils
import "components"
import "styles"

Item {
    id: root
    width: 640
    height: 480

    // Connect theme
    property Constants constants: Constants {}

    // ====== State ===========================================================
    property var rawData: ({})
    property var normalized: ([])
    property date filterDate: new Date()
    property int filterYear: new Date().getFullYear()
    property int filterMonth: new Date().getMonth() + 1

    // backing ListModel for dayCombo so we can rebuild when month/year changes
    ListModel {
        id: dayModel
    }

    // ====== Helpers =========================================================
    function mapTitle(k) {
        return constants.titlesMap[k] || k;
    }
    function mapFreq(k) {
        return constants.freqMap[k] || "";
    }
    function calculateNextTO(lastDate, intervalDays) {
        if (!lastDate)
            return "Today";
        var nextDate = new Date(lastDate);
        nextDate.setDate(nextDate.getDate() + intervalDays);
        var today = new Date();
        today.setHours(0, 0, 0, 0);
        nextDate.setHours(0, 0, 0, 0);
        var diffDays = Math.ceil((nextDate - today) / (1000 * 60 * 60 * 24));
        if (diffDays === 0)
            return "Today";
        if (diffDays === 1)
            return "Tomorrow";
        if (diffDays > 0)
            return "In " + diffDays + " days";
        return "Overdue by " + Math.abs(diffDays) + " days";
    }

    function normalizeData(obj) {
        const out = [];
        const keys = ["TO-1", "TO-2", "TO-3"];
        for (var i = 0; i < keys.length; ++i) {
            const k = keys[i];
            const arr = (obj && obj[k]) ? obj[k].slice(0) : [];
            const dates = arr.map(function (iso) {
                return new Date(iso + "T00:00:00");
            }).sort(function (a, b) {
                return b - a;
            });
            const datesStr = dates.map(function (d) {
                return DateUtils.fmtDate(d);
            });
            const lastDate = dates.length ? dates[0] : null;

            // Filter by selected date
            var filteredDates = dates.filter(function (d) {
                return DateUtils.isSameDate(d, filterDate);
            });
            var filteredDatesStr = filteredDates.map(DateUtils.fmtDate);

            out.push({
                key: k,
                title: mapTitle(k),
                freqHint: mapFreq(k),
                count: filteredDates.length,
                dates: filteredDates,
                datesStr: filteredDatesStr,
                lastDate: lastDate,
                nextTO: calculateNextTO(lastDate, constants.intervals[k]),
                interval: constants.intervals[k]
            });
        }

        out.sort(function (a, b) {
            var ao = constants.categoryOrder[a.key] || 0;
            var bo = constants.categoryOrder[b.key] || 0;
            if (ao !== bo) {
                return ao - bo;
            }
            var at = a.lastDate ? a.lastDate.getTime() : 0;
            var bt = b.lastDate ? b.lastDate.getTime() : 0;
            return bt - at;
        });

        return out;
    }

    function rebuildModelFromNormalized() {
        performedTOModel.clear();
        for (var i = 0; i < normalized.length; ++i) {
            const rec = normalized[i];
            performedTOModel.append({
                key: rec.key,
                title: rec.title,
                freqHint: rec.freqHint,
                count: rec.count,
                lastDate: rec.lastDate ? DateUtils.fmtDate(rec.lastDate) : "Never performed",
                datesStr: JSON.stringify(rec.datesStr || []),
                datesIso: JSON.stringify(rec.dates.map(DateUtils.toIso) || []),
                nextTO: rec.nextTO,
                interval: rec.interval
            });
        }
    }

    function openReport(categoryKey, dateIso) {
        var filePath = DataManager.findReportPdf(categoryKey, dateIso);
        if (filePath && filePath.length > 0) {
            var url;
            if (Qt.platform.os === "windows") {
                url = encodeURI(filePath.replace(/\\/g, "/"));
            } else {
                url = "file://" + encodeURI(filePath.replace(/\\/g, "/"));
            }
            Qt.openUrlExternally(url);
        } else {
            console.warn("Report PDF not found:", categoryKey, dateIso);
        }
    }
    function totalCount() {
        return normalized.reduce((s, rec) => s + rec.count, 0);
    }
    function applyFilter() {
        normalized = normalizeData(rawData);
        rebuildModelFromNormalized();
    }

    function rebuildDays() {
        if (!dayCombo || !monthCombo || !yearSpin)
            return;

        var y = yearSpin.value;
        var m = monthCombo.currentIndex;
        var currentDay = dayCombo.currentIndex + 1;

        var days = new Date(y, m + 1, 0).getDate();
        dayModel.clear();
        for (var i = 1; i <= days; ++i) {
            dayModel.append({
                text: i.toString().padStart(2, '0')
            });
        }

        var newDay = Math.min(currentDay, days);
        dayCombo.currentIndex = newDay - 1;
    }

    function updateDateFromControls() {
        if (!dayCombo || !monthCombo || !yearSpin)
            return;

        var day = parseInt(dayModel.get(dayCombo.currentIndex).text);
        var month = monthCombo.currentIndex;
        var year = yearSpin.value;

        root.filterDate = new Date(year, month, day);
        root.filterYear = year;
        root.filterMonth = month + 1;

        root.applyFilter();
    }

    Component.onCompleted: {
        root.filterDate = new Date();
        root.filterYear = root.filterDate.getFullYear();
        root.filterMonth = root.filterDate.getMonth() + 1;

        rebuildDays();
        monthCombo.currentIndex = root.filterDate.getMonth();
        yearSpin.value = root.filterDate.getFullYear();
        dayCombo.currentIndex = root.filterDate.getDate() - 1;

        rawData = DataManager.performedTOsNew();
        applyFilter();
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 50
            spacing: 12

            Label {
                text: "Performed Maintenance"
                font.pixelSize: Theme.fontTitle
                font.bold: true
                color: Theme.colorTextPrimary
                Layout.alignment: Qt.AlignVCenter
            }

            Item {
                Layout.fillWidth: true
            }

            Label {
                id: totalLabel
                text: "Total records: " + root.totalCount()
                font.pixelSize: Theme.fontBody
                color: Theme.colorTextPrimary
                Accessible.role: Accessible.StaticText
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            ComboBox {
                id: dayCombo
                Layout.preferredWidth: 80
                font.pixelSize: Theme.fontBody
                model: dayModel
                currentIndex: root.filterDate.getDate() - 1
                onActivated: root.updateDateFromControls()
            }

            ComboBox {
                id: monthCombo
                Layout.preferredWidth: 140
                font.pixelSize: Theme.fontBody
                model: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
                currentIndex: root.filterDate.getMonth()
                onActivated: {
                    root.rebuildDays();
                    root.updateDateFromControls();
                }
            }

            SpinBox {
                id: yearSpin
                Layout.preferredWidth: 200
                font.pixelSize: Theme.fontBody
                from: 2000
                to: 2100
                value: root.filterDate.getFullYear()
                onValueChanged: {
                    if (value !== root.filterYear) {
                        root.rebuildDays();
                        root.updateDateFromControls();
                    }
                }
            }

            Button {
                text: "Reset"
                onClicked: {
                    root.filterDate = new Date();
                    root.filterYear = root.filterDate.getFullYear();
                    root.filterMonth = root.filterDate.getMonth() + 1;

                    monthCombo.currentIndex = root.filterDate.getMonth();
                    yearSpin.value = root.filterDate.getFullYear();
                    root.rebuildDays();
                    dayCombo.currentIndex = root.filterDate.getDate() - 1;

                    root.applyFilter();
                }
            }
        }

        Loader {
            Layout.fillWidth: true
            Layout.fillHeight: true
            active: root.totalCount() > 0
            sourceComponent: contentComp
        }

        Label {
            visible: root.totalCount() === 0
            text: "No performed maintenance for selected filter"
            font.pixelSize: Theme.fontSubtitle
            color: Theme.colorTextMuted
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
    ListModel {
        id: performedTOModel
    }

    Component {
        id: contentComp
        ScrollView {
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ListView {
                id: list
                width: parent.width
                height: parent.height
                spacing: 12
                clip: true
                model: performedTOModel
                boundsBehavior: Flickable.StopAtBounds
                reuseItems: true
                interactive: contentHeight > height
                keyNavigationEnabled: true

                delegate: Item {
                    id: delegateItem
                    required property var modelData

                    width: ListView.view.width
                    height: cardDelegate.height

                    CardDelegate {
                        id: cardDelegate
                        width: parent.width
                        key: delegateItem.modelData.key
                        title: delegateItem.modelData.title
                        freqHint: delegateItem.modelData.freqHint
                        count: delegateItem.modelData.count
                        lastDate: delegateItem.modelData.lastDate
                        datesStr: delegateItem.modelData.datesStr
                        datesIso: delegateItem.modelData.datesIso
                        nextTO: delegateItem.modelData.nextTO
                        interval: delegateItem.modelData.interval

                        onReportRequested: (categoryKey, dateIso) => root.openReport(categoryKey, dateIso)
                    }
                }
            }
        }
    }
}

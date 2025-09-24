import QtQuick 2.15
import "styles"

Item {
    id: root

    Rectangle {
        id: sidebar
        color: Theme.colorSidebar
        width: 220
        height: parent.height
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        y: 60

        Row {
            x: 5
            spacing: 5
            Image {
                id: logo
                source: "qrc:///media/icons/app.png"
                width: 50
                height: 50
                y: 5
                mipmap: true
            }
            Text {
                color: Theme.colorTextPrimary
                text: qsTr("Maintence")
                font.pointSize: 22
                y: 10
            }
        }

        Rectangle {
            id: navDashboard
            color: Theme.colorNavActive
            width: parent.width
            height: 40
            y: 60

            Image {
                source: "qrc:///media/icons/icon-dashboard.svg"
                height: 20
                width: 20
                x: 20
                y: 10
            }

            Text {
                color: Theme.colorTextPrimary
                text: qsTr("Dashboard")
                font.pointSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            MouseArea {
                id: mouseAreaDashboard
                width: parent.width
                height: parent.height

                onClicked: function () {
                    navSettings.color = Theme.colorNavInactive;
                    navAbout.color = Theme.colorNavInactive;
                    navReports.color = Theme.colorNavInactive;
                    navDashboard.color = Theme.colorNavActive;
                    
                    dashboardLoader.visible = true;
                    reportsLoader.visible = false;
                    settingsLoader.visible = false;
                    aboutLoader.visible = false;
                }
            }
        }

        Rectangle {
            id: navReports
            color: Theme.colorNavInactive
            width: parent.width
            height: 40
            y: 105

            Image {
                source: "qrc:///media/icons/icon-reports.svg"
                height: 20
                width: 20
                x: 20
                y: 10
            }

            Text {
                color: Theme.colorTextPrimary
                text: qsTr("Reports")
                font.pointSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            MouseArea {
                id: mouseAreaReports
                width: parent.width
                height: parent.height

                onClicked: function () {
                    navSettings.color = Theme.colorNavInactive;
                    navAbout.color = Theme.colorNavInactive;
                    navReports.color = Theme.colorNavActive;
                    navDashboard.color = Theme.colorNavInactive;
                    
                    dashboardLoader.visible = false;

                    settingsLoader.visible = false;
                    aboutLoader.visible = false;
                    
                    reportsLoader.active = false;
                    reportsLoader.visible = true;
                    reportsLoader.active = true;
                }
            }
        }

        Rectangle {
            id: navSettings
            color: Theme.colorNavInactive
            width: parent.width
            height: 40
            y: 150

            Image {
                source: "qrc:///media/icons/icon-settings.svg"
                height: 20
                width: 20
                x: 20
                y: 10
            }

            Text {
                color: Theme.colorTextPrimary
                text: qsTr("Settings")
                font.pointSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            MouseArea {
                id: mouseAreaSettings
                width: parent.width
                height: parent.height

                onClicked: function () {
                    navSettings.color = Theme.colorNavActive;
                    navAbout.color = Theme.colorNavInactive;
                    navReports.color = Theme.colorNavInactive;
                    navDashboard.color = Theme.colorNavInactive;
                    
                    dashboardLoader.visible = false;
                    reportsLoader.visible = false;
                    settingsLoader.visible = true;
                    aboutLoader.visible = false;
                }
            }
        }

        Rectangle {
            id: navAbout
            color: Theme.colorNavInactive
            width: parent.width
            height: 40
            y: 195

            Image {
                source: "qrc:///media/icons/icon-about.svg"
                height: 20
                width: 20
                x: 20
                y: 10
            }

            Text {
                color: Theme.colorTextPrimary
                text: qsTr("About")
                font.pointSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            MouseArea {
                id: mouseAreaAbout
                width: parent.width
                height: parent.height

                onClicked: function () {
                    navSettings.color = Theme.colorNavInactive;
                    navAbout.color = Theme.colorNavActive;
                    navReports.color = Theme.colorNavInactive;
                    navDashboard.color = Theme.colorNavInactive;
                    
                    dashboardLoader.visible = false;
                    reportsLoader.visible = false;
                    settingsLoader.visible = false;
                    aboutLoader.visible = true;
                }
            }
        }
    }

    Rectangle {
        id: content
        color: Theme.colorBgPrimary
        width: parent.width - 220
        height: parent.height
        anchors.left: sidebar.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        Loader {
            id: dashboardLoader
            anchors.fill: parent
            source: "Dashboard.qml"
            active: true
            visible: true
        }

        Loader {
            id: reportsLoader
            anchors.fill: parent
            source: "Reports.qml"
            active: true
            visible: false
        }

        Loader {
            id: settingsLoader
            anchors.fill: parent
            source: "Settings.qml"
            active: true
            visible: false
        }

        Loader {
            id: aboutLoader
            anchors.fill: parent
            source: "About.qml"
            active: true
            visible: false
        }
    }
}
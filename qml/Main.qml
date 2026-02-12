import QtQuick 2.15
import "styles"

Item {
    id: root

    property bool isSidebarVisible: false

    Rectangle {
        id: overlay
        anchors.fill: parent
        color: "#80000000"
        visible: false
        opacity: 0
        z: 1

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.hideSidebar()
            }
        }
    }

    function toggleSidebar() {
        if (isSidebarVisible) {
            hideSidebar()
        } else {
            showSidebar()
        }
    }

    function showSidebar() {
        isSidebarVisible = true
        overlay.visible = true
        overlay.opacity = 1
    }

    function hideSidebar() {
        isSidebarVisible = false
        overlay.opacity = 0
        overlay.visible = false
    }

    Rectangle {
        id: sidebar
        color: Theme.colorSidebar
        width: 220
        height: parent.height
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        x: root.isSidebarVisible ? 0 : -width
        Behavior on x {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        z: 2

        Row {
            x: 5
            spacing: 5
            Image {
                id: logo
                source: "qrc:///media/icons/logo.png"
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
                    navInstallPO.color = Theme.colorNavInactive;
                    navDashboard.color = Theme.colorNavActive;

                    dashboardLoader.visible = true;
                    reportsLoader.visible = false;
                    settingsLoader.visible = false;
                    aboutLoader.visible = false;
                    installPoLoader.visible = false;

                    root.hideSidebar()
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
                    navInstallPO.color = Theme.colorNavInactive;

                    dashboardLoader.visible = false;
                    settingsLoader.visible = false;
                    aboutLoader.visible = false;
                    installPoLoader.visible = false;

                    reportsLoader.active = false;
                    reportsLoader.visible = true;
                    reportsLoader.active = true;

                    root.hideSidebar()
                }
            }
        }

        Rectangle {
            id: navInstallPO
            color: Theme.colorNavInactive
            width: parent.width
            height: 40
            y: 150

            Image {
                source: "qrc:///media/icons/icon-servers.svg"
                height: 20
                width: 20
                x: 20
                y: 10
            }

            Text {
                color: Theme.colorTextPrimary
                text: qsTr("Software")
                font.pointSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            MouseArea {
                id: mouseAreaInstallPO
                width: parent.width
                height: parent.height

                onClicked: function () {
                    navSettings.color = Theme.colorNavInactive;
                    navAbout.color = Theme.colorNavInactive;
                    navReports.color = Theme.colorNavInactive;
                    navDashboard.color = Theme.colorNavInactive;
                    navInstallPO.color = Theme.colorNavActive;

                    dashboardLoader.visible = false;
                    reportsLoader.visible = false;
                    settingsLoader.visible = false;
                    aboutLoader.visible = false;

                    installPoLoader.active = false;
                    installPoLoader.visible = true;
                    installPoLoader.active = true;

                    root.hideSidebar()
                }
            }
        }

        Rectangle {
            id: navSettings
            color: Theme.colorNavInactive
            width: parent.width
            height: 40
            y: 195

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
                    navInstallPO.color = Theme.colorNavInactive;

                    dashboardLoader.visible = false;
                    reportsLoader.visible = false;
                    installPoLoader.visible = false;
                    aboutLoader.visible = false;

                    settingsLoader.active = false;
                    settingsLoader.visible = true;
                    settingsLoader.active = true;

                    root.hideSidebar()
                }
            }
        }

        Rectangle {
            id: navAbout
            color: Theme.colorNavInactive
            width: parent.width
            height: 40
            y: 240

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
                    navInstallPO.color = Theme.colorNavInactive;

                    dashboardLoader.visible = false;
                    reportsLoader.visible = false;
                    settingsLoader.visible = false;
                    installPoLoader.visible = false;

                    aboutLoader.active = false;
                    aboutLoader.visible = true;
                    aboutLoader.active = true;

                    root.hideSidebar()
                }
            }
        }
    }

    Rectangle {
        id: content
        color: Theme.colorBgPrimary
        width: parent.width
        height: parent.height
        anchors.fill: parent

        Rectangle {
            id: menuButton
            width: 40
            height: 40
            radius: 20
            color: Theme.colorSidebar
            visible: true
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: 10
            z: 3

            Row {
                anchors.centerIn: parent
                spacing: 2
                Repeater {
                    model: 3
                    Rectangle {
                        width: 4
                        height: 4
                        radius: 2
                        color: Theme.colorTextPrimary
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.toggleSidebar()
                }
            }
        }

        Loader {
            id: dashboardLoader
            anchors.fill: parent
            source: "Dashboard.qml"
            active: true
            visible: false
        }

        Loader {
            id: reportsLoader
            anchors.fill: parent
            source: "Reports.qml"
            active: true
            visible: false
        }

        Loader {
            id: installPoLoader
            anchors.fill: parent
            source: "InstallPO.qml"
            active: true
            visible: true
        }

        Loader {
            id: settingsLoader
            anchors.fill: parent
            source: "Settings.qml"
            active: false
            visible: false
        }

        Loader {
            id: aboutLoader
            anchors.fill: parent
            source: "About.qml"
            active: false
            visible: false
        }
    }
}
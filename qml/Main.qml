import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ManualAppCorePlugin 1.0
import QtQuick.Window 2.15
import "styles"

Item {
    id: root

    property bool isSidebarVisible: false

    Dialog {
    id: adminDialog
    modal: true
    focus: true
    width: 400
    height: 370
    anchors.centerIn: Overlay.overlay

    property bool isError: false

    onOpened: {
        passwordField.text = "";
        isError = false;
        passwordField.forceActiveFocus();
    }

    background: Rectangle {
        color: Theme.colorBgPrimary
        radius: 8
        border.color: Theme.colorBorder
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        Text {
            text: qsTr("Admin Access")
            font.pointSize: Theme.fontSubtitle
            font.bold: true
            color: Theme.colorTextPrimary
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            Layout.preferredWidth: 60
            Layout.preferredHeight: 60
            Layout.alignment: Qt.AlignHCenter
            radius: 30
            color: Theme.colorBgMuted

            Text {
                anchors.centerIn: parent
                text: "🔒"
                font.pointSize: 28
            }
        }

        ColumnLayout {
            spacing: 8
            Layout.fillWidth: true

            Text {
                text: qsTr("Enter password to access admin features")
                color: Theme.colorTextSecondary
                font.pointSize: Theme.fontSmall
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            TextField {
                id: passwordField
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                echoMode: TextInput.Password
                placeholderText: qsTr("Password")
                color: Theme.colorTextPrimary
                font.pointSize: Theme.fontBody
                verticalAlignment: Text.AlignVCenter
                focus: true

                background: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 45
                    color: Theme.colorBgPrimary
                    border.color: adminDialog.isError ? Theme.colorError : Theme.colorBorder
                    border.width: 1
                    radius: 6
                }

                Keys.onReturnPressed: adminDialog.submitPassword()
            }

            Text {
                visible: adminDialog.isError
                text: qsTr("Invalid password")
                color: Theme.colorError
                font.pointSize: Theme.fontSmall
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
        }

        RowLayout {
            spacing: 12
            Layout.fillWidth: true

            Button {
                id: cancelButton
                text: qsTr("Cancel")
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                background: Rectangle {
                    color: cancelButton.down ? Theme.colorButtonSecondaryHover : Theme.colorButtonSecondary
                    radius: Theme.radiusButton
                }

                contentItem: Text {
                    text: cancelButton.text
                    color: Theme.colorTextPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: Theme.fontSmall
                }

                onClicked: {
                    adminDialog.close();
                }
            }

            Button {
                id: loginButton
                text: qsTr("Login")
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                background: Rectangle {
                    color: loginButton.down ? Theme.colorButtonPrimaryHover : Theme.colorButtonPrimary
                    radius: Theme.radiusButton
                }

                contentItem: Text {
                    text: loginButton.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: Theme.fontSmall
                    font.bold: true
                }

                onClicked: adminDialog.submitPassword()
            }
        }
    }

    function submitPassword() {
        if (AdminManager.verifyPassword(passwordField.text)) {
            close();
            adminActivatedNotification.show();
        } else {
            isError = true;
            passwordField.text = "";
            passwordField.forceActiveFocus();
        }
    }
}

Rectangle {
    id: adminActivatedNotification
    anchors.centerIn: parent
    width: 220
    height: 50
    color: Theme.colorSuccess
    radius: 8
    opacity: 0
    z: 1000

    Text {
        anchors.centerIn: parent
        text: qsTr("Admin Mode Activated")
        color: "white"
        font.bold: true
        font.pointSize: Theme.fontSmall
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 300
        }
    }

    function show() {
        opacity = 1;
        hideTimer.start();
    }

    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: adminActivatedNotification.opacity = 0
    }
}

Connections {
    target: AdminManager

    function onShowPasswordDialog() {
        adminDialog.open();
    }
}

    Rectangle {
        id: overlay
        anchors.fill: parent
        color: "#80000000"
        visible: false
        opacity: 0
        z: 1

        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.hideSidebar();
            }
        }
    }

    function toggleSidebar() {
        if (isSidebarVisible) {
            hideSidebar();
        } else {
            showSidebar();
        }
    }

    function showSidebar() {
        isSidebarVisible = true;
        overlay.visible = true;
        overlay.opacity = 1;
    }

    function hideSidebar() {
        isSidebarVisible = false;
        overlay.opacity = 0;
        overlay.visible = false;
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
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
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

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        AdminManager.registerClick();
                    }
                }
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
            color: Theme.colorNavInactive
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
                    navActivate.color = Theme.colorNavInactive;
                    navAdmin.color = Theme.colorNavInactive;
                    navDashboard.color = Theme.colorNavActive;

                    dashboardLoader.visible = true;
                    reportsLoader.visible = false;
                    settingsLoader.visible = false;
                    aboutLoader.visible = false;
                    activateLoader.visible = false;
                    installPoLoader.visible = false;
                    adminLoader.visible = false;

                    root.hideSidebar();
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
                    navActivate.color = Theme.colorNavInactive;
                    navAdmin.color = Theme.colorNavInactive;

                    dashboardLoader.visible = false;
                    settingsLoader.visible = false;
                    aboutLoader.visible = false;
                    installPoLoader.visible = false;
                    activateLoader.visible = false;
                    adminLoader.visible = false;

                    reportsLoader.active = false;
                    reportsLoader.visible = true;
                    reportsLoader.active = true;

                    root.hideSidebar();
                }
            }
        }

        Rectangle {
            id: navInstallPO
            color: Theme.colorNavActive
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
                    navActivate.color = Theme.colorNavInactive;
                    navAdmin.color = Theme.colorNavInactive;

                    dashboardLoader.visible = false;
                    reportsLoader.visible = false;
                    settingsLoader.visible = false;
                    aboutLoader.visible = false;
                    activateLoader.visible = false;
                    adminLoader.visible = false;

                    installPoLoader.active = false;
                    installPoLoader.visible = true;
                    installPoLoader.active = true;

                    root.hideSidebar();
                }
            }
        }

        Rectangle {
            id: navActivate
            color: Theme.colorNavInactive
            width: parent.width
            height: 40
            y: 195

            Image {
                source: "qrc:///media/icons/icon-activate.svg"
                height: 20
                width: 20
                x: 20
                y: 10
            }

            Text {
                color: Theme.colorTextPrimary
                text: qsTr("Activate")
                font.pointSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            MouseArea {
                id: mouseAreaActivate
                width: parent.width
                height: parent.height

                onClicked: function () {
                    navSettings.color = Theme.colorNavInactive;
                    navAbout.color = Theme.colorNavInactive;
                    navReports.color = Theme.colorNavInactive;
                    navDashboard.color = Theme.colorNavInactive;
                    navInstallPO.color = Theme.colorNavInactive;
                    navActivate.color = Theme.colorNavActive;
                    navAdmin.color = Theme.colorNavInactive;

                    dashboardLoader.visible = false;
                    reportsLoader.visible = false;
                    settingsLoader.visible = false;
                    aboutLoader.visible = false;
                    installPoLoader.visible = false;
                    adminLoader.visible = false;

                    activateLoader.active = false;
                    activateLoader.visible = true;
                    activateLoader.active = true;

                    root.hideSidebar();
                }
            }
        }

        Rectangle {
            id: navSettings
            color: Theme.colorNavInactive
            width: parent.width
            height: 40
            y: 240

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
                    navActivate.color = Theme.colorNavInactive;
                    navAdmin.color = Theme.colorNavInactive;

                    dashboardLoader.visible = false;
                    reportsLoader.visible = false;
                    installPoLoader.visible = false;
                    aboutLoader.visible = false;
                    activateLoader.visible = false;
                    adminLoader.visible = false;

                    settingsLoader.active = false;
                    settingsLoader.visible = true;
                    settingsLoader.active = true;

                    root.hideSidebar();
                }
            }
        }

        Rectangle {
            id: navAbout
            color: Theme.colorNavInactive
            width: parent.width
            height: 40
            y: 285

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
                    navActivate.color = Theme.colorNavInactive;
                    navAdmin.color = Theme.colorNavInactive;

                    dashboardLoader.visible = false;
                    reportsLoader.visible = false;
                    settingsLoader.visible = false;
                    installPoLoader.visible = false;
                    activateLoader.visible = false;
                    adminLoader.visible = false;

                    aboutLoader.active = false;
                    aboutLoader.visible = true;
                    aboutLoader.active = true;

                    root.hideSidebar();
                }
            }
        }

        Rectangle {
            id: navAdmin
            color: Theme.colorNavInactive
            width: parent.width
            height: 40
            y: 330

            visible: AdminManager.adminMode

            Image {
                source: "qrc:///media/icons/icon-admin.svg"
                height: 20
                width: 20
                x: 20
                y: 10
            }

            Text {
                color: Theme.colorTextPrimary
                text: qsTr("Admin")
                font.pointSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            MouseArea {
                id: mouseAreaAdmin
                width: parent.width
                height: parent.height

                onClicked: function () {
                    navSettings.color = Theme.colorNavInactive;
                    navAbout.color = Theme.colorNavInactive;
                    navReports.color = Theme.colorNavInactive;
                    navDashboard.color = Theme.colorNavInactive;
                    navInstallPO.color = Theme.colorNavInactive;
                    navActivate.color = Theme.colorNavInactive;
                    navAdmin.color = Theme.colorNavActive;

                    dashboardLoader.visible = false;
                    reportsLoader.visible = false;
                    settingsLoader.visible = false;
                    installPoLoader.visible = false;
                    activateLoader.visible = false;
                    aboutLoader.visible = false;

                    adminLoader.active = false;
                    adminLoader.visible = true;
                    adminLoader.active = true;

                    root.hideSidebar();
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
                    root.toggleSidebar();
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
            id: activateLoader
            anchors.fill: parent
            source: "Activate.qml"
            active: true
            visible: false
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

        Loader {
            id: adminLoader
            anchors.fill: parent
            source: "Admin.qml"
            active: false
            visible: false
        }
    }
}

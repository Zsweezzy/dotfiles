import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PC3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.plasma.private.sessions as Sessions

Item {
    id: menuRoot

    property var dialog: null
    property var root: null
    property var session: null

    readonly property string currentSection: root ? root.currentSection : "favorites"
    readonly property bool searchActive: root ? root.searchActive : false

    function closeMenu() {
        if (root) root.menuVisible = false
        if (dialog) {
            dialog.visible = false
            dialog.close()
        }
    }

    function triggerModel(modelValue, row) {
        if (!modelValue) return
        modelValue.trigger(row, "", null)
        closeMenu()
    }

    Kicker.RunnerModel {
        id: runnerModel
        query: root ? root.searchQuery : ""
        favoritesModel: root ? root.favoritesModel : null
        appletInterface: root ? root.plasmoid : null
        mergeResults: true
        runners: ["applications", "services", "places", "recentlyused", "calculator", "unitconverter", "baloosearch"]
        onQueryChanged: {
            if (query.length > 0) startQuery()
            else clear()
        }
    }

    implicitWidth: 720
    implicitHeight: 580

    Connections {
        target: menuRoot.dialog
        function onVisibleChanged() {
            if (menuRoot.dialog.visible) {
                Qt.callLater(function() { searchField.forceActiveFocus() })
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // --- Header: search field ---
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 2.2
            Layout.topMargin: Kirigami.Units.smallSpacing * 2
            Layout.leftMargin: Kirigami.Units.smallSpacing * 2
            Layout.rightMargin: Kirigami.Units.smallSpacing * 2
            Layout.bottomMargin: Kirigami.Units.smallSpacing
            color: "transparent"

            PlasmaExtras.SearchField {
                id: searchField
                anchors.fill: parent
                placeholderText: i18n("Search...")
                onTextChanged: root.searchQuery = text
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Kirigami.Theme.textColor
            opacity: 0.15
        }

        // --- Main row: sidebar + content ---
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Sidebar
            Rectangle {
                id: sidebar
                Layout.preferredWidth: 175
                Layout.fillHeight: true
                color: "transparent"
                Layout.topMargin: Kirigami.Units.smallSpacing
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                Layout.leftMargin: Kirigami.Units.smallSpacing * 2

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 2

                    SidebarItem {
                        labelText: i18n("Favorites")
                        iconName: "folder-favorites"
                        checked: menuRoot.currentSection === "favorites"
                        onClickedAction: menuRoot.root.currentSection = "favorites"
                    }
                    SidebarItem {
                        labelText: i18n("All Apps")
                        iconName: "applications-all"
                        checked: menuRoot.currentSection === "all"
                        onClickedAction: menuRoot.root.currentSection = "all"
                    }
                    SidebarItem {
                        labelText: i18n("Recent")
                        iconName: "document-open-recent"
                        checked: menuRoot.currentSection === "recent"
                        onClickedAction: menuRoot.root.currentSection = "recent"
                    }

                    Item { Layout.fillHeight: true }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        Layout.leftMargin: Kirigami.Units.smallSpacing
                        Layout.rightMargin: Kirigami.Units.smallSpacing
                        Layout.bottomMargin: Kirigami.Units.smallSpacing
                        color: Kirigami.Theme.textColor
                        opacity: 0.15
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        SessionButton {
                            iconName: "system-lock-screen"
                            tipText: i18n("Lock")
                            visible: session ? session.canLock : false
                            onClicked: {
                                session.lock()
                                menuRoot.closeMenu()
                            }
                        }
                        SessionButton {
                            iconName: "system-log-out"
                            tipText: i18n("Logout")
                            visible: session ? session.canLogout : false
                            onClicked: {
                                session.requestLogout(Sessions.SessionManagement.ConfirmationMode.Default)
                                menuRoot.closeMenu()
                            }
                        }
                        SessionButton {
                            iconName: "system-suspend"
                            tipText: i18n("Suspend")
                            visible: session ? session.canSuspend : false
                            onClicked: {
                                session.suspend()
                                menuRoot.closeMenu()
                            }
                        }
                        SessionButton {
                            iconName: "system-reboot"
                            tipText: i18n("Restart")
                            visible: session ? session.canReboot : false
                            onClicked: {
                                session.requestReboot(Sessions.SessionManagement.ConfirmationMode.Default)
                                menuRoot.closeMenu()
                            }
                        }
                        SessionButton {
                            iconName: "system-shutdown"
                            tipText: i18n("Shutdown")
                            visible: session ? session.canShutdown : false
                            onClicked: {
                                session.requestShutdown(Sessions.SessionManagement.ConfirmationMode.Default)
                                menuRoot.closeMenu()
                            }
                        }
                    }
                }
            }

            // Content
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.rightMargin: Kirigami.Units.smallSpacing * 2
                Layout.topMargin: Kirigami.Units.smallSpacing
                Layout.bottomMargin: Kirigami.Units.smallSpacing

                color: Kirigami.Theme.backgroundColor
                radius: Kirigami.Units.largeSpacing

                StackLayout {
                    id: contentStack
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.smallSpacing
                    currentIndex: menuRoot.searchActive ? 3
                        : menuRoot.currentSection === "favorites" ? 0
                        : menuRoot.currentSection === "all" ? 1 : 2

                    AppListView {
                        id: favoritesPage
                        model: root ? root.favoritesModel : null
                        showSections: false
                        onLaunch: menuRoot.triggerModel(model, index)
                    }

                    AppListView {
                        id: allAppsPage
                        model: root ? root.allAppsModel : null
                        showSections: true
                        onLaunch: menuRoot.triggerModel(model, index)
                    }

                    AppListView {
                        id: recentPage
                        model: root ? root.recentListModel : null
                        showSections: false
                        onLaunch: menuRoot.triggerModel(model, index)
                    }

                    AppListView {
                        id: searchPage
                        model: searchActive ? runnerModel : null
                        onLaunch: {
                            const matchModel = runnerModel.modelForRow(index)
                            if (matchModel) {
                                matchModel.trigger(index, "", null)
                            }
                            menuRoot.closeMenu()
                        }
                    }
                }
            }
        }
    }
}
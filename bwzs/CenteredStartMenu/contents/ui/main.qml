import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.plasma.private.sessions as Sessions

PlasmoidItem {
    id: root

    property bool menuVisible: false
    property string currentSection: "favorites"
    property string searchQuery: ""
    readonly property bool searchActive: searchQuery.length > 0
    property rect openScreenRect: Qt.rect(0, 0, 1920, 1080)

    property QtObject favoritesModel: null
    property QtObject allAppsModel: null
    property QtObject recentListModel: null

    Kicker.RootModel {
        id: rootModel
        autoPopulate: false
        appletInterface: root
        flat: true
        sorted: true
        showSeparators: false
        showRootSeparator: true
        showTopLevelItems: true
        showAllApps: true
        showAllAppsCategorized: false
        showRecentApps: false
        showRecentDocs: false
        showFavoritesPlaceholder: true
        showPowerSession: false
        highlightNewlyInstalledApps: false
        Component.onCompleted: {
            refresh()
            favoritesModel.initForClient("org.kde.plasma.centeredstart.favorites.instance-" + Plasmoid.id)
            root.favoritesModel = rootModel.favoritesModel
            Qt.callLater(function() {
                for (var i = 0; i < rootModel.count; i++) {
                    var m = rootModel.modelForRow(i)
                    if (m && m.description === "KICKER_ALL_MODEL") {
                        root.allAppsModel = m
                        break
                    }
                }
            })
        }
    }

    Kicker.RecentUsageModel {
        id: recentList
        favoritesModel: rootModel.favoritesModel
        shownItems: Kicker.RecentUsageModel.OnlyApps
        ordering: Kicker.RecentUsageModel.Recent
        Component.onCompleted: {
            refresh()
            root.recentListModel = recentList
        }
    }

    Sessions.SessionManagement {
        id: session
    }

    compactRepresentation: Item {
        id: compactRep

        MouseArea {
            anchors.fill: parent
            onClicked: {
                var s = compactRep.Screen
                if (s && s.width > 0 && s.height > 0
                        && s.virtualX !== undefined && s.virtualY !== undefined) {
                    root.openScreenRect = Qt.rect(Math.round(s.virtualX), Math.round(s.virtualY),
                                                  Math.round(s.width), Math.round(s.height))
                }
                root.menuVisible = !root.menuVisible
            }
        }
        Kirigami.Icon {
            anchors.fill: parent
            source: plasmoid.icon
        }
    }

    fullRepresentation: Item {
        visible: false
    }

    PlasmaCore.Dialog {
        id: menuDialog
        visible: root.menuVisible
        location: PlasmaCore.Types.Floating
        hideOnWindowDeactivate: false
        backgroundHints: PlasmaCore.Types.ShadowBackground

        property int menuWidth: 720
        property int menuHeight: 580
        property bool opening: false

        // Center on the screen captured before opening.
        x: Math.round((root.openScreenRect.width - menuWidth) / 2)
            + root.openScreenRect.x
        y: Math.round((root.openScreenRect.height - menuHeight) / 2)
            + root.openScreenRect.y
        width: menuWidth
        height: menuHeight

        onActiveChanged: {
            if (!active && root.menuVisible && !opening) {
                root.menuVisible = false
            }
        }

        onVisibleChanged: {
            if (visible) {
                opening = true
                openingGrace.restart()
                requestActivate()
            }
        }

        mainItem: MenuContent {
            dialog: menuDialog
            root: root
            session: session
        }
    }

    // Keeps the menu from closing during the brief window-activation race
    // that Wayland goes through when a new window first grabs focus.
    Timer {
        id: openingGrace
        interval: 400
        onTriggered: menuDialog.opening = false
    }
}
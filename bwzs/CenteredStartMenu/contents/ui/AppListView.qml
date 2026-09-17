import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

ListView {
    id: appList

    property bool showSections: false
    signal launch(var model, int index)

    clip: true
    spacing: 1
    currentIndex: -1

    section.property: "group"
    section.criteria: ViewSection.FirstCharacter
    section.delegate: Rectangle {
        width: appList.width
        height: appList.showSections ? 26 : 0
        color: "transparent"

        PC3.Label {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Kirigami.Units.smallSpacing
            text: section
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            font.bold: true
            opacity: 0.7
        }
    }

    delegate: AppDelegate {
        width: appList.width
        onItemClicked: appList.launch(appList.model, index)
    }
}
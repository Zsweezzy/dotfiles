import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

PC3.ToolButton {
    id: control

    property string labelText: ""
    property string iconName: ""

    signal clickedAction

    Layout.fillWidth: true
    Layout.preferredHeight: 40
    checkable: true

    contentItem: RowLayout {
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
            Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
            source: control.iconName
        }

        PC3.Label {
            Layout.fillWidth: true
            text: control.labelText
            horizontalAlignment: Text.AlignLeft
            elide: Text.ElideRight
            font.pointSize: Kirigami.Theme.defaultFont.pointSize
        }
    }

    background: Rectangle {
        radius: Kirigami.Units.smallSpacing
        color: control.checked || control.hovered ? Kirigami.Theme.highlightColor : "transparent"
        opacity: control.checked ? 0.25 : control.hovered ? 0.1 : 1
    }

    onClicked: clickedAction()
}
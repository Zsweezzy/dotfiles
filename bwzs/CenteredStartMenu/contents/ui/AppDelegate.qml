import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

PC3.ItemDelegate {
    id: delegate

    signal itemClicked

    width: parent ? parent.width : 0
    height: 48

    readonly property string displayText: model.name !== undefined && model.name.length > 0
        ? model.name : (model.display ? model.display : "Unknown")
    readonly property string descText: model.description ? model.description : ""
    readonly property string iconName: model.icon !== undefined && model.icon.length > 0
        ? model.icon : (model.decoration ? model.decoration : "")

    contentItem: RowLayout {
        spacing: Kirigami.Units.smallSpacing * 2

        Kirigami.Icon {
            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            source: delegate.iconName
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            PC3.Label {
                text: delegate.displayText
                Layout.fillWidth: true
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
            }

            PC3.Label {
                text: delegate.descText
                Layout.fillWidth: true
                visible: text.length > 0
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                opacity: 0.75
            }
        }
    }

    onClicked: itemClicked()
}
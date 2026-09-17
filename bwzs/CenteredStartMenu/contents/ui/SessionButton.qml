import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

PC3.ToolButton {
    id: control

    property string iconName: ""
    property string tipText: ""

    Layout.preferredWidth: 34
    Layout.preferredHeight: 34

    icon.source: control.iconName

    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        mainText: control.tipText
        textFormat: Text.PlainText
    }
}
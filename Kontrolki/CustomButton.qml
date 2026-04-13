import QtQuick
import QtQuick.Controls

Button {
    id: control
    property string tooltipText: ""
    property int iconSize: 32
    padding: 0
    contentItem: Item {
        implicitWidth: img.width
        implicitHeight: img.height
        Image {
            id: img
            anchors.centerIn: parent
            width: control.iconSize
            height: control.iconSize
            source: control.icon.source
            fillMode: Image.PreserveAspectFit
            opacity: control.hovered ? 1.0 : 0.8
        }
    }

    background: Rectangle {
        anchors.fill: parent
        color: control.pressed ? "#66000000" : (control.hovered ? "#33000000" : "transparent")
        radius: 8
    }

    ToolTip.visible: hovered && tooltipText !== ""
    ToolTip.text: tooltipText
    ToolTip.delay: 500
}
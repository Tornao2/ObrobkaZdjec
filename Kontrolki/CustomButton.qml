import QtQuick
import QtQuick.Controls

Button {
    id: control
    property string tooltipText: ""
    property int iconSize: 32
    hoverEnabled: true
    padding: 0
    signal entered()
    signal exited()
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        onEntered: control.entered()
        onExited: control.exited()
        cursorShape: Qt.PointingHandCursor
        onPressed: (mouse) => mouse.accepted = false
    }
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
            opacity: !control.enabled ? 0.2 : (control.hovered ? 1.0 : 0.8)
            scale: control.pressed ? 0.9 : 1.0
            Behavior on scale { NumberAnimation { duration: 50 } }
        }
    }

    background: Rectangle {
        implicitWidth: control.iconSize + 10
        implicitHeight: control.iconSize + 10
        color: control.pressed ? "#66000000" : (control.hovered ? "#33000000" : "transparent")
        radius: 8
    }

    ToolTip.visible: hovered && tooltipText !== ""
    ToolTip.text: tooltipText
    ToolTip.delay: 500
}
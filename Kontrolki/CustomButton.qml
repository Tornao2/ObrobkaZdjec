import QtQuick
import QtQuick.Controls

Button {
    id: control
    property string tooltipText: ""
    property int iconSize: 32
    hoverEnabled: true
    padding: 0
    property bool isSelected: false
    property color previewColor: "transparent"
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
        Rectangle {
            id: colorFill
            width: control.iconSize - 8
            height: control.iconSize - 8
            anchors.centerIn: parent
            radius: width / 2
            color: control.previewColor
            visible: control.previewColor !== "transparent"
        }
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
        color: control.isSelected ? "#66000000" :
                       (control.pressed ? "#66000000" :
                       (control.hovered ? "#33000000" : "transparent"))
        radius: 8
    }
    ToolTip.visible: hovered && tooltipText !== ""
    ToolTip.text: tooltipText
    ToolTip.delay: 500
}
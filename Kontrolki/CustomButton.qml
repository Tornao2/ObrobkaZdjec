import QtQuick
import QtQuick.Controls
import "../Style"
Button {
    id: control
    property string tooltipText: ""
    property int iconSize: Style.iconButtonIconSize
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
            width: control.iconSize - Style.iconButtonColorFillPadding
            height: control.iconSize - Style.iconButtonColorFillPadding
            anchors.centerIn: parent
            radius: width / 2
            color: control.previewColor
            visible: control.previewColor !== "transparent"
        }
        Image {
            id: img
            anchors.centerIn: parent
            mipmap: true
            width: Math.round(control.iconSize)
            height: Math.round(control.iconSize)
            sourceSize: Qt.size(width, height)
            antialiasing: true
            smooth: true
            source: control.icon.source.toString().replace("../Resources/", Style.iconPath)
            fillMode: Image.PreserveAspectFit
            opacity: !control.enabled ? Style.iconButtonDisabledOpacity : (control.hovered ? 1.0 : Style.iconButtonNormalOpacity)
            scale: control.pressed ? Style.iconButtonPressedScale : 1.0
            Behavior on scale { NumberAnimation { duration: Style.iconButtonAnimationDuration } }
        }
    }
    background: Rectangle {
        implicitWidth: control.iconSize + Style.iconButtonBgPadding
        implicitHeight: control.iconSize + Style.iconButtonBgPadding
        color: control.isSelected ? Style.iconButtonSelectedColor : (control.pressed ? Style.iconButtonPressedColor : (control.hovered ? Style.iconButtonHoveredColor : "transparent"))
        radius: Style.iconButtonRadius
    }
    ToolTip.visible: hovered && tooltipText !== ""
    ToolTip.text: tooltipText
    ToolTip.delay: Style.iconButtonTooltipDelay
}
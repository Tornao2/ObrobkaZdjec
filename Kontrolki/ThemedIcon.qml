import QtQuick
import QtQuick.Controls
import "../Style"

Item {
    id: root
    property alias source: img.source
    property alias fillMode: img.fillMode
    property color tintColor: appStyle.baseTextColor
    Style { id: appStyle }
    Image {
        id: img
        anchors.fill: parent
        visible: false
    }
    Rectangle {
        anchors.fill: parent
        color: root.tintColor
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: img
        }
    }
}
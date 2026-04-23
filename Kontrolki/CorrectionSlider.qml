import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    implicitHeight: 100
    property alias from: slider.from
    property alias to: slider.to
    property alias value: slider.value
    property alias stepSize: slider.stepSize
    property string title: "Tytuł"
    ColumnLayout {
        anchors.fill: parent
        spacing: 1
        Text {
            text: root.title
            font.pixelSize: 20
            font.weight: Font.Medium
            color: "black"
            Layout.alignment: Qt.AlignCenter
        }
        Slider {
            id: slider
            Layout.preferredWidth: 130
            Layout.preferredHeight: 40
            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitWidth: 200
                implicitHeight: 8
                width: slider.availableWidth
                height: implicitHeight
                radius: 3
                color: "#555555"
            }
            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitWidth: 22
                implicitHeight: 22
                radius: 9
                color: "white"
                border.color: "#333"
                border.width: 1
            }
            onPressedChanged: {
                if (!pressed) {
                    if (typeof root.parent.saveState === "function") root.parent.saveState()
                }
            }
        }
        Text {
            text: slider.value.toFixed(0)
            font.pixelSize: 22
            font.weight: Font.Medium
            color: "#333"
            Layout.alignment: Qt.AlignCenter
        }
    }
}
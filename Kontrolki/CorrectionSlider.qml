import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    implicitHeight: 105
    property alias from: slider.from
    property alias to: slider.to
    property alias value: slider.value
    property alias stepSize: slider.stepSize
    property alias pressed: slider.pressed
    property string title: "Tytuł"
    signal moved()
    ColumnLayout {
        anchors.fill: parent
        Text {
            text: root.title
            font.pixelSize: 18
            font.weight: Font.Medium
            color: "black"
            Layout.alignment: Qt.AlignCenter
        }
        Slider {
            id: slider
            Layout.preferredWidth: 130
            onMoved: root.moved()
            Layout.preferredHeight: 30
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
        Button {
            text: "↺"
            Layout.alignment: Qt.AlignCenter
            flat: true
            Layout.preferredWidth: 115
            Layout.preferredHeight: 16
            contentItem: Text {
                text: parent.text
                font.pixelSize: 10
                font.bold: true
                verticalAlignment: Text.AlignVCenter
                color: "black"
                horizontalAlignment: Text.AlignHCenter
            }
            background: Rectangle {
                implicitHeight: 3
                color: "#D65151"
                radius: 5
            }
            onClicked: {
                slider.value = 0
                root.moved()
                if (typeof root.parent.saveState === "function") root.parent.saveState()
            }
        }
        Text {
            text: slider.value.toFixed(0)
            font.pixelSize: 20
            font.weight: Font.Medium
            color: "#333"
            Layout.alignment: Qt.AlignCenter
        }
    }
}
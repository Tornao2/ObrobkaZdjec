import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Style"
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
            font.pixelSize: Style.sliderTitleFontSize
            font.weight: Style.sliderTitleFontWeight
            color: Style.sliderTitleColor
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
                implicitWidth: Style.sliderBgImplicitWidth
                implicitHeight: Style.sliderBgImplicitHeight
                width: slider.availableWidth
                height: implicitHeight
                radius: Style.sliderBgRadius
                color: Style.sliderBgColor
            }
            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitWidth: Style.sliderHandleImplicitWidth
                implicitHeight: Style.sliderHandleImplicitHeight
                radius: Style.sliderHandleRadius
                color: Style.sliderHandleColor
                border.color: Style.sliderHandleBorderColor
                border.width: Style.sliderHandleBorderWidth
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
            Layout.preferredWidth: Style.sliderResetBtnWidth
            Layout.preferredHeight: Style.sliderResetBtnHeight
            contentItem: Text {
                text: parent.text
                font.pixelSize: Style.sliderResetBtnFontSize
                font.bold: true
                verticalAlignment: Text.AlignVCenter
                color: Style.sliderResetBtnTextColor
                horizontalAlignment: Text.AlignHCenter
            }
            background: Rectangle {
                implicitHeight: Style.sliderResetBtnBgHeight
                color: Style.sliderResetBtnBgColor
                radius: Style.sliderResetBtnBgRadius
            }
            onClicked: {
                slider.value = 0
                root.moved()
                if (typeof root.parent.saveState === "function") root.parent.saveState()
            }
        }
        Text {
            text: slider.value.toFixed(0)
            font.pixelSize: Style.sliderValueFontSize
            font.weight: Style.sliderValueFontWeight
            color: Style.sliderValueColor
            Layout.alignment: Qt.AlignCenter
        }
    }
}
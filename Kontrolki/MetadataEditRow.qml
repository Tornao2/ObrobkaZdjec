import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

RowLayout {
    property string label: ""
    property string value: ""
    property string inputMask: ""
    spacing: 10
    property var validator: null
    Layout.fillWidth: true
    property bool isReadOnly: false
    Text {
        text: label
        Layout.preferredWidth: 150
        font.pixelSize: 16
        font.bold: true
        color: "#222"
    }

    TextField {
        id: editField
        text: value
        Layout.fillWidth: true
        font.pixelSize: 16
        selectByMouse: true
        color: activeFocus ? "black" : "#333"
        inputMask: parent.inputMask
        validator: parent.validator
        readOnly: isReadOnly
        background: Rectangle {
            color: (editField.activeFocus && !editField.readOnly) ? "white" : "transparent"
            border.color: !editField.acceptableInput ? "red" : (editField.activeFocus ? "#3498db" : "transparent")
            border.width: 1
            radius: 4
        }
    }
}
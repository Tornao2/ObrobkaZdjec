import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

RowLayout {
    id: root
    signal edited(string newValue)
    property string label: ""
    property string value: ""
    property string inputMask: ""
    property string trailingIcon: "../Resources/edit-pencil.svg"
    property var validator: null
    property bool isReadOnly: false
    spacing: 10
    Layout.fillWidth: true
    opacity: isReadOnly ? 0.7 : 1.0

    Text {
        text: label
        Layout.preferredWidth: 150
        Layout.minimumWidth: 150
        Layout.maximumWidth: 150
        font.pixelSize: 16
        font.bold: true
        color: "#222"
        horizontalAlignment: Text.AlignRight
    }

    TextField {
        id: editField
        text: value
        Layout.fillWidth: true
        font.pixelSize: 16
        selectByMouse: true
        onEditingFinished: {
            if (value !== text) {
                root.edited(text)
            }
        }
        color: activeFocus ? "black" : "#333"
        inputMask: parent.inputMask
        validator: parent.validator
        readOnly: isReadOnly
        Layout.rightMargin: 50
        rightPadding: (!isReadOnly && trailingIcon !== "") ? 35 : 10
        background: Rectangle {
            color: (editField.activeFocus && !isReadOnly) ? "white" : "transparent"
            border.color: !editField.acceptableInput ? "red" : (editField.activeFocus ? "#3498db" : "transparent")
            border.width: 1
            radius: 4
        }

        Image {
            source: root.trailingIcon
            visible: !root.isReadOnly && root.trailingIcon !== ""
            width: 18
            height: 18
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            opacity: editField.activeFocus ? 0.8 : 0.4
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
    }
}
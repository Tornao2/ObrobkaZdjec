import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../Style"
RowLayout {
    id: root
    spacing: Style.inputRowSpacing
    property string label: ""
    property string value: ""
    property bool isReadOnly: false
    property string trailingIcon: ""
    property string inputMask: ""
    property var validator: null
    signal edited(string newValue)
    Text {
        text: root.label
        font.pixelSize: Style.inputLabelFontSize
        font.bold: Style.inputLabelFontBold
        color: Style.inputLabelColor
        Layout.preferredWidth: Style.inputLabelWidth
        Layout.minimumWidth: Style.inputLabelWidth
        Layout.maximumWidth: Style.inputLabelWidth
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
    }
    Item {
        Layout.fillWidth: true
        Layout.rightMargin: Style.inputFieldRightMargin
        Layout.preferredHeight: Style.inputFieldHeight
        Rectangle {
            anchors.fill: parent
            radius: Style.inputFieldRadius
            color: root.isReadOnly ? Style.inputFieldBgReadOnly : Style.inputFieldBgNormal
            border.color: inputField.activeFocus ? Style.inputFieldFocusBorderColor : "transparent"
            border.width: Style.inputFieldBorderWidth
            TextField {
                id: inputField
                anchors.fill: parent
                text: root.value
                readOnly: root.isReadOnly
                color: root.isReadOnly ? Style.inputFieldTextReadOnly : Style.inputFieldTextNormal
                background: null
                font.pixelSize: Style.inputFieldFontSize
                leftPadding: Style.inputFieldPaddingLeft
                rightPadding: root.trailingIcon !== "" ? Style.inputFieldPaddingRightIcon : Style.inputFieldPaddingRight
                verticalAlignment: TextInput.AlignVCenter
                inputMask: root.inputMask
                validator: root.validator
                onEditingFinished: root.edited(text)
                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        nextItemInFocusChain().forceActiveFocus();
                        event.accepted = true;
                    }
                }
            }
            Image {
                source: Style.currentTheme === "dark" ? "../Resources/icons-light/edit-pencil.svg" :  "../Resources/edit-pencil.svg"
                visible: root.trailingIcon !== "" && !root.isReadOnly
                width: Style.inputIconSize
                height: Style.inputIconSize
                anchors.right: parent.right
                anchors.rightMargin: Style.inputIconRightMargin
                anchors.verticalCenter: parent.verticalCenter
                opacity: inputField.activeFocus ? Style.inputIconFocusOpacity : Style.inputIconNormalOpacity
                fillMode: Image.PreserveAspectFit
                smooth: true
            }
        }
    }
}
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../Style"

Item {
    id: root
    property string titleText:   "Niezapisane zmiany"
    property string messageText: "Czy na pewno chcesz wyjść?"
    property string confirmText: "Wyjdź bez zapisywania"
    property string cancelText:  "Anuluj"
    signal confirmed()
    signal cancelled()
    function open()  { root.visible = true  }
    function close() { root.visible = false }
    anchors.fill: parent
    visible: false
    z: 9999
    Rectangle {
        id: overlay
        anchors.fill: parent
        color: Style.overlayColor
        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.cancelled()
                root.close()
            }
        }
        Rectangle {
            id: dialog
            anchors.centerIn: parent
            width: 340
            height: dialogColumn.implicitHeight + 48
            color: Style.dialogBackground
            opacity: 1.0
            radius: Style.dialogRadius
            layer.enabled: true
            MouseArea { anchors.fill: parent }
            ColumnLayout {
                id: dialogColumn
                anchors {
                    top: parent.top; left: parent.left; right: parent.right
                    topMargin: 24; leftMargin: 24; rightMargin: 24
                }
                spacing: 0
                Text {
                    text: root.titleText
                    font.pixelSize: Style.fontTitleSize
                    font.weight: Font.Bold
                    color: Style.titleColor
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Style.separatorColor
                    Layout.topMargin: 5
                    Layout.bottomMargin: 5
                }
                Text {
                    text: root.messageText
                    font.pixelSize: Style.fontBodySize
                    color: Style.messageColor
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    Layout.bottomMargin: 5
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Layout.topMargin: 5
                    Layout.bottomMargin: 0
                    Button {
                        id: cancelBtn
                        text: root.cancelText
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        contentItem: Text {
                            text: cancelBtn.text
                            font.pixelSize: Style.fontBodySize
                            font.weight: Font.Medium
                            color: Style.btnCancelText
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: cancelBtn.pressed ? Style.btnCancelPressed
                                 : cancelBtn.hovered ? Style.btnCancelHover
                                 : Style.btnCancelNormal
                            radius: Style.buttonRadius
                        }
                        onClicked: {
                            root.cancelled()
                            root.close()
                        }
                    }
                    Button {
                        id: confirmBtn
                        text: root.confirmText
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        contentItem: Text {
                            text: confirmBtn.text
                            font.pixelSize: Style.fontBodySize
                            font.weight: Font.Medium
                            color: Style.btnCancelText
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: confirmBtn.pressed ? Style.btnConfirmPressed
                                 : confirmBtn.hovered ? Style.btnConfirmHover
                                 : Style.btnConfirmNormal
                            radius: Style.buttonRadius
                        }
                        onClicked: {
                            root.confirmed()
                            root.close()
                        }
                    }
                }
            }
        }
    }
}
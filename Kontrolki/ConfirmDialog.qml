import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Style"

Dialog {
    id: root
    property alias message: messageText.text
    property bool isAlert: false
    signal confirmed()
    title: "Potwierdzenie"
    modal: true
    anchors.centerIn: Overlay.overlay
    standardButtons: isAlert ? Dialog.Ok : (Dialog.No | Dialog.Yes)
    background: Rectangle {
        color: Style.dialogBackground
        radius: Style.dialogRadius
        layer.enabled: true
    }

    header: Rectangle {
        color: Style.dialogHeaderBackground
        height: 40
        radius: Style.dialogRadius

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 10
            color: Style.dialogHeaderBackground
        }

        Text {
            text: root.title
            anchors.centerIn: parent
            font.pixelSize: Style.fontBodySize
            font.weight: Font.Bold
            color: Style.titleColor
        }
    }

    contentItem: Item {
        implicitWidth: 400
        implicitHeight: 150

        Text {
            id: messageText
            width: parent.width - 40
            anchors.centerIn: parent
            text: "Czy na pewno chcesz wykonać tę akcję?"
            font.pixelSize: Style.fontBodySize
            color: Style.messageColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
        }
    }

    footer: DialogButtonBox {
        background: Rectangle {
            color: "transparent"
        }
        alignment: Qt.AlignHCenter
        spacing: 20
        topPadding: 10
        bottomPadding: 15

        delegate: Button {
            id: control
            implicitWidth: 100
            implicitHeight: 40

            contentItem: Text {
                text: {
                    if (control.text === "Yes") return "Tak"
                    if (control.text === "No") return "Nie"
                    if (control.text === "OK") return "OK"
                    return control.text
                }
                font.pixelSize: Style.fontBodySize
                font.weight: Font.Medium
                color: control.text === "Yes" ? Style.btnConfirmText : Style.btnCancelText
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: control.text === "Yes"
                    ? (control.pressed ? Style.btnConfirmPressed : Style.btnConfirmNormal)
                    : (control.pressed ? Style.btnCancelPressed  : Style.btnCancelNormal)
                radius: Style.buttonRadius
            }
        }
    }

    onAccepted: confirmed()
}
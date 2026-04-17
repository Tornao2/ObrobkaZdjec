import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

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
        color: "#8E9191"
        radius: 10
        layer.enabled: true
    }

    header: Rectangle {
        color: "#7A7D7D"
        height: 40
        radius: 10
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width; height: 10; color: "#7A7D7D"
        }
        Text {
            text: root.title
            anchors.centerIn: parent
            font.pixelSize: 18
            color: "black"
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
            font.pixelSize: 18
            color: "black"
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
                font.pixelSize: 16
                font.weight: Font.Medium
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                color: control.text === "Yes" ? (control.pressed ? "#963838" : "#AC4141")
                                              : (control.pressed ? "#555" : "#6F7373")
                radius: 4
            }
        }
    }
    onAccepted: confirmed()
}
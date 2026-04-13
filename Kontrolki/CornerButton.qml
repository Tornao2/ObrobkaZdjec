import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: control
    property string mainText: "---------"
    Layout.fillWidth: true
    Layout.preferredHeight: 45
    contentItem: Text {
        text: control.mainText
        opacity: control.hovered ? 1.0 : 0.8
        color: "black"
        font.pixelSize: 18
        font.weight: Font.Medium
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    background: Rectangle {
        color: control.pressed ? "#66000000" : (control.hovered ? "#33000000" : "transparent")
        radius: 8
        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.strokeStyle = "#444";
                ctx.lineWidth = 4;
                var len = 8;
                ctx.beginPath(); ctx.moveTo(0, len); ctx.lineTo(0, 0); ctx.lineTo(len, 0); ctx.stroke();
                ctx.beginPath(); ctx.moveTo(width - len, 0); ctx.lineTo(width, 0); ctx.lineTo(width, len); ctx.stroke();
                ctx.beginPath(); ctx.moveTo(0, height - len); ctx.lineTo(0, height); ctx.lineTo(len, height); ctx.stroke();
                ctx.beginPath(); ctx.moveTo(width - len, height); ctx.lineTo(width, height); ctx.lineTo(width, height - len); ctx.stroke();
            }
        }
    }
}
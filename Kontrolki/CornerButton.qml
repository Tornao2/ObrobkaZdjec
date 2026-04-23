import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore
import QtQuick.Controls.Basic

Button {
    id: control
    property string assignedFunction: ""
    property string mainText: assignedFunction === "" ? "---------" : assignedFunction
    property string settingsCategory: "button1"
    Layout.fillWidth: true
    signal functionActivated(string funcName)
    Layout.preferredHeight: 45
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton || control.assignedFunction === "") {
                contextMenu.popup()
            } else {
                control.functionActivated(control.assignedFunction)
            }
        }
    }
    Settings {
        category: control.settingsCategory
        property alias assignedFunction: control.assignedFunction
    }
    contentItem: Text {
        text: control.mainText
        opacity: control.hovered ? 1.0 : 0.8
        color: "black"
        font.pixelSize: 16
        font.weight: Font.Medium
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    Menu {
        id: contextMenu
        transformOrigin: Menu.Left
        spacing: 0
        background: Rectangle {
            implicitWidth: 200
            color: "#8E9191"
            radius: 6
            border.color: "#7A7D7D"
        }
        delegate: MenuItem {
            id: menuItem
            implicitHeight: 45
            arrow: null
            contentItem: Text {
                text: menuItem.text
                font.pixelSize: 14;
                font.weight: Font.Medium;
                color: "black";
                verticalAlignment: Text.AlignVCenter;
            }
            background: Rectangle {
                color: menuItem.highlighted ? "#9DA1A1" : "transparent"
                radius: 4
                anchors.fill: parent
                anchors.margins: 4
            }
        }

        Menu {
            title: "Manipulacja wymiarami"
            x: parent.width; y: 0
            background: Rectangle { implicitWidth: 200; color: "#8E9191"; radius: 6; border.color: "#7A7D7D" }
            MenuItem {
                text: "Obróć w lewo"; onTriggered: control.assignedFunction = "Obróć w lewo"
                implicitHeight: 45
                arrow: null; indicator: null
                contentItem: Text { text: "Obróć w lewo"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle { color: parent.highlighted ? "#9DA1A1" : "transparent"; radius: 4; anchors.fill: parent; anchors.margins: 4 }
            }
            MenuItem {
                text: "Obróć w prawo"; onTriggered: control.assignedFunction = "Obróć w prawo"
                implicitHeight: 45
                arrow: null; indicator: null
                contentItem: Text { text: "Obróć w prawo"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle { color: parent.highlighted ? "#9DA1A1" : "transparent"; radius: 4; anchors.fill: parent; anchors.margins: 4 }
            }
            MenuItem {
                text: "Odbij w bok"; onTriggered: control.assignedFunction = "Odbij w bok"
                implicitHeight: 45
                arrow: null; indicator: null
                contentItem: Text { text: "Odbij w bok"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle { color: parent.highlighted ? "#9DA1A1" : "transparent"; radius: 4; anchors.fill: parent; anchors.margins: 4 }
            }
            MenuItem {
                text: "Odbij wertykalnie"; onTriggered: control.assignedFunction = "Odbij wertykalnie"
                implicitHeight: 45
                arrow: null; indicator: null
                contentItem: Text { text: "Odbij wertykalnie"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle { color: parent.highlighted ? "#9DA1A1" : "transparent"; radius: 4; anchors.fill: parent; anchors.margins: 4 }
            }
        }
        Menu {
            title: "Filtry"
            x: parent.width; y: 0
            background: Rectangle { implicitWidth: 200; color: "#8E9191"; radius: 6; border.color: "#7A7D7D" }
            MenuItem {
                text: "Czarno-Biały"; onTriggered: control.assignedFunction = "Czarno-Biały"
                implicitHeight: 45
                arrow: null; indicator: null
                contentItem: Text { text: "Czarno-Biały"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle { color: parent.highlighted ? "#9DA1A1" : "transparent"; radius: 4; anchors.fill: parent; anchors.margins: 4 }
            }
            MenuItem {
                text: "Sepia"; onTriggered: control.assignedFunction = "Sepia"
                implicitHeight: 45
                arrow: null; indicator: null
                contentItem: Text { text: "Sepia"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle { color: parent.highlighted ? "#9DA1A1" : "transparent"; radius: 4; anchors.fill: parent; anchors.margins: 4 }
            }
        }
        Menu {
            title: "Rysunek"
            x: parent.width; y: 0
            background: Rectangle { implicitWidth: 200; color: "#8E9191"; radius: 6; border.color: "#7A7D7D" }
            MenuItem {
                text: "Ołówek"; onTriggered: control.assignedFunction = "Sepia"
                implicitHeight: 45
                arrow: null; indicator: null
                contentItem: Text { text: "Ołówek"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle { color: parent.highlighted ? "#9DA1A1" : "transparent"; radius: 4; anchors.fill: parent; anchors.margins: 4 }
            }
        }
        MenuSeparator {
            contentItem: Rectangle {
                implicitHeight: 2;
                color: "#7A7D7D";
                anchors.leftMargin: 5; anchors.rightMargin: 5
            }
        }
        MenuItem {
            id: clearItem
            text: "Wyczyść slot"
            enabled: control.assignedFunction !== ""
            onTriggered: control.assignedFunction = ""
            implicitHeight: 45
            arrow: null
            indicator: null
            contentItem: Text {
                text: "Wyczyść slot"
                font.pixelSize: 14
                font.weight: Font.Medium
                color: control.assignedFunction !== "" ? "black" : "#555"
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                color: clearItem.highlighted ? "#9DA1A1" : "transparent"
                radius: 4
                anchors.fill: parent
                anchors.margins: 4
            }
        }
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
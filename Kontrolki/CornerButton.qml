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
    Layout.preferredHeight: 50
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
        background: Rectangle {
            implicitWidth: 200
            color: "#8E9191"
            radius: 6
            border.color: "#7A7D7D"
        }
        delegate: MenuItem {
            id: menuItem
            implicitHeight: 50
            arrow: null

            contentItem: Text {
                text: menuItem.text
                font.pixelSize: 14;
                font.weight: Font.Medium;
                color: "black";
                verticalAlignment: Text.AlignVCenter;
            }
            background: Rectangle {
                color: menuItem.pressed ? "#66000000" : (menuItem.hovered ? "#33000000" : "transparent")
                radius: 8
                anchors.fill: parent
                anchors.margins: 4
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

        Menu {
            title: "Manipulacja wymiarami"
            x: parent.width; y: 0
            background: Rectangle { implicitWidth: 200; color: "#8E9191"; radius: 6; border.color: "#7A7D7D" }
            MenuItem {
                text: "Obróć w lewo"; onTriggered: control.assignedFunction = "Obróć w lewo"
                implicitHeight: 50
                arrow: null; indicator: null
                contentItem: Text { text: "Obróć w lewo"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle {
                    color: parent.highlighted ? "#33000000" : "transparent"
                    radius: 8
                    anchors.fill: parent
                    anchors.margins: 4
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
            MenuItem {
                text: "Obróć w prawo"; onTriggered: control.assignedFunction = "Obróć w prawo"
                implicitHeight: 50
                arrow: null; indicator: null
                contentItem: Text { text: "Obróć w prawo"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle {
                    color: parent.highlighted ? "#33000000" : "transparent"
                    radius: 8
                    anchors.fill: parent
                    anchors.margins: 4
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
            MenuItem {
                text: "Odbij w bok"; onTriggered: control.assignedFunction = "Odbij w bok"
                implicitHeight: 50
                arrow: null; indicator: null
                contentItem: Text { text: "Odbij w bok"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle {
                    color: parent.highlighted ? "#33000000" : "transparent"
                    radius: 8
                    anchors.fill: parent
                    anchors.margins: 4
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
            MenuItem {
                text: "Odbij wertykalnie"; onTriggered: control.assignedFunction = "Odbij wertykalnie"
                implicitHeight: 50
                arrow: null; indicator: null
                contentItem: Text { text: "Odbij wertykalnie"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle {
                    color: parent.highlighted ? "#33000000" : "transparent"
                    radius: 8
                    anchors.fill: parent
                    anchors.margins: 4
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
        }
        Menu {
            title: "Filtry"
            x: parent.width; y: 0
            background: Rectangle { implicitWidth: 200; color: "#8E9191"; radius: 6; border.color: "#7A7D7D" }
            MenuItem {
                text: "Krawędzie"; onTriggered: control.assignedFunction = "Krawędzie"
                implicitHeight: 50
                arrow: null; indicator: null
                contentItem: Text { text: "Krawędzie"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle {
                    color: parent.highlighted ? "#33000000" : "transparent"
                    radius: 8
                    anchors.fill: parent
                    anchors.margins: 4
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
            MenuItem {
                text: "Szum"; onTriggered: control.assignedFunction = "Szum"
                implicitHeight: 50
                arrow: null; indicator: null
                contentItem: Text { text: "Szum"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle {
                    color: parent.highlighted ? "#33000000" : "transparent"
                    radius: 8
                    anchors.fill: parent
                    anchors.margins: 4
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
            MenuItem {
                text: "Rozmycie kół"; onTriggered: control.assignedFunction = "Rozmycie kół"
                implicitHeight: 50
                arrow: null; indicator: null
                contentItem: Text { text: "Rozmycie kół"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle {
                    color: parent.highlighted ? "#33000000" : "transparent"
                    radius: 8
                    anchors.fill: parent
                    anchors.margins: 4
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
            MenuItem {
                text: "Pixel Art"; onTriggered: control.assignedFunction = "Pixel Art"
                implicitHeight: 50
                arrow: null; indicator: null
                contentItem: Text { text: "Pixel Art"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle {
                    color: parent.highlighted ? "#33000000" : "transparent"
                    radius: 8
                    anchors.fill: parent
                    anchors.margins: 4
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
            MenuItem {
                text: "Stary Film"; onTriggered: control.assignedFunction = "Stary Film"
                implicitHeight: 50
                arrow: null; indicator: null
                contentItem: Text { text: "Stary Film"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle {
                    color: parent.highlighted ? "#33000000" : "transparent"
                    radius: 8
                    anchors.fill: parent
                    anchors.margins: 4
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
            MenuItem {
                text: "Negatyw"; onTriggered: control.assignedFunction = "Negatyw"
                implicitHeight: 50
                arrow: null; indicator: null
                contentItem: Text { text: "Negatyw"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle {
                    color: parent.highlighted ? "#33000000" : "transparent"
                    radius: 8
                    anchors.fill: parent
                    anchors.margins: 4
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
            MenuItem {
                text: "Sepia Retro"; onTriggered: control.assignedFunction = "Sepia Retro"
                implicitHeight: 50
                arrow: null; indicator: null
                contentItem: Text { text: "Sepia Retro"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle {
                    color: parent.highlighted ? "#33000000" : "transparent"
                    radius: 8
                    anchors.fill: parent
                    anchors.margins: 4
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
            MenuItem {
                text: "Progowanie"; onTriggered: control.assignedFunction = "Progowanie"
                implicitHeight: 50
                arrow: null; indicator: null
                contentItem: Text { text: "Progowanie"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle {
                    color: parent.highlighted ? "#33000000" : "transparent"
                    radius: 8
                    anchors.fill: parent
                    anchors.margins: 4
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
            MenuItem {
                text: "Zimna Noc"; onTriggered: control.assignedFunction = "Zimna Noc"
                implicitHeight: 50
                arrow: null; indicator: null
                contentItem: Text { text: "Zimna Noc"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle {
                    color: parent.highlighted ? "#33000000" : "transparent"
                    radius: 8
                    anchors.fill: parent
                    anchors.margins: 4
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
            MenuItem {
                text: "Ciepłe Lato"; onTriggered: control.assignedFunction = "Ciepłe Lato"
                implicitHeight: 50
                arrow: null; indicator: null
                contentItem: Text { text: "Ciepłe Lato"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle {
                    color: parent.highlighted ? "#33000000" : "transparent"
                    radius: 8
                    anchors.fill: parent
                    anchors.margins: 4
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
        }
        Menu {
            title: "Rysunek"
            x: parent.width; y: 0
            background: Rectangle { implicitWidth: 200; color: "#8E9191"; radius: 6; border.color: "#7A7D7D" }
            MenuItem {
                text: "Ołówek"; onTriggered: control.assignedFunction = "Ołówek"
                implicitHeight: 50
                arrow: null; indicator: null
                contentItem: Text { text: "Ołówek"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle {
                    color: parent.highlighted ? "#33000000" : "transparent"
                    radius: 8
                    anchors.fill: parent
                    anchors.margins: 4
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
            MenuItem {
                text: "Pióro"; onTriggered: control.assignedFunction = "Pióro"
                implicitHeight: 50
                arrow: null; indicator: null
                contentItem: Text { text: "Pióro"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle {
                    color: parent.highlighted ? "#33000000" : "transparent"
                    radius: 8
                    anchors.fill: parent
                    anchors.margins: 4
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
            MenuItem {
                text: "Gumka"; onTriggered: control.assignedFunction = "Gumka"
                implicitHeight: 50
                arrow: null; indicator: null
                contentItem: Text { text: "Gumka"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle {
                    color: parent.highlighted ? "#33000000" : "transparent"
                    radius: 8
                    anchors.fill: parent
                    anchors.margins: 4
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
            MenuItem {
                text: "Kolor"; onTriggered: control.assignedFunction = "Kolor"
                implicitHeight: 50
                arrow: null; indicator: null
                contentItem: Text { text: "Kolor"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle {
                    color: parent.highlighted ? "#33000000" : "transparent"
                    radius: 8
                    anchors.fill: parent
                    anchors.margins: 4
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
            MenuItem {
                text: "Tekst"; onTriggered: control.assignedFunction = "Tekst"
                implicitHeight: 50
                arrow: null; indicator: null
                contentItem: Text { text: "Tekst"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle {
                    color: parent.highlighted ? "#33000000" : "transparent"
                    radius: 8
                    anchors.fill: parent
                    anchors.margins: 4
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
            MenuItem {
                text: "Próbnik"; onTriggered: control.assignedFunction = "Próbnik"
                implicitHeight: 50
                arrow: null; indicator: null
                contentItem: Text { text: "Próbnik"; font.pixelSize: 14; font.weight: Font.Medium; color: "black"; verticalAlignment: Text.AlignVCenter;}
                background: Rectangle {
                    color: parent.highlighted ? "#33000000" : "transparent"
                    radius: 8
                    anchors.fill: parent
                    anchors.margins: 4
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
            implicitHeight: 50
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
                color: clearItem.pressed ? "#66000000" : (clearItem.hovered ? "#33000000" : "transparent")
                radius: 8
                anchors.fill: parent
                anchors.margins: 4
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
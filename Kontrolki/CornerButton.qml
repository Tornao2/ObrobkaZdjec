import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore
import QtQuick.Controls.Basic
import "../Style"
Button {
    id: control
    property string assignedFunction: ""
    property string mainText: assignedFunction === "" ? "---------" : assignedFunction
    property string settingsCategory: "button1"
    Layout.fillWidth: true
    Layout.preferredHeight: Style.menuItemHeight
    signal functionActivated(string funcName)
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
        color: Style.customButtonText
        font.pixelSize: Style.fontBodySize
        font.weight: Style.fontWeight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    Menu {
        id: contextMenu
        transformOrigin: Menu.Left
        background: Rectangle {
            implicitWidth: Style.menuWidth
            color: Style.menuBackground
            radius: Style.menuRadius
            border.color: Style.menuBorder
        }
        delegate: MenuItem {
            id: menuItem
            implicitHeight: Style.menuItemHeight
            arrow: null
            contentItem: Text {
                text: menuItem.text
                font.pixelSize: Style.menuTextSize
                font.weight: Style.fontWeight
                color: Style.menuText
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                color: menuItem.pressed ? Style.menuItemPressed : (menuItem.hovered ? Style.menuItemHover : "transparent")
                radius: Style.menuItemRadius
                anchors.fill: parent
                anchors.margins: Style.menuItemMargin
                Canvas {
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.strokeStyle = Style.canvasBorderColor
                        ctx.lineWidth = Style.canvasBorderWidth
                        var len = Style.canvasBorderLen
                        ctx.beginPath(); ctx.moveTo(0, len); ctx.lineTo(0, 0); ctx.lineTo(len, 0); ctx.stroke()
                        ctx.beginPath(); ctx.moveTo(width - len, 0); ctx.lineTo(width, 0); ctx.lineTo(width, len); ctx.stroke()
                        ctx.beginPath(); ctx.moveTo(0, height - len); ctx.lineTo(0, height); ctx.lineTo(len, height); ctx.stroke()
                        ctx.beginPath(); ctx.moveTo(width - len, height); ctx.lineTo(width, height); ctx.lineTo(width, height - len); ctx.stroke()
                    }
                }
            }
        }
        Menu {
            title: "Manipulacja wymiarami"
            x: parent.width; y: 0
            background: Rectangle {
                implicitWidth: Style.menuWidth
                color: Style.menuBackground
                radius: Style.menuRadius
                border.color: Style.menuBorder
            }
            MenuItem {
                text: "Obróć w lewo"; onTriggered: control.assignedFunction = "Obróć w lewo"
                implicitHeight: Style.menuItemHeight; arrow: null; indicator: null
                contentItem: Text { text: "Obróć w lewo"; font.pixelSize: Style.menuTextSize; font.weight: Style.fontWeight; color: Style.menuText; verticalAlignment: Text.AlignVCenter; }
                background: Rectangle {
                    color: parent.highlighted ? Style.menuItemHover : "transparent"
                    radius: Style.menuItemRadius; anchors.fill: parent; anchors.margins: Style.menuItemMargin
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d"); ctx.reset(); ctx.strokeStyle = Style.canvasBorderColor; ctx.lineWidth = Style.canvasBorderWidth; var len = Style.canvasBorderLen;
                            ctx.beginPath(); ctx.moveTo(0, len); ctx.lineTo(0, 0); ctx.lineTo(len, 0); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, 0); ctx.lineTo(width, 0); ctx.lineTo(width, len); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(0, height - len); ctx.lineTo(0, height); ctx.lineTo(len, height); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, height); ctx.lineTo(width, height); ctx.lineTo(width, height - len); ctx.stroke()
                        }
                    }
                }
            }
            MenuItem {
                text: "Obróć w prawo"; onTriggered: control.assignedFunction = "Obróć w prawo"
                implicitHeight: Style.menuItemHeight; arrow: null; indicator: null
                contentItem: Text { text: "Obróć w prawo"; font.pixelSize: Style.menuTextSize; font.weight: Style.fontWeight; color: Style.menuText; verticalAlignment: Text.AlignVCenter; }
                background: Rectangle {
                    color: parent.highlighted ? Style.menuItemHover : "transparent"
                    radius: Style.menuItemRadius; anchors.fill: parent; anchors.margins: Style.menuItemMargin
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d"); ctx.reset(); ctx.strokeStyle = Style.canvasBorderColor; ctx.lineWidth = Style.canvasBorderWidth; var len = Style.canvasBorderLen;
                            ctx.beginPath(); ctx.moveTo(0, len); ctx.lineTo(0, 0); ctx.lineTo(len, 0); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, 0); ctx.lineTo(width, 0); ctx.lineTo(width, len); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(0, height - len); ctx.lineTo(0, height); ctx.lineTo(len, height); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, height); ctx.lineTo(width, height); ctx.lineTo(width, height - len); ctx.stroke()
                        }
                    }
                }
            }
            MenuItem {
                text: "Odbij w bok"; onTriggered: control.assignedFunction = "Odbij w bok"
                implicitHeight: Style.menuItemHeight; arrow: null; indicator: null
                contentItem: Text { text: "Odbij w bok"; font.pixelSize: Style.menuTextSize; font.weight: Style.fontWeight; color: Style.menuText; verticalAlignment: Text.AlignVCenter; }
                background: Rectangle {
                    color: parent.highlighted ? Style.menuItemHover : "transparent"
                    radius: Style.menuItemRadius; anchors.fill: parent; anchors.margins: Style.menuItemMargin
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d"); ctx.reset(); ctx.strokeStyle = Style.canvasBorderColor; ctx.lineWidth = Style.canvasBorderWidth; var len = Style.canvasBorderLen;
                            ctx.beginPath(); ctx.moveTo(0, len); ctx.lineTo(0, 0); ctx.lineTo(len, 0); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, 0); ctx.lineTo(width, 0); ctx.lineTo(width, len); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(0, height - len); ctx.lineTo(0, height); ctx.lineTo(len, height); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, height); ctx.lineTo(width, height); ctx.lineTo(width, height - len); ctx.stroke()
                        }
                    }
                }
            }
            MenuItem {
                text: "Odbij wertykalnie"; onTriggered: control.assignedFunction = "Odbij wertykalnie"
                implicitHeight: Style.menuItemHeight; arrow: null; indicator: null
                contentItem: Text { text: "Odbij wertykalnie"; font.pixelSize: Style.menuTextSize; font.weight: Style.fontWeight; color: Style.menuText; verticalAlignment: Text.AlignVCenter; }
                background: Rectangle {
                    color: parent.highlighted ? Style.menuItemHover : "transparent"
                    radius: Style.menuItemRadius; anchors.fill: parent; anchors.margins: Style.menuItemMargin
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d"); ctx.reset(); ctx.strokeStyle = Style.canvasBorderColor; ctx.lineWidth = Style.canvasBorderWidth; var len = Style.canvasBorderLen;
                            ctx.beginPath(); ctx.moveTo(0, len); ctx.lineTo(0, 0); ctx.lineTo(len, 0); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, 0); ctx.lineTo(width, 0); ctx.lineTo(width, len); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(0, height - len); ctx.lineTo(0, height); ctx.lineTo(len, height); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, height); ctx.lineTo(width, height); ctx.lineTo(width, height - len); ctx.stroke()
                        }
                    }
                }
            }
        }
        Menu {
            title: "Filtry"
            x: parent.width; y: 0
            background: Rectangle { implicitWidth: Style.menuWidth; color: Style.menuBackground; radius: Style.menuRadius; border.color: Style.menuBorder }
            MenuItem {
                text: "Krawędzie"; onTriggered: control.assignedFunction = "Krawędzie"
                implicitHeight: Style.menuItemHeight; arrow: null; indicator: null
                contentItem: Text { text: "Krawędzie"; font.pixelSize: Style.menuTextSize; font.weight: Style.fontWeight; color: Style.menuText; verticalAlignment: Text.AlignVCenter; }
                background: Rectangle {
                    color: parent.highlighted ? Style.menuItemHover : "transparent"
                    radius: Style.menuItemRadius; anchors.fill: parent; anchors.margins: Style.menuItemMargin
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d"); ctx.reset(); ctx.strokeStyle = Style.canvasBorderColor; ctx.lineWidth = Style.canvasBorderWidth; var len = Style.canvasBorderLen;
                            ctx.beginPath(); ctx.moveTo(0, len); ctx.lineTo(0, 0); ctx.lineTo(len, 0); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, 0); ctx.lineTo(width, 0); ctx.lineTo(width, len); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(0, height - len); ctx.lineTo(0, height); ctx.lineTo(len, height); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, height); ctx.lineTo(width, height); ctx.lineTo(width, height - len); ctx.stroke()
                        }
                    }
                }
            }
            MenuItem {
                text: "Szum"; onTriggered: control.assignedFunction = "Szum"
                implicitHeight: Style.menuItemHeight; arrow: null; indicator: null
                contentItem: Text { text: "Szum"; font.pixelSize: Style.menuTextSize; font.weight: Style.fontWeight; color: Style.menuText; verticalAlignment: Text.AlignVCenter; }
                background: Rectangle {
                    color: parent.highlighted ? Style.menuItemHover : "transparent"
                    radius: Style.menuItemRadius; anchors.fill: parent; anchors.margins: Style.menuItemMargin
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d"); ctx.reset(); ctx.strokeStyle = Style.canvasBorderColor; ctx.lineWidth = Style.canvasBorderWidth; var len = Style.canvasBorderLen;
                            ctx.beginPath(); ctx.moveTo(0, len); ctx.lineTo(0, 0); ctx.lineTo(len, 0); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, 0); ctx.lineTo(width, 0); ctx.lineTo(width, len); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(0, height - len); ctx.lineTo(0, height); ctx.lineTo(len, height); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, height); ctx.lineTo(width, height); ctx.lineTo(width, height - len); ctx.stroke()
                        }
                    }
                }
            }
            MenuItem {
                text: "Rozmycie kół"; onTriggered: control.assignedFunction = "Rozmycie kół"
                implicitHeight: Style.menuItemHeight; arrow: null; indicator: null
                contentItem: Text { text: "Rozmycie kół"; font.pixelSize: Style.menuTextSize; font.weight: Style.fontWeight; color: Style.menuText; verticalAlignment: Text.AlignVCenter; }
                background: Rectangle {
                    color: parent.highlighted ? Style.menuItemHover : "transparent"
                    radius: Style.menuItemRadius; anchors.fill: parent; anchors.margins: Style.menuItemMargin
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d"); ctx.reset(); ctx.strokeStyle = Style.canvasBorderColor; ctx.lineWidth = Style.canvasBorderWidth; var len = Style.canvasBorderLen;
                            ctx.beginPath(); ctx.moveTo(0, len); ctx.lineTo(0, 0); ctx.lineTo(len, 0); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, 0); ctx.lineTo(width, 0); ctx.lineTo(width, len); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(0, height - len); ctx.lineTo(0, height); ctx.lineTo(len, height); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, height); ctx.lineTo(width, height); ctx.lineTo(width, height - len); ctx.stroke()
                        }
                    }
                }
            }
            MenuItem {
                text: "Pixel Art"; onTriggered: control.assignedFunction = "Pixel Art"
                implicitHeight: Style.menuItemHeight; arrow: null; indicator: null
                contentItem: Text { text: "Pixel Art"; font.pixelSize: Style.menuTextSize; font.weight: Style.fontWeight; color: Style.menuText; verticalAlignment: Text.AlignVCenter; }
                background: Rectangle {
                    color: parent.highlighted ? Style.menuItemHover : "transparent"
                    radius: Style.menuItemRadius; anchors.fill: parent; anchors.margins: Style.menuItemMargin
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d"); ctx.reset(); ctx.strokeStyle = Style.canvasBorderColor; ctx.lineWidth = Style.canvasBorderWidth; var len = Style.canvasBorderLen;
                            ctx.beginPath(); ctx.moveTo(0, len); ctx.lineTo(0, 0); ctx.lineTo(len, 0); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, 0); ctx.lineTo(width, 0); ctx.lineTo(width, len); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(0, height - len); ctx.lineTo(0, height); ctx.lineTo(len, height); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, height); ctx.lineTo(width, height); ctx.lineTo(width, height - len); ctx.stroke()
                        }
                    }
                }
            }
            MenuItem {
                text: "Stary Film"; onTriggered: control.assignedFunction = "Stary Film"
                implicitHeight: Style.menuItemHeight; arrow: null; indicator: null
                contentItem: Text { text: "Stary Film"; font.pixelSize: Style.menuTextSize; font.weight: Style.fontWeight; color: Style.menuText; verticalAlignment: Text.AlignVCenter; }
                background: Rectangle {
                    color: parent.highlighted ? Style.menuItemHover : "transparent"
                    radius: Style.menuItemRadius; anchors.fill: parent; anchors.margins: Style.menuItemMargin
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d"); ctx.reset(); ctx.strokeStyle = Style.canvasBorderColor; ctx.lineWidth = Style.canvasBorderWidth; var len = Style.canvasBorderLen;
                            ctx.beginPath(); ctx.moveTo(0, len); ctx.lineTo(0, 0); ctx.lineTo(len, 0); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, 0); ctx.lineTo(width, 0); ctx.lineTo(width, len); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(0, height - len); ctx.lineTo(0, height); ctx.lineTo(len, height); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, height); ctx.lineTo(width, height); ctx.lineTo(width, height - len); ctx.stroke()
                        }
                    }
                }
            }
            MenuItem {
                text: "Negatyw"; onTriggered: control.assignedFunction = "Negatyw"
                implicitHeight: Style.menuItemHeight; arrow: null; indicator: null
                contentItem: Text { text: "Negatyw"; font.pixelSize: Style.menuTextSize; font.weight: Style.fontWeight; color: Style.menuText; verticalAlignment: Text.AlignVCenter; }
                background: Rectangle {
                    color: parent.highlighted ? Style.menuItemHover : "transparent"
                    radius: Style.menuItemRadius; anchors.fill: parent; anchors.margins: Style.menuItemMargin
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d"); ctx.reset(); ctx.strokeStyle = Style.canvasBorderColor; ctx.lineWidth = Style.canvasBorderWidth; var len = Style.canvasBorderLen;
                            ctx.beginPath(); ctx.moveTo(0, len); ctx.lineTo(0, 0); ctx.lineTo(len, 0); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, 0); ctx.lineTo(width, 0); ctx.lineTo(width, len); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(0, height - len); ctx.lineTo(0, height); ctx.lineTo(len, height); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, height); ctx.lineTo(width, height); ctx.lineTo(width, height - len); ctx.stroke()
                        }
                    }
                }
            }
            MenuItem {
                text: "Sepia Retro"; onTriggered: control.assignedFunction = "Sepia Retro"
                implicitHeight: Style.menuItemHeight; arrow: null; indicator: null
                contentItem: Text { text: "Sepia Retro"; font.pixelSize: Style.menuTextSize; font.weight: Style.fontWeight; color: Style.menuText; verticalAlignment: Text.AlignVCenter; }
                background: Rectangle {
                    color: parent.highlighted ? Style.menuItemHover : "transparent"
                    radius: Style.menuItemRadius; anchors.fill: parent; anchors.margins: Style.menuItemMargin
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d"); ctx.reset(); ctx.strokeStyle = Style.canvasBorderColor; ctx.lineWidth = Style.canvasBorderWidth; var len = Style.canvasBorderLen;
                            ctx.beginPath(); ctx.moveTo(0, len); ctx.lineTo(0, 0); ctx.lineTo(len, 0); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, 0); ctx.lineTo(width, 0); ctx.lineTo(width, len); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(0, height - len); ctx.lineTo(0, height); ctx.lineTo(len, height); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, height); ctx.lineTo(width, height); ctx.lineTo(width, height - len); ctx.stroke()
                        }
                    }
                }
            }
            MenuItem {
                text: "Progowanie"; onTriggered: control.assignedFunction = "Progowanie"
                implicitHeight: Style.menuItemHeight; arrow: null; indicator: null
                contentItem: Text { text: "Progowanie"; font.pixelSize: Style.menuTextSize; font.weight: Style.fontWeight; color: Style.menuText; verticalAlignment: Text.AlignVCenter; }
                background: Rectangle {
                    color: parent.highlighted ? Style.menuItemHover : "transparent"
                    radius: Style.menuItemRadius; anchors.fill: parent; anchors.margins: Style.menuItemMargin
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d"); ctx.reset(); ctx.strokeStyle = Style.canvasBorderColor; ctx.lineWidth = Style.canvasBorderWidth; var len = Style.canvasBorderLen;
                            ctx.beginPath(); ctx.moveTo(0, len); ctx.lineTo(0, 0); ctx.lineTo(len, 0); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, 0); ctx.lineTo(width, 0); ctx.lineTo(width, len); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(0, height - len); ctx.lineTo(0, height); ctx.lineTo(len, height); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, height); ctx.lineTo(width, height); ctx.lineTo(width, height - len); ctx.stroke()
                        }
                    }
                }
            }
            MenuItem {
                text: "Zimna Noc"; onTriggered: control.assignedFunction = "Zimna Noc"
                implicitHeight: Style.menuItemHeight; arrow: null; indicator: null
                contentItem: Text { text: "Zimna Noc"; font.pixelSize: Style.menuTextSize; font.weight: Style.fontWeight; color: Style.menuText; verticalAlignment: Text.AlignVCenter; }
                background: Rectangle {
                    color: parent.highlighted ? Style.menuItemHover : "transparent"
                    radius: Style.menuItemRadius; anchors.fill: parent; anchors.margins: Style.menuItemMargin
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d"); ctx.reset(); ctx.strokeStyle = Style.canvasBorderColor; ctx.lineWidth = Style.canvasBorderWidth; var len = Style.canvasBorderLen;
                            ctx.beginPath(); ctx.moveTo(0, len); ctx.lineTo(0, 0); ctx.lineTo(len, 0); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, 0); ctx.lineTo(width, 0); ctx.lineTo(width, len); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(0, height - len); ctx.lineTo(0, height); ctx.lineTo(len, height); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, height); ctx.lineTo(width, height); ctx.lineTo(width, height - len); ctx.stroke()
                        }
                    }
                }
            }
            MenuItem {
                text: "Ciepłe Lato"; onTriggered: control.assignedFunction = "Ciepłe Lato"
                implicitHeight: Style.menuItemHeight; arrow: null; indicator: null
                contentItem: Text { text: "Ciepłe Lato"; font.pixelSize: Style.menuTextSize; font.weight: Style.fontWeight; color: Style.menuText; verticalAlignment: Text.AlignVCenter; }
                background: Rectangle {
                    color: parent.highlighted ? Style.menuItemHover : "transparent"
                    radius: Style.menuItemRadius; anchors.fill: parent; anchors.margins: Style.menuItemMargin
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d"); ctx.reset(); ctx.strokeStyle = Style.canvasBorderColor; ctx.lineWidth = Style.canvasBorderWidth; var len = Style.canvasBorderLen;
                            ctx.beginPath(); ctx.moveTo(0, len); ctx.lineTo(0, 0); ctx.lineTo(len, 0); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, 0); ctx.lineTo(width, 0); ctx.lineTo(width, len); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(0, height - len); ctx.lineTo(0, height); ctx.lineTo(len, height); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, height); ctx.lineTo(width, height); ctx.lineTo(width, height - len); ctx.stroke()
                        }
                    }
                }
            }
        }
        Menu {
            title: "Rysunek"
            x: parent.width; y: 0
            background: Rectangle { implicitWidth: Style.menuWidth; color: Style.menuBackground; radius: Style.menuRadius; border.color: Style.menuBorder }
            MenuItem {
                text: "Ołówek"; onTriggered: control.assignedFunction = "Ołówek"
                implicitHeight: Style.menuItemHeight; arrow: null; indicator: null
                contentItem: Text { text: "Ołówek"; font.pixelSize: Style.menuTextSize; font.weight: Style.fontWeight; color: Style.menuText; verticalAlignment: Text.AlignVCenter; }
                background: Rectangle {
                    color: parent.highlighted ? Style.menuItemHover : "transparent"
                    radius: Style.menuItemRadius; anchors.fill: parent; anchors.margins: Style.menuItemMargin
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d"); ctx.reset(); ctx.strokeStyle = Style.canvasBorderColor; ctx.lineWidth = Style.canvasBorderWidth; var len = Style.canvasBorderLen;
                            ctx.beginPath(); ctx.moveTo(0, len); ctx.lineTo(0, 0); ctx.lineTo(len, 0); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, 0); ctx.lineTo(width, 0); ctx.lineTo(width, len); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(0, height - len); ctx.lineTo(0, height); ctx.lineTo(len, height); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, height); ctx.lineTo(width, height); ctx.lineTo(width, height - len); ctx.stroke()
                        }
                    }
                }
            }
            MenuItem {
                text: "Pióro"; onTriggered: control.assignedFunction = "Pióro"
                implicitHeight: Style.menuItemHeight; arrow: null; indicator: null
                contentItem: Text { text: "Pióro"; font.pixelSize: Style.menuTextSize; font.weight: Style.fontWeight; color: Style.menuText; verticalAlignment: Text.AlignVCenter; }
                background: Rectangle {
                    color: parent.highlighted ? Style.menuItemHover : "transparent"
                    radius: Style.menuItemRadius; anchors.fill: parent; anchors.margins: Style.menuItemMargin
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d"); ctx.reset(); ctx.strokeStyle = Style.canvasBorderColor; ctx.lineWidth = Style.canvasBorderWidth; var len = Style.canvasBorderLen;
                            ctx.beginPath(); ctx.moveTo(0, len); ctx.lineTo(0, 0); ctx.lineTo(len, 0); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, 0); ctx.lineTo(width, 0); ctx.lineTo(width, len); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(0, height - len); ctx.lineTo(0, height); ctx.lineTo(len, height); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, height); ctx.lineTo(width, height); ctx.lineTo(width, height - len); ctx.stroke()
                        }
                    }
                }
            }
            MenuItem {
                text: "Gumka"; onTriggered: control.assignedFunction = "Gumka"
                implicitHeight: Style.menuItemHeight; arrow: null; indicator: null
                contentItem: Text { text: "Gumka"; font.pixelSize: Style.menuTextSize; font.weight: Style.fontWeight; color: Style.menuText; verticalAlignment: Text.AlignVCenter; }
                background: Rectangle {
                    color: parent.highlighted ? Style.menuItemHover : "transparent"
                    radius: Style.menuItemRadius; anchors.fill: parent; anchors.margins: Style.menuItemMargin
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d"); ctx.reset(); ctx.strokeStyle = Style.canvasBorderColor; ctx.lineWidth = Style.canvasBorderWidth; var len = Style.canvasBorderLen;
                            ctx.beginPath(); ctx.moveTo(0, len); ctx.lineTo(0, 0); ctx.lineTo(len, 0); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, 0); ctx.lineTo(width, 0); ctx.lineTo(width, len); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(0, height - len); ctx.lineTo(0, height); ctx.lineTo(len, height); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, height); ctx.lineTo(width, height); ctx.lineTo(width, height - len); ctx.stroke()
                        }
                    }
                }
            }
            MenuItem {
                text: "Kolor"; onTriggered: control.assignedFunction = "Kolor"
                implicitHeight: Style.menuItemHeight; arrow: null; indicator: null
                contentItem: Text { text: "Kolor"; font.pixelSize: Style.menuTextSize; font.weight: Style.fontWeight; color: Style.menuText; verticalAlignment: Text.AlignVCenter; }
                background: Rectangle {
                    color: parent.highlighted ? Style.menuItemHover : "transparent"
                    radius: Style.menuItemRadius; anchors.fill: parent; anchors.margins: Style.menuItemMargin
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d"); ctx.reset(); ctx.strokeStyle = Style.canvasBorderColor; ctx.lineWidth = Style.canvasBorderWidth; var len = Style.canvasBorderLen;
                            ctx.beginPath(); ctx.moveTo(0, len); ctx.lineTo(0, 0); ctx.lineTo(len, 0); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, 0); ctx.lineTo(width, 0); ctx.lineTo(width, len); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(0, height - len); ctx.lineTo(0, height); ctx.lineTo(len, height); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, height); ctx.lineTo(width, height); ctx.lineTo(width, height - len); ctx.stroke()
                        }
                    }
                }
            }
            MenuItem {
                text: "Tekst"; onTriggered: control.assignedFunction = "Tekst"
                implicitHeight: Style.menuItemHeight; arrow: null; indicator: null
                contentItem: Text { text: "Tekst"; font.pixelSize: Style.menuTextSize; font.weight: Style.fontWeight; color: Style.menuText; verticalAlignment: Text.AlignVCenter; }
                background: Rectangle {
                    color: parent.highlighted ? Style.menuItemHover : "transparent"
                    radius: Style.menuItemRadius; anchors.fill: parent; anchors.margins: Style.menuItemMargin
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d"); ctx.reset(); ctx.strokeStyle = Style.canvasBorderColor; ctx.lineWidth = Style.canvasBorderWidth; var len = Style.canvasBorderLen;
                            ctx.beginPath(); ctx.moveTo(0, len); ctx.lineTo(0, 0); ctx.lineTo(len, 0); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, 0); ctx.lineTo(width, 0); ctx.lineTo(width, len); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(0, height - len); ctx.lineTo(0, height); ctx.lineTo(len, height); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, height); ctx.lineTo(width, height); ctx.lineTo(width, height - len); ctx.stroke()
                        }
                    }
                }
            }
            MenuItem {
                text: "Próbnik"; onTriggered: control.assignedFunction = "Próbnik"
                implicitHeight: Style.menuItemHeight; arrow: null; indicator: null
                contentItem: Text { text: "Próbnik"; font.pixelSize: Style.menuTextSize; font.weight: Style.fontWeight; color: Style.menuText; verticalAlignment: Text.AlignVCenter; }
                background: Rectangle {
                    color: parent.highlighted ? Style.menuItemHover : "transparent"
                    radius: Style.menuItemRadius; anchors.fill: parent; anchors.margins: Style.menuItemMargin
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d"); ctx.reset(); ctx.strokeStyle = Style.canvasBorderColor; ctx.lineWidth = Style.canvasBorderWidth; var len = Style.canvasBorderLen;
                            ctx.beginPath(); ctx.moveTo(0, len); ctx.lineTo(0, 0); ctx.lineTo(len, 0); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, 0); ctx.lineTo(width, 0); ctx.lineTo(width, len); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(0, height - len); ctx.lineTo(0, height); ctx.lineTo(len, height); ctx.stroke()
                            ctx.beginPath(); ctx.moveTo(width - len, height); ctx.lineTo(width, height); ctx.lineTo(width, height - len); ctx.stroke()
                        }
                    }
                }
            }
        }
        MenuSeparator {
            contentItem: Rectangle {
                implicitHeight: Style.menuSeparatorHeight
                color: Style.menuSeparatorColor
                anchors.leftMargin: 5
                anchors.rightMargin: 5
            }
        }
        MenuItem {
            id: clearItem
            text: "Wyczyść slot"
            enabled: control.assignedFunction !== ""
            onTriggered: control.assignedFunction = ""
            implicitHeight: Style.menuItemHeight
            arrow: null
            indicator: null
            contentItem: Text {
                text: "Wyczyść slot"
                font.pixelSize: Style.menuTextSize
                font.weight: Style.fontWeight
                color: control.assignedFunction !== "" ? Style.menuText : Style.disabledTextColor
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                color: clearItem.pressed ? Style.menuItemPressed : (clearItem.hovered ? Style.menuItemHover : "transparent")
                radius: Style.menuItemRadius
                anchors.fill: parent
                anchors.margins: Style.menuItemMargin
                Canvas {
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.strokeStyle = Style.canvasBorderColor
                        ctx.lineWidth = Style.canvasBorderWidth
                        var len = Style.canvasBorderLen
                        ctx.beginPath(); ctx.moveTo(0, len); ctx.lineTo(0, 0); ctx.lineTo(len, 0); ctx.stroke()
                        ctx.beginPath(); ctx.moveTo(width - len, 0); ctx.lineTo(width, 0); ctx.lineTo(width, len); ctx.stroke()
                        ctx.beginPath(); ctx.moveTo(0, height - len); ctx.lineTo(0, height); ctx.lineTo(len, height); ctx.stroke()
                        ctx.beginPath(); ctx.moveTo(width - len, height); ctx.lineTo(width, height); ctx.lineTo(width, height - len); ctx.stroke()
                    }
                }
            }
        }
    }
    background: Rectangle {
        color: control.pressed ? Style.customButtonPressed : (control.hovered ? Style.customButtonHover : Style.customButtonNormal)
        radius: Style.buttonRadius
        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.strokeStyle = Style.canvasBorderColor
                ctx.lineWidth = Style.canvasBorderWidth
                var len = Style.canvasBorderLen
                ctx.beginPath(); ctx.moveTo(0, len); ctx.lineTo(0, 0); ctx.lineTo(len, 0); ctx.stroke()
                ctx.beginPath(); ctx.moveTo(width - len, 0); ctx.lineTo(width, 0); ctx.lineTo(width, len); ctx.stroke()
                ctx.beginPath(); ctx.moveTo(0, height - len); ctx.lineTo(0, height); ctx.lineTo(len, height); ctx.stroke()
                ctx.beginPath(); ctx.moveTo(width - len, height); ctx.lineTo(width, height); ctx.lineTo(width, height - len); ctx.stroke()
            }
        }
    }
}
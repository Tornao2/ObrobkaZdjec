import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Basic

Button {
    id: control
    property string categoryTitle: "Kategoria"
    Layout.fillWidth: true
    Layout.preferredHeight: 70
    signal filterActivated(string filterName)
    contentItem: ColumnLayout {
        spacing: 3
        anchors.centerIn: parent
        Text {
            text: control.categoryTitle
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 16
            color: "black"
        }
    }

    background: Rectangle {
        color: control.pressed ? "#66000000" : (control.hovered ? "#22000000" : "transparent")
        Rectangle { anchors.top: parent.top; width: parent.width; height: 1; color: "black" }
        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "black" }
    }
    onClicked: filterMenu.popup()
    Menu {
        id: filterMenu
        y: control.height
        width: 200
        padding: 0
        background: Rectangle {
            implicitWidth: 320
            color: "#8E9191"
            radius: 4
            border.color: "black"
        }
        Repeater {
            model: {
                if (control.categoryTitle === "Filtry \nWyostrzania") return ["Krawędzie", "Szum"];
                if (control.categoryTitle === "Filtry \nRozmycia") return ["Rozmycie kół", "Pixel Art"];
                if (control.categoryTitle === "Filtry \nKreatywne") return ["Stary Film", "Negatyw"];
                if (control.categoryTitle === "Filtry \nKorekcyjne") return ["Progowanie", "Sepia Retro"];
                if (control.categoryTitle === "Filtry \nKoloru") return ["Zimna Noc", "Ciepłe Lato"];
                return [];
            }
            MenuItem {
                id: mItem
                text: modelData
                implicitWidth: 200
                implicitHeight: 70
                arrow: null
                indicator: null
                onTriggered: {
                    let propertyMap = {
                        "Krawędzie": "f_krawedzie",
                        "Szum": "f_szum",
                        "Rozmycie kół": "f_rozmycie_kol",
                        "Pixel Art": "f_pixel_art",
                        "Stary Film": "f_stary_film",
                        "Negatyw": "f_negatyw",
                        "Progowanie": "f_progowanie",
                        "Sepia Retro": "f_sepia_retro",
                        "Zimna Noc": "f_zimna_noc",
                        "Ciepłe Lato": "f_cieple_lato"
                    };
                    let targetProp = propertyMap[text];
                    filterScreen.activeProperty = targetProp;
                    control.filterActivated(text);
                }
                contentItem: Text {
                    text: mItem.text
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    color: "black"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: mItem.pressed ? "#66000000" : (mItem.highlighted ? "#22000000" : "transparent")
                    Rectangle {
                        anchors.top: parent.top
                        width: parent.width
                        height: 1
                        color: "black"
                    }
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: "black"
                    }
                }
            }
        }
    }
}
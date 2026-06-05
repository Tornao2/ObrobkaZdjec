import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Basic
import "../Style"
Button {
    id: control
    property string categoryTitle: "Kategoria"
    Layout.fillWidth: true
    Layout.preferredHeight: Style.filterButtonHeight
    signal filterActivated(string filterName)
    contentItem: ColumnLayout {
        spacing: Style.filterButtonSpacing
        anchors.centerIn: parent
        Text {
            text: control.categoryTitle
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Style.fontBodySize
            color: Style.baseTextColor
        }
    }
    background: Rectangle {
        color: control.pressed ? Style.baseInteractionPressed : (control.hovered ? Style.filterButtonHoverColor : "transparent")
        Rectangle { anchors.top: parent.top; width: parent.width; height: Style.filterButtonBorderHeight; color: Style.filterButtonBorderColor }
        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: Style.filterButtonBorderHeight; color: Style.filterButtonBorderColor }
    }
    onClicked: filterMenu.popup()
    Menu {
        id: filterMenu
        y: control.height
        width: Style.menuWidth
        padding: 0
        background: Rectangle {
            implicitWidth: Style.filterMenuWidth
            color: Style.dialogBackground
            radius: Style.filterMenuRadius
            border.color: Style.filterMenuBorderColor
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
                implicitWidth: Style.menuWidth
                implicitHeight: Style.filterMenuItemHeight
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
                    font.pixelSize: Style.fontBodySize
                    font.weight: Style.fontWeight
                    color: Style.baseTextColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: mItem.pressed ? Style.baseInteractionPressed : (mItem.highlighted ? Style.filterButtonHoverColor : "transparent")
                    Rectangle {
                        anchors.top: parent.top
                        width: parent.width
                        height: Style.filterButtonBorderHeight
                        color: Style.filterButtonBorderColor
                    }
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: Style.filterButtonBorderHeight
                        color: Style.filterButtonBorderColor
                    }
                }
            }
        }
    }
}
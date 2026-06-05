import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs
import "../Kontrolki"
import QtCore
import "../Style"
Rectangle {
    id: startScreen
    color: Style.dialogBackground
    readonly property int iconColumnWidth: Style.startScreenIconColumnWidth
    signal fileSelected(string filePath)
    function usunZHistorii(sciezka) {
        let sciezkaStr = String(sciezka);
        for (let i = 0; i < historyModel.count; i++) {
            if (historyModel.get(i).fullPath === sciezkaStr) {
                historyModel.remove(i);
                zapiszUstawienia();
                break;
            }
        }
    }
    Settings {
        id: appSettings
        category: "History"
        property var lastFiles: []
    }
    function zapiszUstawienia() {
        let paths = [];
        for (let i = 0; i < historyModel.count; i++) {
            paths.push(String(historyModel.get(i).fullPath));
        }
        appSettings.lastFiles = paths;
    }
    function dodajDoHistorii(sciezka) {
        let sciezkaStr = String(sciezka);
        let nazwa = sciezkaStr.split("/").pop();
        for (let i = 0; i < historyModel.count; i++) {
            if (historyModel.get(i).fullPath === sciezkaStr) return;
        }
        historyModel.insert(0, {
            "fileName": nazwa,
            "fullPath": sciezkaStr
        });
        zapiszUstawienia();
    }
    Component.onCompleted: {
        let savedPaths = appSettings.lastFiles;
        if (savedPaths) {
            for (let i = 0; i < savedPaths.length; i++) {
                let path = String(savedPaths[i]);
                let name = path.split("/").pop();
                historyModel.append({ "fileName": name, "fullPath": path });
            }
        }
    }
    FileDialog {
        id: fileOpenDialog
        title: "Wybierz zdjęcie do obróbki"
        nameFilters: ["Obrazy (*.jpg *.png *.jpeg)"]
        onAccepted: {
            let path = String(selectedFile)
            dodajDoHistorii(selectedFile)
            startScreen.fileSelected(path)
        }
    }
    ColumnLayout {
        anchors.top: parent.top
        anchors.topMargin: Style.startScreenTopMargin
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width * 0.8, 800)
        height: parent.height * 0.85
        spacing: Style.startScreenLayoutSpacing
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.startScreenOpenAreaHeight
            Rectangle {
                anchors.fill: parent
                anchors.margins: Style.startScreenOpenAreaBgMargin
                radius: Style.startScreenOpenAreaRadius
                color: openAreaMA.containsPress ? Style.dialogHeaderBackground : (openAreaMA.containsMouse ? Style.startScreenOpenAreaHover : "transparent")
            }
            RowLayout {
                id: openRow
                anchors.fill: parent
                spacing: Style.startScreenLayoutSpacing
                Item {
                    Layout.preferredWidth: startScreen.iconColumnWidth
                    Layout.fillHeight: true
                    CustomButton {
                        id: openButton
                        anchors.centerIn: parent
                        icon.source: "../Resources/open-in-window.svg"
                        iconSize: Style.startScreenOpenIconSize
                        background: Item {}
                    }
                }
                Text {
                    text: "Otwórz zdjęcie"
                    font.pixelSize: Style.startScreenOpenTextSize
                    font.weight: Style.startScreenOpenTextWeight
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignLeft
                    color: Style.tertiaryTextColor
                }
            }
            MouseArea {
                id: openAreaMA
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: fileOpenDialog.open()
            }
        }
        RowLayout {
            spacing: Style.startScreenLayoutSpacing
            Layout.alignment: Qt.AlignLeft
            Item {
                Layout.preferredWidth: startScreen.iconColumnWidth
                Layout.preferredHeight: Style.startScreenRecentIconSize
                Image {
                    source: Style.currentTheme === "dark" ? "../Resources/icons-light/arrow-email-forward.svg" :  "../Resources/arrow-email-forward.svg"
                    width: Style.startScreenRecentIconSize; height: Style.startScreenRecentIconSize
                    anchors.centerIn: parent
                    opacity: Style.startScreenRecentIconOpacity
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    sourceSize: Qt.size(width, height)
                    antialiasing: true
                    smooth: true
                }
            }
            Text {
                text: "Ostatnie pliki"
                font.pixelSize: Style.startScreenRecentTextSize
                font.weight: Style.startScreenRecentTextWeight
                color: Style.tertiaryTextColor
            }
        }
        ListView {
            id: historyList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            Layout.rightMargin: Style.startScreenLayoutSpacing
            model: ListModel {
                id: historyModel
            }
            delegate: Rectangle {
                id: delegateRoot
                height: Style.startScreenHistoryItemHeight
                width: historyList.width - historyList.rightMargin
                color: itemMA.containsMouse ? Style.startScreenOpenAreaHover : "transparent"
                radius: Style.startScreenHistoryItemRadius
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 0
                    anchors.rightMargin: Style.startScreenHistoryItemSpacing
                    spacing: Style.startScreenHistoryItemSpacing
                    Item {
                        Layout.preferredWidth: startScreen.iconColumnWidth
                        Layout.fillHeight: true
                        Rectangle {
                            width: Style.startScreenThumbSize; height: Style.startScreenThumbSize
                            anchors.centerIn: parent
                            radius: Style.startScreenThumbRadius; clip: true; color: Style.startScreenThumbBgColor
                            Image {
                                anchors.fill: parent
                                source: model.fullPath
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                onStatusChanged: {
                                    if (status === Image.Error) {
                                        historyModel.remove(index)
                                        startScreen.zapiszUstawienia()
                                    }
                                }
                            }
                        }
                    }
                    Text {
                        text: model.fileName
                        font.pixelSize: Style.fontTitleSize
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        color: Style.secondaryTextColor
                        verticalAlignment: Text.AlignVCenter
                    }
                    CustomButton {
                        id: deleteButton
                        Layout.preferredWidth: Style.startScreenDeleteButtonSize
                        Layout.preferredHeight: Style.startScreenDeleteButtonSize
                        icon.source: "../Resources/xmark.svg"
                        onClicked: {
                            historyModel.remove(index);
                            startScreen.zapiszUstawienia();
                        }
                        background: Rectangle {
                            color: deleteButton.hovered ? Style.startScreenDeleteButtonHoverColor : "transparent"
                            radius: Style.startScreenDeleteButtonRadius
                        }
                    }
                }
                MouseArea {
                    id: itemMA
                    anchors.fill: parent
                    anchors.rightMargin: 50
                    hoverEnabled: true
                    onClicked: {
                        startScreen.fileSelected(model.fullPath)
                    }
                }
            }
            ScrollBar.vertical: ScrollBar {
                id: scrollBar
                policy: ScrollBar.AsNeeded
                visible: historyList.contentHeight > historyList.height
                contentItem: Rectangle {
                    implicitWidth: Style.scrollBarWidth
                    radius: Style.scrollBarRadius
                    color: scrollBar.pressed ? Style.secondaryTextColor : Style.disabledTextColor
                }
            }
        }
    }
}
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs
import "../Kontrolki"
import QtCore

Rectangle {
    id: startScreen
    color: "#8E9191"
    readonly property int iconColumnWidth: 100
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
        anchors.topMargin: 120
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width * 0.8, 800)
        height: parent.height * 0.85
        spacing: 10
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            Rectangle {
                anchors.fill: parent
                anchors.margins: -10
                radius: 10
                color: openAreaMA.containsPress ? "#7A7D7D" : (openAreaMA.containsMouse ? "#6F7373" : "transparent")
            }
            RowLayout {
                id: openRow
                anchors.fill: parent
                spacing: 10
                Item {
                    Layout.preferredWidth: startScreen.iconColumnWidth
                    Layout.fillHeight: true
                    CustomButton {
                        id: openButton
                        anchors.centerIn: parent
                        icon.source: "../Resources/open-in-window.svg"
                        iconSize: 80
                        background: Item {}
                    }
                }
                Text {
                    text: "Otwórz zdjęcie"
                    font.pixelSize: 45
                    font.weight: Font.DemiBold
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignLeft
                    color: "#333"
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
            spacing: 10
            Layout.alignment: Qt.AlignLeft
            Item {
                Layout.preferredWidth: startScreen.iconColumnWidth
                Layout.preferredHeight: 64
                Image {
                    source: "../Resources/arrow-email-forward.svg"
                    width: 60; height: 60
                    anchors.centerIn: parent
                    opacity: 0.5
                    fillMode: Image.PreserveAspectFit
                }
            }
            Text {
                text: "Ostatnie pliki"
                font.pixelSize: 32
                font.weight: Font.DemiBold
                color: "#333"
            }
        }

        ListView {
            id: historyList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            rightMargin: scrollBar.visible ? 20 : 0
            model: ListModel {
                id: historyModel
            }
            delegate: Rectangle {
                id: delegateRoot
                height: 70
                width: historyList.width - historyList.rightMargin
                color: itemMA.containsMouse ? "#6F7373" : "transparent"
                radius: 5
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 0
                    anchors.rightMargin: 15
                    spacing: 15
                    Item {
                        Layout.preferredWidth: startScreen.iconColumnWidth
                        Layout.fillHeight: true
                        Rectangle {
                            width: 50; height: 50
                            anchors.centerIn: parent
                            radius: 6; clip: true; color: "#ccc"
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
                        font.pixelSize: 20
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        color: "#222"
                        verticalAlignment: Text.AlignVCenter
                    }
                    CustomButton {
                        id: deleteButton
                        Layout.preferredWidth: 35
                        Layout.preferredHeight: 35
                        icon.source: "../Resources/xmark.svg"
                        onClicked: {
                            historyModel.remove(index);
                            startScreen.zapiszUstawienia();
                        }
                        background: Rectangle {
                            color: deleteButton.hovered ? "#555" : "transparent"
                            radius: 5
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
                policy: historyList.contentHeight > historyList.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                contentItem: Rectangle {
                    implicitWidth: 8
                    radius: 4
                    color: scrollBar.pressed ? "#222" : "#555"
                }
            }
        }
    }
}


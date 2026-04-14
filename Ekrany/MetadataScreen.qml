import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../Kontrolki"

Rectangle {
    id: editorScreen
    color: "#8E9191"
    property var imageInfo: ({})
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        Rectangle {
            id: topBar
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "#8E9191"
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            Rectangle {
                Layout.preferredWidth: 150
                Layout.fillHeight: true
                color: "#8E9191"
                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 12
                    Button {
                        id: resetBtn
                        text: "Anuluj"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        contentItem: Text {
                            text: resetBtn.text
                            font.pixelSize: 20
                            font.weight: Font.Medium
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: resetBtn.pressed ? "#A34141" : (resetBtn.hovered ? "#C45454" : "#AB4141")
                            radius: 4
                        }
                        onClicked: mainStack.pop()
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        CustomButton {
                            id: undoBtn
                            Layout.fillWidth: true
                            Layout.preferredWidth: 50; Layout.preferredHeight: 50
                            icon.source: "../Resources/undo.svg"
                            iconSize: 35
                            tooltipText: "Cofnij"
                        }
                        CustomButton {
                            id: redoBtn
                            Layout.fillWidth: true
                            Layout.preferredWidth: 50; Layout.preferredHeight: 50
                            icon.source: "../Resources/undo.svg"
                            iconSize: 35
                            contentItem: Item {
                                Image {
                                    anchors.centerIn: parent
                                    width: redoBtn.iconSize
                                    height: redoBtn.iconSize
                                    sourceSize.width: redoBtn.iconSize
                                    sourceSize.height: redoBtn.iconSize
                                    source: redoBtn.icon.source
                                    mirror: true
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                }
                            }
                            tooltipText: "Ponów"
                        }
                        CustomButton {
                            id: actionBtn
                            Layout.fillWidth: true
                            Layout.preferredWidth: 50; Layout.preferredHeight: 50
                            icon.source: "../Resources/transition-right.svg"
                            iconSize: 35
                            tooltipText: "Pokaż zmiany"
                        }
                    }
                    Item { Layout.fillHeight: true }
                }
            }
            Rectangle {
                color: "#C0C3C4"
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 0
                Layout.alignment: Qt.AlignHCenter
                Item {
                    id: metadataField
                    anchors.fill: parent
                    anchors.margins: 20
                    Layout.alignment: Qt.AlignHCenter
                    Rectangle {
                        anchors.fill: parent
                        color: "#8E9191"
                        Layout.alignment: Qt.AlignHCenter
                        ScrollView {
                            anchors.fill: parent
                            anchors.margins: 20
                            contentWidth: availableWidth
                            clip: true
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                            Layout.alignment: Qt.AlignHCenter
                            ColumnLayout {
                                width: parent.width
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 15
                                MetadataEditRow {
                                    label: "Nazwa pliku:"
                                    value: imageInfo.name.substring(0, imageInfo.name.lastIndexOf('.'))
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 1000
                                }
                                MetadataEditRow {
                                    label: "Data wykonania:"
                                    value: imageInfo.date || ""
                                    inputMask: "0000-00-00 00:00;_"
                                    validator: RegularExpressionValidator {
                                        regularExpression: /^((19|20)\d\d)-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])\s([01][0-9]|2[0-3]):([0-5][0-9])$/
                                    }
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 1000
                                }
                                MetadataEditRow {
                                    label: "Ścieżka:"
                                    value: imageInfo.path || ""
                                    isReadOnly: true
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 1000
                                }
                                Rectangle {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 1000
                                    height: 1
                                    color: "#777"
                                }
                                MetadataEditRow {
                                    label: "Rozdzielczość:"
                                    value: (imageInfo.w || 0) + " x " + (imageInfo.h || 0)
                                    isReadOnly: true
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 1000
                                }
                                MetadataEditRow {
                                    label: "Dpi:"
                                    value: imageInfo.dpi || ""
                                    isReadOnly: true
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 1000
                                }
                                MetadataEditRow {
                                    label: "Głębia koloru:"
                                    value: imageInfo.depth || ""
                                    isReadOnly: true
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 1000
                                }
                                MetadataEditRow {
                                    label: "Rozmiar pliku:"
                                    value: imageInfo.fileSize || ""
                                    isReadOnly: true
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 1000
                                }
                                Rectangle {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 1000
                                    height: 1
                                    color: "#777"
                                }
                                ColumnLayout {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.fillWidth: true
                                    spacing: 5
                                    Text {
                                        text: "Opis zdjęcia:";
                                        font.pixelSize: 16;
                                        font.bold: true;
                                        color: "#222"
                                        Layout.alignment: Qt.AlignLeft
                                    }
                                    TextArea {
                                        id: descriptionArea
                                        text: imageInfo.description || ""
                                        color: "#222"
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 100
                                        Layout.preferredWidth: 1000
                                        placeholderText: "Kliknij, aby dodać opis..."
                                        placeholderTextColor: "#222"
                                        font.pixelSize: 16
                                        wrapMode: TextEdit.Wrap
                                        background: Rectangle {
                                            color: descriptionArea.activeFocus ? "white" : "transparent"
                                            border.color: descriptionArea.activeFocus ? "#3498db" : "transparent"
                                            radius: 4
                                        }
                                    }
                                }
                                Button {
                                    id: saveBtn
                                    text: "Zapisz zmiany"
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 160
                                    Layout.preferredHeight: 60
                                    Layout.topMargin: 10
                                    contentItem: Text {
                                        text: saveBtn.text
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: "#222"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    background: Rectangle {
                                        color: saveBtn.pressed ? "#2980b9" : (saveBtn.hovered ? "#5dade2" : "#3498db")
                                        radius: 6
                                    }
                                    onClicked: {
                                        mainStack.pop()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "#8E9191"
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "#A0A3A3"
            RowLayout {
                anchors.fill: parent
                CustomButton {
                    icon.source: "../Resources/info-circle.svg"
                    iconSize: 35
                    Layout.preferredWidth: 50; Layout.preferredHeight: 50
                    tooltipText: "Wyjdź z edycji"
                    onClicked: mainStack.pop()
                }
                Item { Layout.fillWidth: true }
                CustomButton {
                    icon.source: "../Resources/maximize.svg"
                    iconSize: 35
                    Layout.preferredWidth: 50; Layout.preferredHeight: 50
                    tooltipText: "Włącz tryb pełnego ekranu"
                }
            }
        }
    }
}
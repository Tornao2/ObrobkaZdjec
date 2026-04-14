import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../Kontrolki"

Rectangle {
    id: editorScreen
    color: "#8E9191"
    property string imagePath: ""
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        Rectangle {
            id: topBar
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "#8E9191"
            Text {
                text: editorScreen.imagePath.split("/").pop()
                anchors.centerIn: parent
                font.pixelSize: 20; color: "black"
            }
            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                CustomButton {
                    id: deleteBtn
                    Layout.preferredWidth: 50; Layout.preferredHeight: 50
                    icon.source: "../Resources/trash.svg"
                    iconSize: 35
                    tooltipText: "Usuń"
                }
                CustomButton {
                    id: printBtn
                    Layout.preferredWidth: 50; Layout.preferredHeight: 50
                    icon.source: "../Resources/printer.svg"
                    iconSize: 35
                    tooltipText: "Drukuj"
                }
                CustomButton {
                    id: copyBtn
                    Layout.preferredWidth: 50; Layout.preferredHeight: 50
                    icon.source: "../Resources/copy.svg"
                    iconSize: 35
                    tooltipText: "Kopiuj"
                }
                CustomButton {
                    id: importBtn
                    Layout.preferredWidth: 50; Layout.preferredHeight: 50
                    icon.source: "../Resources/download.svg"
                    iconSize: 35
                    tooltipText: "Importuj"
                }
                CustomButton {
                    id: saveBtn
                    Layout.preferredWidth: 50; Layout.preferredHeight: 50
                    icon.source: "../Resources/floppy-disk.svg"
                    iconSize: 35
                    tooltipText: "Zapisz"
                }
            }
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
                        text: "Reset"
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
                    CornerButton {  }
                    CornerButton {  }
                    CornerButton {  }
                    CornerButton {  }
                    CornerButton {  }
                    CornerButton {  }
                    CornerButton {  }
                    CornerButton {  }
                    CornerButton {  }
                    CornerButton {  }
                    CornerButton {  }
                    CornerButton {  }
                    Item { Layout.fillHeight: true }
                }
            }
            Rectangle {
                color: "#C0C3C4"
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 0
                Item {
                    id: imageContainer
                    anchors.fill: parent
                    anchors.margins: 20
                    Image {
                        id: photo
                        source: editorScreen.imagePath
                        asynchronous: true
                        anchors.centerIn: parent
                        width: Math.min(implicitWidth, imageContainer.width)
                        height: Math.min(implicitHeight, imageContainer.height)
                        fillMode: Image.PreserveAspectFit
                    }
                    Image {
                        id: arrowLeft
                        source: "../Resources/arrow-left.svg"
                        sourceSize: Qt.size(35, 35)
                        opacity: 0.6
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: -10
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: arrowLeft.opacity = 1.0
                            onExited: arrowLeft.opacity = 0.6
                        }
                    }
                    Image {
                        id: arrowRight
                        source: "../Resources/arrow-right.svg"
                        sourceSize: Qt.size(35, 35)
                        opacity: 0.6
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: -10
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: arrowRight.opacity = 1.0
                            onExited: arrowRight.opacity = 0.6
                        }
                    }
                }
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "#8E9191"
            RowLayout {
                anchors.centerIn: parent
                CustomButton {
                    id: cropBtn
                    Layout.preferredHeight: 50
                    Layout.preferredWidth: rowContent.childrenRect.width + rowContent.leftPadding + rowContent.rightPadding
                    contentItem: Row {
                        id: rowContent
                        spacing: 10
                        leftPadding: 15
                        rightPadding: 15
                        Image {
                            source: "../Resources/crop.svg"
                            width: 28; height: 28
                            sourceSize: Qt.size(28, 28)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Manipulacja wymiarami"
                            font.pixelSize: 20
                            color: "black"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    onClicked: {
                        mainStack.push("ManipulationScreen.qml", { "imageSource": imagePath })
                    }
                }
                CustomButton {
                    id: adjustBtn
                    Layout.preferredHeight: 50
                    Layout.preferredWidth: rowContent2.childrenRect.width + rowContent2.leftPadding + rowContent2.rightPadding
                    Layout.leftMargin: 100
                    contentItem: Row {
                        id: rowContent2
                        spacing: 10
                        leftPadding: 15
                        rightPadding: 15
                        Image {
                            source: "../Resources/sun-light.svg"
                            width: 28; height: 28
                            sourceSize: Qt.size(28, 28)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Korekta"
                            font.pixelSize: 20
                            color: "black"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                CustomButton {
                    id: filtersBtn
                    Layout.preferredHeight: 50
                    Layout.preferredWidth: rowContent3.childrenRect.width + rowContent3.leftPadding + rowContent3.rightPadding
                    Layout.leftMargin: 100
                    contentItem: Row {
                        id: rowContent3
                        spacing: 10
                        leftPadding: 15
                        rightPadding: 15
                        Image {
                            source: "../Resources/color-filter.svg"
                            width: 28; height: 28
                            sourceSize: Qt.size(28, 28)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Filtry"
                            font.pixelSize: 20
                            color: "black"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                CustomButton {
                    id: drawBtn
                    Layout.leftMargin: 100
                    Layout.preferredHeight: 50
                    Layout.preferredWidth: rowContent4.childrenRect.width + rowContent4.leftPadding + rowContent4.rightPadding
                    contentItem: Row {
                        id: rowContent4
                        spacing: 10
                        leftPadding: 15
                        rightPadding: 15
                        Image {
                            source: "../Resources/edit-pencil.svg"
                            width: 28; height: 28
                            sourceSize: Qt.size(28, 28)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Rysunek"
                            font.pixelSize: 20
                            color: "black"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
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
                    tooltipText: "Edytuj metadane"
                    onClicked: {
                            let imgData = {
                                "path": editorScreen.imagePath,
                                "name": editorScreen.imagePath.split("/").pop(),
                                "w": photo.implicitWidth,
                                "h": photo.implicitHeight,
                                "fileSize": "3.2 MB",
                                "depth": "24-bit",
                                "date": "2024-05-12 14:30",
                                "dpi" : "300 dpi",
                                "description" : "Example description"
                            }
                            mainStack.push("MetadataScreen.qml", { "imageInfo": imgData })
                    }
                }
                Row {
                    spacing: 5
                    Layout.alignment: Qt.AlignVCenter
                    Image {
                        source: "../Resources/crop.svg"
                        width: 28; height: 28
                        sourceSize: Qt.size(28, 28)
                        fillMode: Image.PreserveAspectFit
                        opacity: 0.7
                    }
                    Text {
                        text: photo.implicitWidth + " x " + photo.implicitHeight
                        font.pixelSize: 20
                        color: "#222"
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                Row {
                    Layout.leftMargin: 10
                    spacing: 5
                    Layout.alignment: Qt.AlignVCenter
                    Image {
                        source: "../Resources/floppy-disk.svg"
                        width: 28; height: 28
                        sourceSize: Qt.size(28, 28)
                        fillMode: Image.PreserveAspectFit
                        opacity: 0.7
                    }
                    Text {
                        text: "3.2MB"
                        font.pixelSize: 20
                        color: "#222"
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                Item { Layout.fillWidth: true }
                CustomButton {
                    icon.source: "../Resources/drag-hand-gesture.svg"
                    iconSize: 35
                    Layout.preferredWidth: 50; Layout.preferredHeight: 50
                    tooltipText: "Włącz tryb przesuwania zdjęcia"
                }
                RowLayout {
                    spacing: 5
                    CustomButton {
                        icon.source: "../Resources/zoom-in.svg"
                        iconSize: 35
                        Layout.preferredWidth: 50; Layout.preferredHeight: 50
                        onClicked: zoomSlider.value = Math.max(zoomSlider.from, zoomSlider.value - 0.2)
                        tooltipText: "Przybliż zdjęcie"
                    }
                    Slider {
                        id: zoomSlider
                        from: 0.1
                        to: 3.0
                        value: 1.0
                        Layout.preferredWidth: 120
                        ToolTip.visible: pressed
                        ToolTip.delay: 0
                        ToolTip.text: Math.round(value * 100) + "%"
                        background: Rectangle {
                            x: zoomSlider.leftPadding
                            y: zoomSlider.topPadding + zoomSlider.availableHeight / 2 - height / 2
                            implicitWidth: 120
                            implicitHeight: 6
                            width: zoomSlider.availableWidth
                            height: implicitHeight
                            radius: 2
                            color: "#555"
                        }
                        handle: Rectangle {
                            x: zoomSlider.leftPadding + zoomSlider.visualPosition * (zoomSlider.availableWidth - width)
                            y: zoomSlider.topPadding + zoomSlider.availableHeight / 2 - height / 2
                            implicitWidth: 16
                            implicitHeight: 16
                            radius: 8
                            color: "white"
                            border.color: "#333"
                        }
                    }
                    CustomButton {
                        icon.source: "../Resources/zoom-out.svg"
                        iconSize: 35
                        Layout.preferredWidth: 50; Layout.preferredHeight: 50
                        onClicked: zoomSlider.value = Math.min(zoomSlider.to, zoomSlider.value + 0.2)
                        tooltipText: "Oddal zdjęcie"
                    }
                }
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
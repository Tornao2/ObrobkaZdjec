import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../Kontrolki"

Rectangle {
    id: editorScreen
    color: "#8E9191"
    property string imageSource: ""
    readonly property real imgX: photo.x + (photo.width - photo.paintedWidth) / 2
    readonly property real imgY: photo.y + (photo.height - photo.paintedHeight) / 2
    readonly property real imgW: photo.paintedWidth
    readonly property real imgH: photo.paintedHeight
    property real cropX: imgX
    property real cropY: imgY
    property real cropWidth: imgW
    property real cropHeight: imgH
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        Rectangle {
            id: topBar
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "#8E9191"
            Text {
                text: editorScreen.imageSource.split("/").pop()
                anchors.centerIn: parent
                font.pixelSize: 20; color: "black"
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
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 2
                        Slider {
                            id: rotationSlider
                            from: -180
                            to: 180
                            value: 0
                            stepSize: 10
                            orientation: Qt.Vertical
                            snapMode: Slider.SnapAlways
                            Layout.preferredHeight: 475
                            Layout.alignment: Qt.AlignCenter
                            Layout.fillWidth: true
                            ToolTip {
                                parent: rotationSlider.handle
                                visible: rotationSlider.pressed
                                text: Math.round(rotationSlider.value) + "°"
                            }
                            background: Rectangle {
                                implicitWidth: 40
                                implicitHeight: 270
                                x: rotationSlider.leftPadding + rotationSlider.availableWidth / 2 - width / 2
                                y: rotationSlider.topPadding
                                width: implicitWidth
                                height: rotationSlider.availableHeight
                                color: "transparent"
                                Rectangle {
                                    width: 4
                                    height: parent.height
                                    anchors.centerIn: parent
                                    color: "#444"
                                    radius: 2
                                }
                                Repeater {
                                    model: 11
                                    delegate: Rectangle {
                                        property int angle: -150 + (index * 30)
                                        width: angle === 0 ? 25 : 15
                                        height: angle === 0 ? 5 : 2
                                        color: angle === 0 ? "black" : "white"
                                        x: (parent.width - width) / 2
                                        y: ((index+1) / 12) * parent.height - height / 2
                                    }
                                }
                            }
                            handle: Rectangle {
                                y: rotationSlider.topPadding + rotationSlider.visualPosition * (rotationSlider.availableHeight - height)
                                x: rotationSlider.leftPadding + rotationSlider.availableWidth / 2 - width / 2
                                implicitWidth: 24
                                implicitHeight: 24
                                radius: 12
                                color: rotationSlider.pressed ? "#f0f0f0" : "#ffffff"
                                border.color: "#333"
                            }
                        }
                    }
                    GridLayout {
                        columns: 2
                        rows: 2
                        Layout.fillWidth: true
                        columnSpacing: 10
                        rowSpacing: 10
                        CustomButton {
                            tooltipText: "Odbij horyzontalnie"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 45
                            icon.source: "../Resources/arrow-separate.svg"
                        }
                        CustomButton {
                            tooltipText: "Odbij wertykalnie"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 45
                            icon.source: "../Resources/arrow-separate-vertical.svg"
                        }
                        CustomButton {
                            tooltipText: "Przekręć o 90 stopni w lewo"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 45
                            icon.source: "../Resources/rotate-camera-left.svg"
                        }
                        CustomButton {
                            tooltipText: "Przekręć o 90 stopni w prawo"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 45
                            icon.source: "../Resources/rotate-camera-right.svg"
                        }
                    }
                    Item { Layout.fillHeight: true }
                    Button {
                        id: confirmBtn
                        text: "Zatwierdź"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        Layout.bottomMargin: 10
                        contentItem: Text {
                            text: confirmBtn.text
                            font.pixelSize: 18
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: confirmBtn.pressed ? "#217dbb" : (confirmBtn.hovered ? "#3498db" : "#2980b9")
                            radius: 4
                        }
                        onClicked: {
                            mainStack.pop()
                        }
                    }
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
                        source: imageSource
                        anchors.centerIn: parent
                        width: Math.min(implicitWidth, imageContainer.width)
                        height: Math.min(implicitHeight, imageContainer.height)
                        fillMode: Image.PreserveAspectFit
                        rotation: rotationSlider.value
                    }
                    Rectangle {
                        x: imgX; y: imgY; width: cropRect.x - imgX; height: imgH
                        color: "#80000000"; visible: width > 0
                    }
                    Rectangle {
                        x: cropRect.x + cropRect.width; y: imgY
                        width: (imgX + imgW) - (cropRect.x + cropRect.width)
                        height: imgH; color: "#80000000"; visible: width > 0
                    }
                    Rectangle {
                        x: cropRect.x; y: imgY; width: cropRect.width
                        height: cropRect.y - imgY; color: "#80000000"; visible: height > 0
                    }
                    Rectangle {
                        x: cropRect.x; y: cropRect.y + cropRect.height; width: cropRect.width
                        height: (imgY + imgH) - (cropRect.y + cropRect.height)
                        color: "#80000000"; visible: height > 0
                    }
                    Rectangle {
                        id: cropRect
                        x: cropX
                        y: cropY
                        width: cropWidth
                        height: cropHeight
                        color: "transparent"
                        border.color: "black"
                        border.width: 2
                        Rectangle {
                            width: 30; height: 30
                            color: "black"; radius: 15
                            anchors.right: parent.right; anchors.bottom: parent.bottom
                            anchors.margins: -15
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.SizeFDiagCursor
                                onPositionChanged: {
                                    if (pressed) {
                                        let maxAllowedW = (imgX + imgW) - cropRect.x
                                        let maxAllowedH = (imgY + imgH) - cropRect.y
                                        cropWidth = Math.min(maxAllowedW, Math.max(50, cropRect.width + mouseX))
                                        cropHeight = Math.min(maxAllowedH, Math.max(50, cropRect.height + mouseY))
                                    }
                                }
                            }
                        }
                        Rectangle {
                            width: 30; height: 30
                            color: "black"; radius: 15
                            anchors.left: parent.left; anchors.top: parent.top
                            anchors.margins: -15
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.SizeAllCursor
                                onPositionChanged: {
                                    if (pressed) {
                                        let newX = cropX + mouseX
                                        let newY = cropY + mouseY
                                        let clampedX = Math.max(imgX, Math.min(newX, cropX + cropWidth - 50))
                                        let clampedY = Math.max(imgY, Math.min(newY, cropY + cropHeight - 50))
                                        let diffX = clampedX - cropX
                                        let diffY = clampedY - cropY
                                        cropWidth -= diffX
                                        cropHeight -= diffY
                                        cropX = clampedX
                                        cropY = clampedY
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
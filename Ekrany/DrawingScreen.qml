import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import "../Kontrolki"

Rectangle {
    id: drawingScreen
    color: "#8E9191"
    property var imageInfo: ({})
    property var currentMetadata: ({})
    property var originalMetadata: currentMetadata
    property bool panMode: false
    property string selectedTool: ""
    property var toolOptions: {
                            "color" : "red",
                            "pencilSize": 5,
                            "pencilOpacity": 1,
                            "penSize": 3,
                            "penOpacity": 1,
                            "penSmoothing": 0.3,
                            "eraserSize": 5,
                            "textSize": 32,
                            "textOpacity": 1,
                            "textSpacing": 0,
                            "currentText": "Wpisz"
                               }
    signal drawingFinished(var finalInfo)
    property string initialCanvasData: ""
    function clone(obj) { return JSON.parse(JSON.stringify(obj)); }
    Component.onCompleted: {
        currentMetadata = clone(imageInfo);
        originalMetadata = clone(imageInfo);
        photo.sourceClipRect = Qt.rect(
            currentMetadata.crop.x, currentMetadata.crop.y,
            currentMetadata.crop.w, currentMetadata.crop.h
        );
        zoomToFit();
    }
    function stripExtension(fileName) {
        if (!fileName) return "";
        return fileName.indexOf('.') !== -1 ? fileName.substring(0, fileName.lastIndexOf('.')) : fileName;
    }
    function finishDrawing() {
        let finalImage = drawingCanvas.toDataURL("image/png");
        let finalData = {
            "image": finalImage,
            "metadata": clone(currentMetadata)
        };
        drawingFinished(finalData);
        mainStack.pop()
    }
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        Rectangle {
            id: topBar
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "#8E9191"
            Text {
                text: currentMetadata.name
                anchors.centerIn: parent
                font.pixelSize: 20; color: "black"
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            Rectangle {
                Layout.leftMargin: 0
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
                        onClicked: {
                            mainStack.pop()
                        }
                    }
                    Grid {
                        id: buttonsGrid
                        columns: 2
                        spacing: 10
                        CustomButton {
                            id: pencilBtn
                            Layout.preferredWidth: 60; Layout.preferredHeight: 60
                            iconSize: 50
                            icon.source: "../Resources/edit-pencil.svg"
                            tooltipText: "Ołówek"
                            isSelected: selectedTool == "Pencil"
                            onClicked: {
                                selectedTool = "Pencil"
                                panMode = false
                            }
                        }
                        CustomButton {
                            id: textBtn
                            Layout.preferredWidth: 60; Layout.preferredHeight: 60
                            iconSize: 50
                            icon.source: "../Resources/text.svg"
                            tooltipText: "Tekst"
                            isSelected: selectedTool == "Text"
                            onClicked: {
                                selectedTool = "Text"
                                panMode = false
                            }
                        }
                        CustomButton {
                            id: penBtn
                            Layout.preferredWidth: 60; Layout.preferredHeight: 60
                            iconSize: 50
                            icon.source: "../Resources/design-nib.svg"
                            tooltipText: "Pióro"
                            isSelected: selectedTool == "Pen"
                            onClicked: {
                                selectedTool = "Pen"
                                panMode = false
                            }
                        }
                        CustomButton {
                            id: pickerBtn
                            Layout.preferredWidth: 60; Layout.preferredHeight: 60
                            iconSize: 50
                            icon.source: "../Resources/color-picker.svg"
                            tooltipText: "Wybierz kolor ze zdjęcia"
                            isSelected: selectedTool == "Picker"
                            onClicked: {
                                selectedTool = "Picker"
                                panMode = false
                            }
                        }
                        CustomButton {
                            id: eraserBtn
                            Layout.preferredWidth: 60; Layout.preferredHeight: 60
                            iconSize: 50
                            icon.source: "../Resources/erase.svg"
                            tooltipText: "Wymaż"
                            isSelected: selectedTool == "Eraser"
                            onClicked: {
                                selectedTool = "Eraser"
                                panMode = false
                            }
                        }
                        CustomButton {
                            id: colorBtn
                            Layout.preferredWidth: 60; Layout.preferredHeight: 60
                            iconSize: 50
                            icon.source: "../Resources/circle.svg"
                            tooltipText: "Wybierz kolor"
                            isSelected: selectedTool == "Color"
                            previewColor: toolOptions.color || "red"
                            onClicked: {
                                selectedTool = "Color"
                                panMode = false
                            }
                        }
                    }
                    Rectangle {
                        id: divider
                        width: 130
                        height: 2
                        color: "black"
                    }
                    ColumnLayout {
                        spacing: 10
                        Layout.fillWidth: true
                        Layout.preferredWidth: 130
                        visible: selectedTool !== ""
                        ColumnLayout {
                            spacing: 15
                            Layout.fillWidth: true
                            Layout.preferredWidth: 130
                            visible: selectedTool == "Pencil"
                            Text {
                                text: "Ustawienia \nołówka"
                                font.pixelSize: 22
                                font.weight: Font.Medium
                                font.bold: true
                                color: "black"
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Text {
                                text: "Grubość: " + pencilSizeSlider.value.toFixed(0)
                                font.pixelSize: 15
                                color: "black"
                                Layout.alignment: Qt.AlignCenter
                            }
                            Slider {
                                id: pencilSizeSlider
                                from: 1
                                to: 50
                                stepSize: 1
                                value: toolOptions.pencilSize || 5
                                Layout.preferredWidth: 130
                                Layout.preferredHeight: 30
                                Layout.alignment: Qt.AlignCenter
                                background: Rectangle {
                                    x: pencilSizeSlider.leftPadding
                                    y: pencilSizeSlider.topPadding + pencilSizeSlider.availableHeight / 2 - height / 2
                                    implicitHeight: 8
                                    width: pencilSizeSlider.availableWidth
                                    height: implicitHeight
                                    radius: 3
                                    color: "#555555"
                                }
                                handle: Rectangle {
                                    x: pencilSizeSlider.leftPadding + pencilSizeSlider.visualPosition * (pencilSizeSlider.availableWidth - width)
                                    y: pencilSizeSlider.topPadding + pencilSizeSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 22
                                    implicitHeight: 22
                                    radius: 11
                                    color: "white"
                                    border.color: "#333"
                                    border.width: 1
                                }
                                onMoved: {
                                    let options = toolOptions
                                    options.pencilSize = value
                                    toolOptions = options
                                }
                            }
                            Text {
                                text: "Krycie: " + (pencilOpacitySlider.value * 100).toFixed(0) + "%"
                                font.pixelSize: 15
                                color: "black"
                                Layout.alignment: Qt.AlignCenter
                            }
                            Slider {
                                id: pencilOpacitySlider
                                from: 0
                                to: 1
                                value: toolOptions.pencilOpacity || 1.0
                                Layout.preferredWidth: 130
                                Layout.preferredHeight: 30
                                Layout.alignment: Qt.AlignCenter
                                background: Rectangle {
                                    x: pencilOpacitySlider.leftPadding
                                    y: pencilOpacitySlider.topPadding + pencilOpacitySlider.availableHeight / 2 - height / 2
                                    implicitHeight: 8
                                    width: pencilOpacitySlider.availableWidth
                                    height: implicitHeight
                                    radius: 3
                                    color: "#555555"
                                }
                                handle: Rectangle {
                                    x: pencilOpacitySlider.leftPadding + pencilOpacitySlider.visualPosition * (pencilOpacitySlider.availableWidth - width)
                                    y: pencilOpacitySlider.topPadding + pencilOpacitySlider.availableHeight / 2 - height / 2
                                    implicitWidth: 22
                                    implicitHeight: 22
                                    radius: 11
                                    color: "white"
                                    border.color: "#333"
                                    border.width: 1
                                }
                                onMoved: {
                                    let options = toolOptions
                                    options.pencilOpacity = value
                                    toolOptions = options
                                }
                            }
                        }
                        ColumnLayout {
                            spacing: 15
                            Layout.fillWidth: true
                            Layout.preferredWidth: 130
                            visible: selectedTool == "Pen"
                            Text {
                                text: "Ustawienia \npióra"
                                font.pixelSize: 22
                                font.bold: true
                                font.weight: Font.Medium
                                color: "black"
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Text {
                                text: "Szerokość: " + penSizeSlider.value.toFixed(0)
                                font.pixelSize: 15
                                color: "black"
                                Layout.alignment: Qt.AlignCenter
                            }
                            Slider {
                                id: penSizeSlider
                                from: 1
                                to: 50
                                stepSize: 1
                                value: toolOptions.penSize || 3
                                Layout.preferredWidth: 130
                                Layout.preferredHeight: 30
                                Layout.alignment: Qt.AlignCenter
                                background: Rectangle {
                                    x: penSizeSlider.leftPadding
                                    y: penSizeSlider.topPadding + penSizeSlider.availableHeight / 2 - height / 2
                                    implicitHeight: 8
                                    width: penSizeSlider.availableWidth
                                    height: implicitHeight
                                    radius: 3
                                    color: "#555555"
                                }
                                handle: Rectangle {
                                    x: penSizeSlider.leftPadding + penSizeSlider.visualPosition * (penSizeSlider.availableWidth - width)
                                    y: penSizeSlider.topPadding + penSizeSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 22
                                    implicitHeight: 22
                                    radius: 11
                                    color: "white"
                                    border.color: "#333"
                                    border.width: 1
                                }
                                onMoved: {
                                    let options = toolOptions
                                    options.penSize = value
                                    toolOptions = options
                                }
                            }
                            Text {
                                text: "Wygładzanie: " + (penSmoothingSlider.value * 100).toFixed(0) + "%"
                                font.pixelSize: 15
                                color: "black"
                                Layout.alignment: Qt.AlignCenter
                            }
                            Slider {
                                id: penSmoothingSlider
                                from: 0
                                to: 0.99
                                value: toolOptions.penSmoothing || 0.5
                                Layout.preferredWidth: 130
                                Layout.preferredHeight: 30
                                Layout.alignment: Qt.AlignCenter
                                background: Rectangle {
                                    x: penSmoothingSlider.leftPadding
                                    y: penSmoothingSlider.topPadding + penSmoothingSlider.availableHeight / 2 - height / 2
                                    implicitHeight: 8
                                    width: penSmoothingSlider.availableWidth
                                    height: implicitHeight
                                    radius: 3
                                    color: "#555555"
                                }
                                handle: Rectangle {
                                    x: penSmoothingSlider.leftPadding + penSmoothingSlider.visualPosition * (penSmoothingSlider.availableWidth - width)
                                    y: penSmoothingSlider.topPadding + penSmoothingSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 22
                                    implicitHeight: 22
                                    radius: 11
                                    color: "white"
                                    border.color: "#333"
                                    border.width: 1
                                }
                                onMoved: {
                                    let options = toolOptions
                                    options.penSmoothing = value
                                    toolOptions = options
                                }
                            }
                            Text {
                                text: "Krycie: " + (penOpacitySlider.value * 100).toFixed(0) + "%"
                                font.pixelSize: 15
                                color: "black"
                                Layout.alignment: Qt.AlignCenter
                            }
                            Slider {
                                id: penOpacitySlider
                                from: 0
                                to: 1
                                value: toolOptions.penOpacity || 1.0
                                Layout.preferredWidth: 130
                                Layout.preferredHeight: 30
                                Layout.alignment: Qt.AlignCenter
                                background: Rectangle {
                                    x: penOpacitySlider.leftPadding
                                    y: penOpacitySlider.topPadding + penOpacitySlider.availableHeight / 2 - height / 2
                                    implicitHeight: 8
                                    width: penOpacitySlider.availableWidth
                                    height: implicitHeight
                                    radius: 3
                                    color: "#555555"
                                }
                                handle: Rectangle {
                                    x: penOpacitySlider.leftPadding + penOpacitySlider.visualPosition * (penOpacitySlider.availableWidth - width)
                                    y: penOpacitySlider.topPadding + penOpacitySlider.availableHeight / 2 - height / 2
                                    implicitWidth: 22
                                    implicitHeight: 22
                                    radius: 11
                                    color: "white"
                                    border.color: "#333"
                                    border.width: 1
                                }
                                onMoved: {
                                    let options = toolOptions
                                    options.penOpacity = value
                                    toolOptions = options
                                }
                            }
                        }
                        ColumnLayout {
                            spacing: 15
                            Layout.fillWidth: true
                            Layout.preferredWidth: 130
                            visible: selectedTool == "Eraser"
                            Text {
                                text: "Ustawienia \ngumki"
                                font.pixelSize: 22
                                font.weight: Font.Medium
                                font.bold: true
                                color: "black"
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Text {
                                text: "Grubość: " + eraserSizeSlider.value.toFixed(0)
                                font.pixelSize: 15
                                color: "black"
                                Layout.alignment: Qt.AlignCenter
                            }
                            Slider {
                                id: eraserSizeSlider
                                from: 1
                                to: 50
                                stepSize: 1
                                value: toolOptions.eraserSize || 5
                                Layout.preferredWidth: 130
                                Layout.preferredHeight: 30
                                Layout.alignment: Qt.AlignCenter
                                background: Rectangle {
                                    x: eraserSizeSlider.leftPadding
                                    y: eraserSizeSlider.topPadding + eraserSizeSlider.availableHeight / 2 - height / 2
                                    implicitHeight: 8
                                    width: eraserSizeSlider.availableWidth
                                    height: implicitHeight
                                    radius: 3
                                    color: "#555555"
                                }
                                handle: Rectangle {
                                    x: eraserSizeSlider.leftPadding + eraserSizeSlider.visualPosition * (eraserSizeSlider.availableWidth - width)
                                    y: eraserSizeSlider.topPadding + eraserSizeSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 22
                                    implicitHeight: 22
                                    radius: 11
                                    color: "white"
                                    border.color: "#333"
                                    border.width: 1
                                }
                                onMoved: {
                                    let options = toolOptions
                                    options.eraserSize = value
                                    toolOptions = options
                                }
                            }
                        }
                        ColumnLayout {
                            spacing: 15
                            id: colorSettingsContainer
                            Layout.fillWidth: true
                            Layout.preferredWidth: 130
                            visible: selectedTool == "Color"
                            property bool _isUpdating: false
                            Connections {
                                target: drawingScreen
                                function onToolOptionsChanged() {
                                    if (colorSettingsContainer._isUpdating) return;
                                    let c = Qt.color(toolOptions.color)
                                    let newR = Math.round(c.r * 255);
                                    let newG = Math.round(c.g * 255);
                                    let newB = Math.round(c.b * 255);
                                    colorSettingsContainer._isUpdating = true;
                                    rSlider.value = newR;
                                    gSlider.value = newG;
                                    bSlider.value = newB;
                                    colorSettingsContainer._isUpdating = false;
                                }
                            }
                            Text {
                                text: "Kolor RGB"
                                font.pixelSize: 22
                                font.weight: Font.Medium
                                font.bold: true
                                color: "black"
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Slider {
                                id: rSlider
                                from: 0; to: 255; stepSize: 1
                                value: 255
                                Layout.preferredWidth: 130
                                Layout.preferredHeight: 20
                                Layout.alignment: Qt.AlignCenter
                                onMoved: colorSettingsContainer.updateColor()
                                background: Rectangle {
                                    x: rSlider.leftPadding; y: rSlider.topPadding + rSlider.availableHeight / 2 - height / 2
                                    implicitHeight: 8; width: rSlider.availableWidth; height: implicitHeight; radius: 3; color: "#ffcccc"
                                }
                                handle: Rectangle {
                                    x: rSlider.leftPadding + rSlider.visualPosition * (rSlider.availableWidth - width)
                                    y: rSlider.topPadding + rSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 22; implicitHeight: 22; radius: 11; color: "white"; border.color: "#333"; border.width: 1
                                }
                            }
                            Text {
                                text: "R: " + rSlider.value
                                font.pixelSize: 16; color: "black"; Layout.alignment: Qt.AlignCenter
                            }
                            Slider {
                                id: gSlider
                                from: 0; to: 255; stepSize: 1
                                value: 0
                                Layout.preferredWidth: 130
                                Layout.preferredHeight: 20
                                Layout.alignment: Qt.AlignCenter
                                onMoved: colorSettingsContainer.updateColor()
                                background: Rectangle {
                                    x: gSlider.leftPadding; y: gSlider.topPadding + gSlider.availableHeight / 2 - height / 2
                                    implicitHeight: 8; width: gSlider.availableWidth; height: implicitHeight; radius: 3; color: "#ccffcc"
                                }
                                handle: Rectangle {
                                    x: gSlider.leftPadding + gSlider.visualPosition * (gSlider.availableWidth - width)
                                    y: gSlider.topPadding + gSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 22; implicitHeight: 22; radius: 11; color: "white"; border.color: "#333"; border.width: 1
                                }
                            }
                            Text {
                                text: "G: " + gSlider.value
                                font.pixelSize: 16; color: "black"; Layout.alignment: Qt.AlignCenter
                            }
                            Slider {
                                id: bSlider
                                from: 0; to: 255; stepSize: 1
                                value: 0
                                Layout.preferredWidth: 130
                                Layout.preferredHeight: 20
                                Layout.alignment: Qt.AlignCenter
                                onMoved: colorSettingsContainer.updateColor()
                                background: Rectangle {
                                    x: bSlider.leftPadding; y: bSlider.topPadding + bSlider.availableHeight / 2 - height / 2
                                    implicitHeight: 8; width: bSlider.availableWidth; height: implicitHeight; radius: 3; color: "#ccccff"
                                }
                                handle: Rectangle {
                                    x: bSlider.leftPadding + bSlider.visualPosition * (bSlider.availableWidth - width)
                                    y: bSlider.topPadding + bSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 22; implicitHeight: 22; radius: 11; color: "white"; border.color: "#333"; border.width: 1
                                }
                            }
                            Text {
                                text: "B: " + bSlider.value
                                font.pixelSize: 16; color: "black"; Layout.alignment: Qt.AlignCenter
                            }
                            function updateColor() {
                                if (_isUpdating) return;
                                let r = rSlider.value / 255
                                let g = gSlider.value / 255
                                let b = bSlider.value / 255
                                let colorObj = Qt.rgba(r, g, b, 1)
                                let newHex = Qt.color(colorObj).toString().substring(0, 7)
                                _isUpdating = true;
                                let temp = Object.assign({}, toolOptions);
                                temp.color = newHex;
                                toolOptions = temp;
                                _isUpdating = false;
                            }
                        }
                        ColumnLayout {
                            spacing: 15
                            Layout.fillWidth: true
                            Layout.preferredWidth: 130
                            visible: selectedTool == "Text"
                            Text {
                                text: "Ustawienia \ntekstu"
                                font.pixelSize: 22
                                font.weight: Font.Medium
                                color: "black"
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Text {
                                text: "Rozmiar: " + textSizeSlider.value.toFixed(0)
                                font.pixelSize: 15
                                color: "black"
                                Layout.alignment: Qt.AlignCenter
                            }
                            Slider {
                                id: textSizeSlider
                                from: 8; to: 150; stepSize: 1
                                value: toolOptions.textSize || 32
                                Layout.preferredWidth: 130; Layout.preferredHeight: 30
                                background: Rectangle {
                                    implicitHeight: 8; radius: 3; color: "#555555"
                                    width: textSizeSlider.availableWidth
                                    y: textSizeSlider.topPadding + textSizeSlider.availableHeight / 2 - height / 2
                                }
                                handle: Rectangle {
                                    x: textSizeSlider.leftPadding + textSizeSlider.visualPosition * (textSizeSlider.availableWidth - width)
                                    y: textSizeSlider.topPadding + textSizeSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 22; implicitHeight: 22; radius: 11
                                    color: "white"; border.color: "#333"; border.width: 1
                                }
                                onMoved: {
                                    let options = toolOptions
                                    options.textSize = value
                                    toolOptions = options
                                }
                            }
                            Text {
                                text: "Odstępy: " + textSpacingSlider.value.toFixed(1)
                                font.pixelSize: 15
                                color: "black"
                                Layout.alignment: Qt.AlignCenter
                            }
                            Slider {
                                id: textSpacingSlider
                                from: -5
                                to: 20
                                stepSize: 0.5
                                value: toolOptions.textSpacing || 0
                                Layout.preferredWidth: 130
                                Layout.preferredHeight: 30
                                Layout.alignment: Qt.AlignCenter
                                background: Rectangle {
                                    x: textSpacingSlider.leftPadding
                                    y: textSpacingSlider.topPadding + textSpacingSlider.availableHeight / 2 - height / 2
                                    implicitHeight: 8
                                    width: textSpacingSlider.availableWidth
                                    height: implicitHeight
                                    radius: 3
                                    color: "#555555"
                                }

                                handle: Rectangle {
                                    x: textSpacingSlider.leftPadding + textSpacingSlider.visualPosition * (textSpacingSlider.availableWidth - width)
                                    y: textSpacingSlider.topPadding + textSpacingSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 22
                                    implicitHeight: 22
                                    radius: 11
                                    color: "white"
                                    border.color: "#333"
                                    border.width: 1
                                }

                                onMoved: {
                                    let options = toolOptions
                                    options.textSpacing = value
                                    toolOptions = options
                                }
                            }
                            Text {
                                text: "Krycie: " + (textOpacitySlider.value * 100).toFixed(0) + "%"
                                font.pixelSize: 15
                                color: "black"
                                Layout.alignment: Qt.AlignCenter
                            }
                            Slider {
                                id: textOpacitySlider
                                from: 0
                                to: 1
                                value: toolOptions.textOpacity || 1.0
                                Layout.preferredWidth: 130
                                Layout.preferredHeight: 30
                                Layout.alignment: Qt.AlignCenter
                                background: Rectangle {
                                    x: textOpacitySlider.leftPadding
                                    y: textOpacitySlider.topPadding + textOpacitySlider.availableHeight / 2 - height / 2
                                    implicitHeight: 8
                                    width: textOpacitySlider.availableWidth
                                    height: implicitHeight
                                    radius: 3
                                    color: "#555555"
                                }

                                handle: Rectangle {
                                    x: textOpacitySlider.leftPadding + textOpacitySlider.visualPosition * (textOpacitySlider.availableWidth - width)
                                    y: textOpacitySlider.topPadding + textOpacitySlider.availableHeight / 2 - height / 2
                                    implicitWidth: 22
                                    implicitHeight: 22
                                    radius: 11
                                    color: "white"
                                    border.color: "#333"
                                    border.width: 1
                                }

                                onMoved: {
                                    let options = toolOptions
                                    options.textOpacity = value
                                    toolOptions = options
                                }
                            }
                            TextField {
                                id: textInputSource
                                placeholderText: "Wpisz tekst..."
                                text: "Mój Tekst"
                                Layout.preferredWidth: 130
                                Layout.preferredHeight: 35
                                Layout.alignment: Qt.AlignCenter
                                color: "white"
                                font.pixelSize: 16
                                selectionColor: "#777777"
                                selectedTextColor: "white"
                                verticalAlignment: TextInput.AlignVCenter
                                leftPadding: 10
                                rightPadding: 10
                                background: Rectangle {
                                    color: "#555555"
                                    radius: 5
                                }
                                placeholderTextColor: "#aaaaaa"
                                onTextChanged: {
                                    let options = toolOptions
                                    options.currentText = text
                                    toolOptions = options
                                }
                                onAccepted: {
                                    focus = false
                                }
                            }
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
                            drawingScreen.finishDrawing()
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
                    clip: true
                    Image {
                        id: photo
                        source: imageInfo.path
                        x: (parent.width - width) / 2
                        y: (parent.height - height) / 2
                        scale: zoomSlider.value
                        transformOrigin: Item.Center
                        width: Math.min(imageContainer.width, imageContainer.height * (sourceSize.width / sourceSize.height))
                        height: Math.min(imageContainer.height, imageContainer.width * (sourceSize.height / sourceSize.width))
                        fillMode: Image.Stretch
                        rotation: currentMetadata.angle
                        transform: Scale {
                            origin.x: photo.width / 2
                            origin.y: photo.height / 2
                            xScale: currentMetadata.flipH
                            yScale: currentMetadata.flipV
                        }
                        Canvas {
                            id: pickerHelper
                            width: 1
                            height: 1
                            visible: false
                            renderTarget: Canvas.Image
                        }
                        Canvas {
                            id: drawingCanvas
                            z: 100
                            anchors.fill: parent
                            renderTarget: Canvas.Image
                            renderStrategy: Canvas.Threaded
                            property real lastX: 0
                            property real lastY: 0
                            property real currentX: 0
                            property real currentY: 0
                            property bool contextReady: false
                            onAvailableChanged: {
                                if (available && drawingScreen.initialCanvasData !== "") {
                                    loadImage(drawingScreen.initialCanvasData);
                                }
                            }
                            onImageLoaded: {
                                var ctx = getContext("2d");
                                ctx.drawImage(drawingScreen.initialCanvasData, 0, 0, width, height);
                                requestPaint();
                            }
                            onPaint: {
                                var ctx = getContext("2d")
                                if (selectedTool !== "Text" && lastX === 0 && lastY === 0) {
                                    lastX = currentX
                                    lastY = currentY
                                    return
                                }
                                ctx.save()
                                ctx.lineJoin = "round"
                                ctx.lineCap = "round"
                                if (selectedTool === "Text") {
                                    ctx.fillStyle = toolOptions.color
                                    ctx.globalAlpha = toolOptions.textOpacity
                                    ctx.font = toolOptions.textSize + "px sans-serif"
                                    if (toolOptions.textSpacing !== undefined) {
                                        ctx.letterSpacing = toolOptions.textSpacing + "px"
                                    }
                                    let tekstDoWpisania = toolOptions.currentText || "Twój Tekst"
                                    ctx.fillText(tekstDoWpisania, currentX, currentY)
                                }
                                else if (selectedTool === "Pencil") {
                                    ctx.lineWidth = toolOptions.pencilSize
                                    ctx.strokeStyle = toolOptions.color
                                    ctx.globalAlpha = toolOptions.pencilOpacity
                                    ctx.beginPath()
                                    ctx.moveTo(lastX, lastY)
                                    ctx.lineTo(currentX, currentY)
                                    ctx.stroke()
                                } else if (selectedTool === "Pen") {
                                    ctx.lineWidth = toolOptions.penSize
                                    ctx.strokeStyle = toolOptions.color
                                    ctx.globalAlpha = toolOptions.penOpacity
                                    let t = 1.0 - (toolOptions.penSmoothing || 0.0)
                                    currentX = lastX + (currentX - lastX) * t
                                    currentY = lastY + (currentY - lastY) * t
                                    ctx.beginPath()
                                    ctx.moveTo(lastX, lastY)
                                    ctx.lineTo(currentX, currentY)
                                    ctx.stroke()
                                } else if (selectedTool === "Eraser") {
                                    ctx.globalCompositeOperation = "destination-out"
                                    ctx.lineWidth = toolOptions.eraserSize
                                    ctx.beginPath()
                                    ctx.moveTo(lastX, lastY)
                                    ctx.lineTo(currentX, currentY)
                                    ctx.stroke()
                                }
                                ctx.restore()
                                if (selectedTool !== "Text") {
                                    lastX = currentX
                                    lastY = currentY
                                }
                            }
                            function pickColor(mouseX, mouseY) {
                                photo.grabToImage(function(result) {
                                    if (!result) return;
                                    let px = Math.floor(mouseX);
                                    let py = Math.floor(mouseY);
                                    px = Math.max(0, Math.min(px, photo.width));
                                    py = Math.max(0, Math.min(py, photo.height));
                                    var ctx = pickerHelper.getContext("2d");
                                    ctx.clearRect(0, 0, 1, 1);
                                    ctx.drawImage(result.url, px, py, 1, 1, 0, 0, 1, 1);
                                    var pixel = ctx.getImageData(0, 0, 1, 1).data;
                                    if (pixel[3] > 0) {
                                        let pickedHex = "#" +
                                            pixel[0].toString(16).padStart(2, '0') +
                                            pixel[1].toString(16).padStart(2, '0') +
                                            pixel[2].toString(16).padStart(2, '0');
                                        let updatedOptions = Object.assign({}, toolOptions);
                                        updatedOptions.color = pickedHex;
                                        toolOptions = updatedOptions;
                                    }
                                });
                            }
                        }
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            id: multiEffectItem
                            contrast: false ? (originalMetadata.contrast/100) : (currentMetadata.contrast / 100)
                            saturation: false ? (originalMetadata.saturation / 100) : (currentMetadata.saturation / 100)
                            brightness: false ? (originalMetadata.exposition / 100) : (currentMetadata.exposition / 100)
                            blurEnabled: false ? (originalMetadata.blur > 0) : (currentMetadata.blur > 0)
                            blur: false ? (originalMetadata.blur / 100) : (currentMetadata.blur / 100)
                            colorization: false ? Math.abs(originalMetadata.temperature / 100) : Math.abs(currentMetadata.temperature / 100)
                            colorizationColor: {
                                let temp = false ? originalMetadata.temperature : currentMetadata.temperature;
                                return temp > 0 ? "#FFCC00" : "#00CCFF";
                            }
                            layer.enabled: true
                            layer.effect: ShaderEffect {
                                property var source: multiEffectItem
                                property real f_negatyw: (false ? originalMetadata.f_negatyw : currentMetadata.f_negatyw) / 100.0
                                property real f_krawedzie: (false ? originalMetadata.f_krawedzie : currentMetadata.f_krawedzie) / 100.0
                                property real f_szum: (false ? originalMetadata.f_szum : currentMetadata.f_szum) / 100.0
                                property real f_rozmycie_kol: (false ? originalMetadata.f_rozmycie_kol : currentMetadata.f_rozmycie_kol) / 100.0
                                property real f_pixel_art: (false ? originalMetadata.f_pixel_art : currentMetadata.f_pixel_art) / 100.0
                                property real f_stary_film: (false ? originalMetadata.f_stary_film : currentMetadata.f_stary_film) / 100.0
                                property real f_cieple_lato: (false ? originalMetadata.f_cieple_lato : currentMetadata.f_cieple_lato) / 100.0
                                property real f_progowanie: (false ? originalMetadata.f_progowanie : currentMetadata.f_progowanie) / 100.0
                                property real f_sepia_retro: (false ? originalMetadata.f_sepia_retro : currentMetadata.f_sepia_retro) / 100.0
                                property real f_zimna_noc: (false ? originalMetadata.f_zimna_noc : currentMetadata.f_zimna_noc) / 100.0
                                property real srcWidth: photo.sourceSize.width
                                property real srcHeight: photo.sourceSize.height
                                fragmentShader: "qrc:/shaders/filters.frag.qsb"
                            }
                        }
                        onStatusChanged: {
                            if (status === Image.Ready) {
                                let updated = Object.assign({}, currentMetadata)
                                updated.name = source.toString().split("/").pop()
                                updated.path = source.toString()
                                updated.w = sourceSize.width
                                updated.h = sourceSize.height
                                currentMetadata = updated
                            }
                        }
                    }
                    MouseArea {
                        id: dragArea
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                        cursorShape: (panMode || pressedButtons & Qt.MiddleButton)
                                     ? Qt.ClosedHandCursor : Qt.ArrowCursor
                        drag.target: (panMode || pressedButtons & Qt.MiddleButton) ? photo : null
                        drag.axis: Drag.XAndYAxis
                        drag.minimumX: -photo.width / 2
                        drag.maximumX: imageContainer.width - photo.width / 2
                        drag.minimumY: -photo.height / 2
                        drag.maximumY: imageContainer.height - photo.height / 2
                        onPressed: (mouse) => {
                           var coords = dragArea.mapToItem(photo, mouse.x, mouse.y)
                           drawingCanvas.currentX = coords.x
                           drawingCanvas.currentY = coords.y
                           if (selectedTool === "Text") {
                               drawingCanvas.lastX = 0
                               drawingCanvas.lastY = 0
                               drawingCanvas.requestPaint()
                           }
                           if (selectedTool === "Picker" && mouse.button === Qt.LeftButton) {
                               drawingCanvas.pickColor(coords.x, coords.y)
                           }
                           if (!panMode && mouse.button === Qt.LeftButton) {
                               drawingCanvas.lastX = coords.x
                               drawingCanvas.lastY = coords.y
                           }
                           if (mouse.button === Qt.MiddleButton) {
                               mouse.accepted = true
                           }
                        }
                        onPositionChanged: (mouse) => {
                            if (!panMode && (mouse.buttons & Qt.LeftButton)) {
                                if (selectedTool === "Text") return
                                var coords = dragArea.mapToItem(photo, mouse.x, mouse.y)
                                drawingCanvas.currentX = coords.x
                                drawingCanvas.currentY = coords.y
                                drawingCanvas.requestPaint()
                            }
                        }
                        onReleased: {
                            drawingCanvas.lastX = 0;
                            drawingCanvas.lastY = 0;
                        }
                        onWheel: (wheel) => {
                            if (wheel.angleDelta.y > 0) {
                                zoomSlider.value = Math.min(zoomSlider.to, zoomSlider.value + 0.1)
                            } else {
                                zoomSlider.value = Math.max(zoomSlider.from, zoomSlider.value - 0.1)
                            }
                        }
                        onDoubleClicked: {
                            photo.x = (parent.width - photo.width) / 2
                            photo.y = (parent.height - photo.height) / 2
                            zoomSlider.value = 1.0
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
                    id: handBtn
                    icon.source: "../Resources/drag-hand-gesture.svg"
                    iconSize: 35
                    Layout.preferredWidth: 50; Layout.preferredHeight: 50
                    tooltipText: "Przesuń obraz"
                    background: Rectangle {
                        color: panMode ? "#6E7171" : (handBtn.hovered ? "#9EAAAA" : "transparent")
                        radius: 4
                    }
                    onClicked: {
                        panMode = !panMode
                        selectedTool = ""
                    }
                }
                RowLayout {
                    spacing: 5
                    CustomButton {
                        icon.source: "../Resources/zoom-out.svg"
                        iconSize: 35
                        Layout.preferredWidth: 50; Layout.preferredHeight: 50
                        onClicked: zoomSlider.value = Math.max(zoomSlider.from, zoomSlider.value - 0.2)
                        tooltipText: "Oddal zdjęcie"
                    }
                    Slider {
                        id: zoomSlider
                        from: 0.1
                        to: 5.0
                        value: 1.0
                        Layout.preferredWidth: 250
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
                        icon.source: "../Resources/zoom-in.svg"
                        iconSize: 35
                        Layout.preferredWidth: 50; Layout.preferredHeight: 50
                        onClicked: zoomSlider.value = Math.min(zoomSlider.to, zoomSlider.value + 0.2)
                        tooltipText: "Przybliż zdjęcie"
                    }
                }
                CustomButton {
                    id: fullscreenBtn
                    icon.source: "../Resources/maximize.svg"
                    iconSize: 35
                    Layout.preferredWidth: 50; Layout.preferredHeight: 50
                    tooltipText: "Dopasuj do ekranu"
                    onClicked: zoomToFit()
                }
            }
        }
    }
    function zoomToFit() {
        if (photo.status !== Image.Ready) return
        let containerW = imageContainer.width
        let containerH = imageContainer.height
        let finalScale = 1.0
        if (photo.width > 0 && photo.height > 0) {
            let currentRatioX = containerW /(photo.width)
            let currentRatioY = containerH /(photo.height)
            finalScale = Math.min(currentRatioX, currentRatioY)
        }
        zoomSlider.value = finalScale
        photo.x = (imageContainer.width - photo.width) / 2
        photo.y = (imageContainer.height - photo.height) / 2
    }
}
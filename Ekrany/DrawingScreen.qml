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
    property var history: []
    property int historyIndex: -1
    property bool isShowingOriginal: false
    property bool blockHistory: false
    property string selectedTool: ""
    property var toolOptions: ({})
    signal drawingFinished(var finalInfo)
    function clone(obj) { return JSON.parse(JSON.stringify(obj)); }
    function saveState() {
        if (blockHistory) return;
        let stateToSave = clone(currentMetadata)
        if (historyIndex < history.length - 1) {
            history = history.slice(0, historyIndex + 1);
        }
        history.push(stateToSave);
        historyIndex = history.length - 1;
    }
    function applyState(state) {
        if (!state) return;
        blockHistory = true;
        currentMetadata = clone(state);
        blockHistory = false;
    }
    Component.onCompleted: {
        currentMetadata = JSON.parse(JSON.stringify(imageInfo));
        originalMetadata = JSON.parse(JSON.stringify(imageInfo));
        history = [];
        historyIndex = -1;
        photo.sourceClipRect = Qt.rect(
            currentMetadata.crop.x,
            currentMetadata.crop.y,
            currentMetadata.crop.w,
            currentMetadata.crop.h
        )
        saveState()
        zoomToFit()
    }
    function stripExtension(fileName) {
        if (!fileName) return "";
        return fileName.indexOf('.') !== -1 ? fileName.substring(0, fileName.lastIndexOf('.')) : fileName;
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
                            enabled: historyIndex > 0
                            opacity: enabled ? 1.0 : 0.4
                            tooltipText: "Cofnij"
                            onClicked: {
                                if (historyIndex > 0) {
                                    historyIndex--
                                    applyState(history[historyIndex])
                                }
                            }
                        }
                        CustomButton {
                            id: redoBtn
                            Layout.fillWidth: true
                            enabled: historyIndex < history.length - 1
                            opacity: enabled ? 1.0 : 0.4
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
                                    opacity: redoBtn.enabled ? 1.0 : 0.25
                                }
                            }
                            tooltipText: "Ponów"
                            onClicked: {
                                if (historyIndex < history.length - 1) {
                                    historyIndex++
                                    applyState(history[historyIndex])
                                }
                            }
                        }
                        CustomButton {
                            id: actionBtn
                            Layout.fillWidth: true
                            Layout.preferredWidth: 50; Layout.preferredHeight: 50
                            icon.source: "../Resources/transition-right.svg"
                            iconSize: 35
                            tooltipText: "Przytrzymaj żeby pokazać zmiany"
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    isShowingOriginal = true
                                }
                                onExited: {
                                    isShowingOriginal = false
                                }
                            }
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
                                to: 1
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
                                let r = rSlider.value / 255
                                let g = gSlider.value / 255
                                let b = bSlider.value / 255
                                let newColor = Qt.rgba(r, g, b, 1)
                                let newOptions = {}
                                for (let key in toolOptions) {
                                    newOptions[key] = toolOptions[key]
                                }
                                newOptions.color = newColor
                                toolOptions = newOptions
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
                            saveState();
                            drawingFinished(currentMetadata);
                            mainStack.pop();
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
                        rotation: isShowingOriginal ? originalMetadata.angle : currentMetadata.angle
                        transform: Scale {
                            origin.x: photo.width / 2
                            origin.y: photo.height / 2
                            xScale: isShowingOriginal ? originalMetadata.flipH : currentMetadata.flipH
                            yScale: isShowingOriginal ? originalMetadata.flipV : currentMetadata.flipV
                        }
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            id: multiEffectItem
                            contrast: isShowingOriginal ? (originalMetadata.contrast/100) : (currentMetadata.contrast / 100)
                            saturation: isShowingOriginal ? (originalMetadata.saturation / 100) : (currentMetadata.saturation / 100)
                            brightness: isShowingOriginal ? (originalMetadata.exposition / 100) : (currentMetadata.exposition / 100)
                            blurEnabled: isShowingOriginal ? (originalMetadata.blur > 0) : (currentMetadata.blur > 0)
                            blur: isShowingOriginal ? (originalMetadata.blur / 100) : (currentMetadata.blur / 100)
                            colorization: isShowingOriginal ? Math.abs(originalMetadata.temperature / 100) : Math.abs(currentMetadata.temperature / 100)
                            colorizationColor: {
                                let temp = isShowingOriginal ? originalMetadata.temperature : currentMetadata.temperature;
                                return temp > 0 ? "#FFCC00" : "#00CCFF";
                            }
                            layer.enabled: true
                            layer.effect: ShaderEffect {
                                property var source: multiEffectItem
                                property real f_negatyw: (isShowingOriginal ? originalMetadata.f_negatyw : currentMetadata.f_negatyw) / 100.0
                                property real f_krawedzie: (isShowingOriginal ? originalMetadata.f_krawedzie : currentMetadata.f_krawedzie) / 100.0
                                property real f_szum: (isShowingOriginal ? originalMetadata.f_szum : currentMetadata.f_szum) / 100.0
                                property real f_rozmycie_kol: (isShowingOriginal ? originalMetadata.f_rozmycie_kol : currentMetadata.f_rozmycie_kol) / 100.0
                                property real f_pixel_art: (isShowingOriginal ? originalMetadata.f_pixel_art : currentMetadata.f_pixel_art) / 100.0
                                property real f_stary_film: (isShowingOriginal ? originalMetadata.f_stary_film : currentMetadata.f_stary_film) / 100.0
                                property real f_cieple_lato: (isShowingOriginal ? originalMetadata.f_cieple_lato : currentMetadata.f_cieple_lato) / 100.0
                                property real f_progowanie: (isShowingOriginal ? originalMetadata.f_progowanie : currentMetadata.f_progowanie) / 100.0
                                property real f_sepia_retro: (isShowingOriginal ? originalMetadata.f_sepia_retro : currentMetadata.f_sepia_retro) / 100.0
                                property real f_zimna_noc: (isShowingOriginal ? originalMetadata.f_zimna_noc : currentMetadata.f_zimna_noc) / 100.0
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
                           if (!panMode && mouse.button === Qt.LeftButton) {
                               var coords = dragArea.mapToItem(drawingCanvas, mouse.x, mouse.y)
                               drawingCanvas.lastX = coords.x
                               drawingCanvas.lastY = coords.y
                           }
                           if (mouse.button === Qt.MiddleButton) {
                               mouse.accepted = true
                           }
                        }
                        onPositionChanged: (mouse) => {
                            if (!panMode && (mouse.buttons & Qt.LeftButton)) {
                                var coords = dragArea.mapToItem(drawingCanvas, mouse.x, mouse.y)
                                if (drawingCanvas.lastX === 0 && drawingCanvas.lastY === 0) {
                                    drawingCanvas.lastX = coords.x
                                    drawingCanvas.lastY = coords.y
                                }
                                drawingCanvas.currentX = coords.x
                                drawingCanvas.currentY = coords.y
                                drawingCanvas.requestPaint()
                                drawingCanvas.lastX = coords.x
                                drawingCanvas.lastY = coords.y
                            }
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
                    Canvas {
                        id: drawingCanvas
                        z: 100
                        x: photo.x
                        y: photo.y
                        width: photo.width
                        height: photo.height
                        visible: true
                        opacity: 1.0
                        layer.enabled: true
                        scale: photo.scale
                        rotation: photo.rotation
                        transformOrigin: photo.transformOrigin
                        renderTarget: Canvas.Image
                        renderStrategy: Canvas.Threaded
                        property real lastX: 0
                        property real lastY: 0
                        property real currentX: 0
                        property real currentY: 0
                        onAvailableChanged: {
                            if (available) {
                                var ctx = getContext("2d");
                                ctx.clearRect(0, 0, width, height);
                                requestPaint();
                            }
                        }
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.lineJoin = "round"
                            ctx.lineCap = "round"
                            ctx.lineWidth = (selectedTool === "Pencil" ? toolOptions.pencilSize : toolOptions.penSize) || 5
                            ctx.strokeStyle = toolOptions.color || "#ff0000"
                            ctx.beginPath()
                            ctx.moveTo(lastX, lastY)
                            ctx.lineTo(currentX, currentY)
                            ctx.stroke()
                        }
                        transform: Scale {
                            origin.x: drawingCanvas.width / 2
                            origin.y: drawingCanvas.height / 2
                            xScale: isShowingOriginal ? originalMetadata.flipH : currentMetadata.flipH
                            yScale: isShowingOriginal ? originalMetadata.flipV : currentMetadata.flipV
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
                        onPressedChanged: if (!pressed) saveState()
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
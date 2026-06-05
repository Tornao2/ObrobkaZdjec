import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import "../Kontrolki"
import "../Style"
Rectangle {
    id: drawingScreen
    color: Style.dialogBackground
    property var imageInfo: ({})
    property var currentMetadata: ({})
    property var originalMetadata: ({})
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
        "currentText": "Mój Tekst"
    }
    signal drawingFinished(var finalInfo)
    property string initialCanvasData: ""
    property var history: []
    property int historyIndex: -1
    property real fitScale: 1.0
    property bool blockHistory: false
    property bool finishedInit: false
    function clone(obj) { return JSON.parse(JSON.stringify(obj)); }
    Component.onCompleted: {
        currentMetadata = clone(imageInfo);
        originalMetadata = clone(imageInfo);
        photo.sourceClipRect = Qt.rect(
            currentMetadata.crop.x, currentMetadata.crop.y,
            currentMetadata.crop.w, currentMetadata.crop.h
        );
        zoomToFit();
        finishedInit = true
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
    Keys.forwardTo: [historyHandler]
    Item {
        id: historyHandler
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_1) pencilBtn.clicked()
            else if (event.key === Qt.Key_3) penBtn.clicked()
            else if (event.key === Qt.Key_2) textBtn.clicked()
            else if (event.key === Qt.Key_5) eraserBtn.clicked()
            else if (event.key === Qt.Key_4) pickerBtn.clicked()
            else if (event.key === Qt.Key_6) colorBtn.clicked()
            else if (event.modifiers & Qt.ControlModifier) {
                refitSize()
                if (event.key === Qt.Key_Plus || event.key === Qt.Key_Equal) {
                    zoomSlider.value = Math.min(zoomSlider.to, zoomSlider.value + 0.2)
                } else if (event.key === Qt.Key_Minus) {
                    zoomSlider.value = Math.max(zoomSlider.from, zoomSlider.value - 0.2)
                } else if (event.key === Qt.Key_0) {
                    zoomSlider.value = 1.0
                    photo.x = (imageContainer.width - photo.width) / 2
                    photo.y = (imageContainer.height - photo.height) / 2
                } else if (event.key === Qt.Key_F) {
                    zoomToFit()
                }
            }
        }
        Connections {
            target: textInputSource
            function onAccepted() { drawingScreen.forceActiveFocus() }
            function onEditingFinished() { drawingScreen.forceActiveFocus() }
        }
    }
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        Rectangle {
            id: topBar
            Layout.fillWidth: true
            Layout.preferredHeight: Style.manipulationTopBarHeight
            color: Style.dialogBackground
            Text {
                text: currentMetadata.name
                anchors.centerIn: parent
                font.pixelSize: Style.fontTitleSize; color: Style.baseTextColor
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            Rectangle {
                Layout.leftMargin: 0
                Layout.preferredWidth: Style.manipulationSidePanelWidth
                Layout.fillHeight: true
                color: Style.dialogBackground
                ScrollView {
                    id: sideScroll
                    anchors.fill: parent
                    clip: true
                    ColumnLayout {
                        id: sideContent
                        anchors.fill: parent
                        anchors.leftMargin: Style.manipulationPanelMargin
                        anchors.rightMargin: Style.manipulationPanelMargin
                        spacing: Style.manipulationPanelSpacing
                        Button {
                            id: resetBtn
                            text: "Anuluj"
                            Layout.fillWidth: true
                            Layout.preferredHeight: Style.customButtonHeight
                            contentItem: Text {
                                text: resetBtn.text
                                font.pixelSize: Style.fontTitleSize
                                font.weight: Style.fontWeight
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                color: resetBtn.pressed ? Style.cancelActionBtnPressed : (resetBtn.hovered ? Style.cancelActionBtnHover : Style.cancelActionBtnNormal)
                                radius: Style.dialogRadius
                            }
                            onClicked: {
                                var handler = function() {
                                    globalConfirmDialog.confirmed.disconnect(handler)
                                    globalConfirmDialog.cancelled.disconnect(cancelHandler)
                                    mainStack.pop()
                                }
                                var cancelHandler = function() {
                                    globalConfirmDialog.confirmed.disconnect(handler)
                                    globalConfirmDialog.cancelled.disconnect(cancelHandler)
                                }
                                globalConfirmDialog.confirmed.connect(handler)
                                globalConfirmDialog.cancelled.connect(cancelHandler)
                                globalConfirmDialog.open()
                            }
                        }
                        Grid {
                            id: buttonsGrid
                            columns: 2
                            spacing: Style.drawingToolGridSpacing
                            CustomButton {
                                id: pencilBtn
                                Layout.preferredWidth: Style.drawingToolBtnSize; Layout.preferredHeight: Style.drawingToolBtnSize
                                iconSize: Style.drawingToolIconSize
                                icon.source: "../Resources/edit-pencil.svg"
                                tooltipText: "Ołówek(1)"
                                isSelected: selectedTool == "Pencil"
                                onClicked: {
                                    selectedTool = "Pencil"
                                    panMode = false
                                }
                            }
                            CustomButton {
                                id: textBtn
                                Layout.preferredWidth: Style.drawingToolBtnSize; Layout.preferredHeight: Style.drawingToolBtnSize
                                iconSize: Style.drawingToolIconSize
                                icon.source: "../Resources/text.svg"
                                tooltipText: "Tekst(2)"
                                isSelected: selectedTool == "Text"
                                onClicked: {
                                    selectedTool = "Text"
                                    panMode = false
                                }
                            }
                            CustomButton {
                                id: penBtn
                                Layout.preferredWidth: Style.drawingToolBtnSize; Layout.preferredHeight: Style.drawingToolBtnSize
                                iconSize: Style.drawingToolIconSize
                                icon.source: "../Resources/design-nib.svg"
                                tooltipText: "Pióro(3)"
                                isSelected: selectedTool == "Pen"
                                onClicked: {
                                    selectedTool = "Pen"
                                    panMode = false
                                }
                            }
                            CustomButton {
                                id: pickerBtn
                                Layout.preferredWidth: Style.drawingToolBtnSize; Layout.preferredHeight: Style.drawingToolBtnSize
                                iconSize: Style.drawingToolIconSize
                                icon.source: "../Resources/color-picker.svg"
                                tooltipText: "Wybierz kolor ze zdjęcia(4)"
                                isSelected: selectedTool == "Picker"
                                onClicked: {
                                    selectedTool = "Picker"
                                    panMode = false
                                }
                            }
                            CustomButton {
                                id: eraserBtn
                                Layout.preferredWidth: Style.drawingToolBtnSize; Layout.preferredHeight: Style.drawingToolBtnSize
                                iconSize: Style.drawingToolIconSize
                                icon.source: "../Resources/erase.svg"
                                tooltipText: "Wymaż(5)"
                                isSelected: selectedTool == "Eraser"
                                onClicked: {
                                    selectedTool = "Eraser"
                                    panMode = false
                                }
                            }
                            CustomButton {
                                id: colorBtn
                                Layout.preferredWidth: Style.drawingToolBtnSize; Layout.preferredHeight: Style.drawingToolBtnSize
                                iconSize: Style.drawingToolIconSize
                                icon.source: "../Resources/circle.svg"
                                tooltipText: "Wybierz kolor(6)"
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
                            width: Style.drawingDividerWidth
                            height: Style.metadataSeparatorHeight
                            color: Style.baseTextColor
                        }
                        ColumnLayout {
                            spacing: Style.drawingSettingsSpacing
                            Layout.fillWidth: true
                            Layout.preferredWidth: Style.drawingSettingsWidth
                            visible: selectedTool !== ""
                            ColumnLayout {
                                spacing: Style.drawingSettingsGroupSpacing
                                Layout.fillWidth: true
                                Layout.preferredWidth: Style.drawingSettingsWidth
                                visible: selectedTool == "Pencil"
                                Text {
                                    text: "Ustawienia \nołówka"
                                    font.pixelSize: Style.drawingSectionTitleSize
                                    font.weight: Style.fontWeight
                                    font.bold: true
                                    color: Style.baseTextColor
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                Text {
                                    text: "Grubość: " + pencilSizeSlider.value.toFixed(0)
                                    font.pixelSize: Style.drawingSettingLabelSize
                                    color: Style.baseTextColor
                                    Layout.alignment: Qt.AlignCenter
                                }
                                Slider {
                                    id: pencilSizeSlider
                                    from: 1
                                    to: 50
                                    stepSize: 1
                                    value: toolOptions.pencilSize || 5
                                    Layout.preferredWidth: Style.drawingSettingsWidth
                                    Layout.preferredHeight: Style.filterStrengthSliderHeight
                                    Layout.alignment: Qt.AlignCenter
                                    background: Rectangle {
                                        x: pencilSizeSlider.leftPadding
                                        y: pencilSizeSlider.topPadding + pencilSizeSlider.availableHeight / 2 - height / 2
                                        implicitHeight: Style.sliderBgImplicitHeight
                                        width: pencilSizeSlider.availableWidth
                                        height: implicitHeight
                                        radius: Style.sliderBgRadius
                                        color: Style.sliderBgColor
                                    }
                                    handle: Rectangle {
                                        x: pencilSizeSlider.leftPadding + pencilSizeSlider.visualPosition * (pencilSizeSlider.availableWidth - width)
                                        y: pencilSizeSlider.topPadding + pencilSizeSlider.availableHeight / 2 - height / 2
                                        implicitWidth: Style.sliderHandleImplicitWidth
                                        implicitHeight: Style.sliderHandleImplicitHeight
                                        radius: Style.sliderHandleRadius
                                        color: Style.sliderHandleColor
                                        border.color: Style.sliderHandleBorderColor
                                        border.width: Style.sliderHandleBorderWidth
                                    }
                                    onMoved: {
                                        let options = toolOptions
                                        options.pencilSize = value
                                        toolOptions = options
                                    }
                                }
                                Text {
                                    text: "Krycie: " + (pencilOpacitySlider.value * 100).toFixed(0) + "%"
                                    font.pixelSize: Style.drawingSettingLabelSize
                                    color: Style.baseTextColor
                                    Layout.alignment: Qt.AlignCenter
                                }
                                Slider {
                                    id: pencilOpacitySlider
                                    from: 0
                                    to: 1
                                    value: toolOptions.pencilOpacity || 1.0
                                    Layout.preferredWidth: Style.drawingSettingsWidth
                                    Layout.preferredHeight: Style.filterStrengthSliderHeight
                                    Layout.alignment: Qt.AlignCenter
                                    background: Rectangle {
                                        x: pencilOpacitySlider.leftPadding
                                        y: pencilOpacitySlider.topPadding + pencilOpacitySlider.availableHeight / 2 - height / 2
                                        implicitHeight: Style.sliderBgImplicitHeight
                                        width: pencilOpacitySlider.availableWidth
                                        height: implicitHeight
                                        radius: Style.sliderBgRadius
                                        color: Style.sliderBgColor
                                    }
                                    handle: Rectangle {
                                        x: pencilOpacitySlider.leftPadding + pencilOpacitySlider.visualPosition * (pencilOpacitySlider.availableWidth - width)
                                        y: pencilOpacitySlider.topPadding + pencilOpacitySlider.availableHeight / 2 - height / 2
                                        implicitWidth: Style.sliderHandleImplicitWidth
                                        implicitHeight: Style.sliderHandleImplicitHeight
                                        radius: Style.sliderHandleRadius
                                        color: Style.sliderHandleColor
                                        border.color: Style.sliderHandleBorderColor
                                        border.width: Style.sliderHandleBorderWidth
                                    }
                                    onMoved: {
                                        let options = toolOptions
                                        options.pencilOpacity = value
                                        toolOptions = options
                                    }
                                }
                            }
                            ColumnLayout {
                                spacing: Style.drawingSettingsGroupSpacing
                                Layout.fillWidth: true
                                Layout.preferredWidth: Style.drawingSettingsWidth
                                visible: selectedTool == "Pen"
                                Text {
                                    text: "Ustawienia \npióra"
                                    font.pixelSize: Style.drawingSectionTitleSize
                                    font.bold: true
                                    font.weight: Style.fontWeight
                                    color: Style.baseTextColor
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                Text {
                                    text: "Szerokość: " + penSizeSlider.value.toFixed(0)
                                    font.pixelSize: Style.drawingSettingLabelSize
                                    color: Style.baseTextColor
                                    Layout.alignment: Qt.AlignCenter
                                }
                                Slider {
                                    id: penSizeSlider
                                    from: 1
                                    to: 50
                                    stepSize: 1
                                    value: toolOptions.penSize || 3
                                    Layout.preferredWidth: Style.drawingSettingsWidth
                                    Layout.preferredHeight: Style.filterStrengthSliderHeight
                                    Layout.alignment: Qt.AlignCenter
                                    background: Rectangle {
                                        x: penSizeSlider.leftPadding
                                        y: penSizeSlider.topPadding + penSizeSlider.availableHeight / 2 - height / 2
                                        implicitHeight: Style.sliderBgImplicitHeight
                                        width: penSizeSlider.availableWidth
                                        height: implicitHeight
                                        radius: Style.sliderBgRadius
                                        color: Style.sliderBgColor
                                    }
                                    handle: Rectangle {
                                        x: penSizeSlider.leftPadding + penSizeSlider.visualPosition * (penSizeSlider.availableWidth - width)
                                        y: penSizeSlider.topPadding + penSizeSlider.availableHeight / 2 - height / 2
                                        implicitWidth: Style.sliderHandleImplicitWidth
                                        implicitHeight: Style.sliderHandleImplicitHeight
                                        radius: Style.sliderHandleRadius
                                        color: Style.sliderHandleColor
                                        border.color: Style.sliderHandleBorderColor
                                        border.width: Style.sliderHandleBorderWidth
                                    }
                                    onMoved: {
                                        let options = toolOptions
                                        options.penSize = value
                                        toolOptions = options
                                    }
                                }
                                Text {
                                    text: "Wygładzanie: " + (penSmoothingSlider.value * 100).toFixed(0) + "%"
                                    font.pixelSize: Style.drawingSettingLabelSize
                                    color: Style.baseTextColor
                                    Layout.alignment: Qt.AlignCenter
                                }
                                Slider {
                                    id: penSmoothingSlider
                                    from: 0
                                    to: 0.99
                                    value: toolOptions.penSmoothing || 0.5
                                    Layout.preferredWidth: Style.drawingSettingsWidth
                                    Layout.preferredHeight: Style.filterStrengthSliderHeight
                                    Layout.alignment: Qt.AlignCenter
                                    background: Rectangle {
                                        x: penSmoothingSlider.leftPadding
                                        y: penSmoothingSlider.topPadding + penSmoothingSlider.availableHeight / 2 - height / 2
                                        implicitHeight: Style.sliderBgImplicitHeight
                                        width: penSmoothingSlider.availableWidth
                                        height: implicitHeight
                                        radius: Style.sliderBgRadius
                                        color: Style.sliderBgColor
                                    }
                                    handle: Rectangle {
                                        x: penSmoothingSlider.leftPadding + penSmoothingSlider.visualPosition * (penSmoothingSlider.availableWidth - width)
                                        y: penSmoothingSlider.topPadding + penSmoothingSlider.availableHeight / 2 - height / 2
                                        implicitWidth: Style.sliderHandleImplicitWidth
                                        implicitHeight: Style.sliderHandleImplicitHeight
                                        radius: Style.sliderHandleRadius
                                        color: Style.sliderHandleColor
                                        border.color: Style.sliderHandleBorderColor
                                        border.width: Style.sliderHandleBorderWidth
                                    }
                                    onMoved: {
                                        let options = toolOptions
                                        options.penSmoothing = value
                                        toolOptions = options
                                    }
                                }
                                Text {
                                    text: "Krycie: " + (penOpacitySlider.value * 100).toFixed(0) + "%"
                                    font.pixelSize: Style.drawingSettingLabelSize
                                    color: Style.baseTextColor
                                    Layout.alignment: Qt.AlignCenter
                                }
                                Slider {
                                    id: penOpacitySlider
                                    from: 0
                                    to: 1
                                    value: toolOptions.penOpacity || 1.0
                                    Layout.preferredWidth: Style.drawingSettingsWidth
                                    Layout.preferredHeight: Style.filterStrengthSliderHeight
                                    Layout.alignment: Qt.AlignCenter
                                    background: Rectangle {
                                        x: penOpacitySlider.leftPadding
                                        y: penOpacitySlider.topPadding + penOpacitySlider.availableHeight / 2 - height / 2
                                        implicitHeight: Style.sliderBgImplicitHeight
                                        width: penOpacitySlider.availableWidth
                                        height: implicitHeight
                                        radius: Style.sliderBgRadius
                                        color: Style.sliderBgColor
                                    }
                                    handle: Rectangle {
                                        x: penOpacitySlider.leftPadding + penOpacitySlider.visualPosition * (penOpacitySlider.availableWidth - width)
                                        y: penOpacitySlider.topPadding + penOpacitySlider.availableHeight / 2 - height / 2
                                        implicitWidth: Style.sliderHandleImplicitWidth
                                        implicitHeight: Style.sliderHandleImplicitHeight
                                        radius: Style.sliderHandleRadius
                                        color: Style.sliderHandleColor
                                        border.color: Style.sliderHandleBorderColor
                                        border.width: Style.sliderHandleBorderWidth
                                    }
                                    onMoved: {
                                        let options = toolOptions
                                        options.penOpacity = value
                                        toolOptions = options
                                    }
                                }
                            }
                            ColumnLayout {
                                spacing: Style.drawingSettingsGroupSpacing
                                Layout.fillWidth: true
                                Layout.preferredWidth: Style.drawingSettingsWidth
                                visible: selectedTool == "Eraser"
                                Text {
                                    text: "Ustawienia \ngumki"
                                    font.pixelSize: Style.drawingSectionTitleSize
                                    font.weight: Style.fontWeight
                                    font.bold: true
                                    color: Style.baseTextColor
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                Text {
                                    text: "Grubość: " + eraserSizeSlider.value.toFixed(0)
                                    font.pixelSize: Style.drawingSettingLabelSize
                                    color: Style.baseTextColor
                                    Layout.alignment: Qt.AlignCenter
                                }
                                Slider {
                                    id: eraserSizeSlider
                                    from: 1
                                    to: 50
                                    stepSize: 1
                                    value: toolOptions.eraserSize || 5
                                    Layout.preferredWidth: Style.drawingSettingsWidth
                                    Layout.preferredHeight: Style.filterStrengthSliderHeight
                                    Layout.alignment: Qt.AlignCenter
                                    background: Rectangle {
                                        x: eraserSizeSlider.leftPadding
                                        y: eraserSizeSlider.topPadding + eraserSizeSlider.availableHeight / 2 - height / 2
                                        implicitHeight: Style.sliderBgImplicitHeight
                                        width: eraserSizeSlider.availableWidth
                                        height: implicitHeight
                                        radius: Style.sliderBgRadius
                                        color: Style.sliderBgColor
                                    }
                                    handle: Rectangle {
                                        x: eraserSizeSlider.leftPadding + eraserSizeSlider.visualPosition * (eraserSizeSlider.availableWidth - width)
                                        y: eraserSizeSlider.topPadding + eraserSizeSlider.availableHeight / 2 - height / 2
                                        implicitWidth: Style.sliderHandleImplicitWidth
                                        implicitHeight: Style.sliderHandleImplicitHeight
                                        radius: Style.sliderHandleRadius
                                        color: Style.sliderHandleColor
                                        border.color: Style.sliderHandleBorderColor
                                        border.width: Style.sliderHandleBorderWidth
                                    }
                                    onMoved: {
                                        let options = toolOptions
                                        options.eraserSize = value
                                        toolOptions = options
                                    }
                                }
                            }
                            ColumnLayout {
                                spacing: Style.drawingSettingsGroupSpacing
                                id: colorSettingsContainer
                                Layout.fillWidth: true
                                Layout.preferredWidth: Style.drawingSettingsWidth
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
                                    font.pixelSize: Style.drawingSectionTitleSize
                                    font.weight: Style.fontWeight
                                    font.bold: true
                                    color: Style.baseTextColor
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                Slider {
                                    id: rSlider
                                    from: 0; to: 255; stepSize: 1
                                    value: 255
                                    Layout.preferredWidth: Style.drawingSettingsWidth
                                    Layout.preferredHeight: Style.drawingColorSliderHeight
                                    Layout.alignment: Qt.AlignCenter
                                    onMoved: colorSettingsContainer.updateColor()
                                    background: Rectangle {
                                        x: rSlider.leftPadding; y: rSlider.topPadding + rSlider.availableHeight / 2 - height / 2
                                        implicitHeight: Style.sliderBgImplicitHeight; width: rSlider.availableWidth; height: implicitHeight; radius: Style.sliderBgRadius; color: Style.drawingRgbRedBg
                                    }
                                    handle: Rectangle {
                                        x: rSlider.leftPadding + rSlider.visualPosition * (rSlider.availableWidth - width)
                                        y: rSlider.topPadding + rSlider.availableHeight / 2 - height / 2
                                        implicitWidth: Style.sliderHandleImplicitWidth; implicitHeight: Style.sliderHandleImplicitHeight; radius: Style.sliderHandleRadius; color: Style.sliderHandleColor; border.color: Style.sliderHandleBorderColor; border.width: Style.sliderHandleBorderWidth
                                    }
                                }
                                Text {
                                    text: "R: " + rSlider.value
                                    font.pixelSize: Style.inputFieldFontSize; color: Style.baseTextColor; Layout.alignment: Qt.AlignCenter
                                }
                                Slider {
                                    id: gSlider
                                    from: 0; to: 255; stepSize: 1
                                    value: 0
                                    Layout.preferredWidth: Style.drawingSettingsWidth
                                    Layout.preferredHeight: Style.drawingColorSliderHeight
                                    Layout.alignment: Qt.AlignCenter
                                    onMoved: colorSettingsContainer.updateColor()
                                    background: Rectangle {
                                        x: gSlider.leftPadding; y: gSlider.topPadding + gSlider.availableHeight / 2 - height / 2
                                        implicitHeight: Style.sliderBgImplicitHeight; width: gSlider.availableWidth; height: implicitHeight; radius: Style.sliderBgRadius; color: Style.drawingRgbGreenBg
                                    }
                                    handle: Rectangle {
                                        x: gSlider.leftPadding + gSlider.visualPosition * (gSlider.availableWidth - width)
                                        y: gSlider.topPadding + gSlider.availableHeight / 2 - height / 2
                                        implicitWidth: Style.sliderHandleImplicitWidth; implicitHeight: Style.sliderHandleImplicitHeight; radius: Style.sliderHandleRadius; color: Style.sliderHandleColor; border.color: Style.sliderHandleBorderColor; border.width: Style.sliderHandleBorderWidth
                                    }
                                }
                                Text {
                                    text: "G: " + gSlider.value
                                    font.pixelSize: Style.inputFieldFontSize; color: Style.baseTextColor; Layout.alignment: Qt.AlignCenter
                                }
                                Slider {
                                    id: bSlider
                                    from: 0; to: 255; stepSize: 1
                                    value: 0
                                    Layout.preferredWidth: Style.drawingSettingsWidth
                                    Layout.preferredHeight: Style.drawingColorSliderHeight
                                    Layout.alignment: Qt.AlignCenter
                                    onMoved: colorSettingsContainer.updateColor()
                                    background: Rectangle {
                                        x: bSlider.leftPadding; y: bSlider.topPadding + bSlider.availableHeight / 2 - height / 2
                                        implicitHeight: Style.sliderBgImplicitHeight; width: bSlider.availableWidth; height: implicitHeight; radius: Style.sliderBgRadius; color: Style.drawingRgbBlueBg
                                    }
                                    handle: Rectangle {
                                        x: bSlider.leftPadding + bSlider.visualPosition * (bSlider.availableWidth - width)
                                        y: bSlider.topPadding + bSlider.availableHeight / 2 - height / 2
                                        implicitWidth: Style.sliderHandleImplicitWidth; implicitHeight: Style.sliderHandleImplicitHeight; radius: Style.sliderHandleRadius; color: Style.sliderHandleColor; border.color: Style.sliderHandleBorderColor; border.width: Style.sliderHandleBorderWidth
                                    }
                                }
                                Text {
                                    text: "B: " + bSlider.value
                                    font.pixelSize: Style.inputFieldFontSize; color: Style.baseTextColor; Layout.alignment: Qt.AlignCenter
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
                                spacing: Style.drawingSettingsGroupSpacing
                                Layout.fillWidth: true
                                Layout.preferredWidth: Style.drawingSettingsWidth
                                visible: selectedTool == "Text"
                                Text {
                                    text: "Ustawienia \ntekstu"
                                    font.pixelSize: Style.drawingSectionTitleSize
                                    font.weight: Style.fontWeight
                                    color: Style.baseTextColor
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                Text {
                                    text: "Rozmiar: " + textSizeSlider.value.toFixed(0)
                                    font.pixelSize: Style.drawingSettingLabelSize
                                    color: Style.baseTextColor
                                    Layout.alignment: Qt.AlignCenter
                                }
                                Slider {
                                    id: textSizeSlider
                                    from: 8; to: 150; stepSize: 1
                                    value: toolOptions.textSize || 32
                                    Layout.preferredWidth: Style.drawingSettingsWidth; Layout.preferredHeight: Style.filterStrengthSliderHeight
                                    background: Rectangle {
                                        x: textSpacingSlider.leftPadding
                                        y: textSpacingSlider.topPadding + textSpacingSlider.availableHeight / 2 - height / 2
                                        implicitHeight: Style.sliderBgImplicitHeight
                                        width: textSpacingSlider.availableWidth
                                        height: implicitHeight
                                        radius: Style.sliderBgRadius
                                        color: Style.sliderBgColor
                                    }
                                    handle: Rectangle {
                                        x: textSizeSlider.leftPadding + textSizeSlider.visualPosition * (textSizeSlider.availableWidth - width)
                                        y: textSizeSlider.topPadding + textSizeSlider.availableHeight / 2 - height / 2
                                        implicitWidth: Style.sliderHandleImplicitWidth; implicitHeight: Style.sliderHandleImplicitHeight; radius: Style.sliderHandleRadius
                                        color: Style.sliderHandleColor; border.color: Style.sliderHandleBorderColor; border.width: Style.sliderHandleBorderWidth
                                    }
                                    onMoved: {
                                        let options = toolOptions
                                        options.textSize = value
                                        toolOptions = options
                                    }
                                }
                                Text {
                                    text: "Odstępy: " + textSpacingSlider.value.toFixed(1)
                                    font.pixelSize: Style.drawingSettingLabelSize
                                    color: Style.baseTextColor
                                    Layout.alignment: Qt.AlignCenter
                                }
                                Slider {
                                    id: textSpacingSlider
                                    from: -5
                                    to: 20
                                    stepSize: 0.5
                                    value: toolOptions.textSpacing || 0
                                    Layout.preferredWidth: Style.drawingSettingsWidth
                                    Layout.preferredHeight: Style.filterStrengthSliderHeight
                                    Layout.alignment: Qt.AlignCenter
                                    background: Rectangle {
                                        x: textSpacingSlider.leftPadding
                                        y: textSpacingSlider.topPadding + textSpacingSlider.availableHeight / 2 - height / 2
                                        implicitHeight: Style.sliderBgImplicitHeight
                                        width: textSpacingSlider.availableWidth
                                        height: implicitHeight
                                        radius: Style.sliderBgRadius
                                        color: Style.sliderBgColor
                                    }
                                    handle: Rectangle {
                                        x: textSpacingSlider.leftPadding + textSpacingSlider.visualPosition * (textSpacingSlider.availableWidth - width)
                                        y: textSpacingSlider.topPadding + textSpacingSlider.availableHeight / 2 - height / 2
                                        implicitWidth: Style.sliderHandleImplicitWidth
                                        implicitHeight: Style.sliderHandleImplicitHeight
                                        radius: Style.sliderHandleRadius
                                        color: Style.sliderHandleColor
                                        border.color: Style.sliderHandleBorderColor
                                        border.width: Style.sliderHandleBorderWidth
                                    }
                                    onMoved: {
                                        let options = toolOptions
                                        options.textSpacing = value
                                        toolOptions = options
                                    }
                                }
                                Text {
                                    text: "Krycie: " + (textOpacitySlider.value * 100).toFixed(0) + "%"
                                    font.pixelSize: Style.drawingSettingLabelSize
                                    color: Style.baseTextColor
                                    Layout.alignment: Qt.AlignCenter
                                }
                                Slider {
                                    id: textOpacitySlider
                                    from: 0
                                    to: 1
                                    value: toolOptions.textOpacity || 1.0
                                    Layout.preferredWidth: Style.drawingSettingsWidth
                                    Layout.preferredHeight: Style.filterStrengthSliderHeight
                                    Layout.alignment: Qt.AlignCenter
                                    background: Rectangle {
                                        x: textOpacitySlider.leftPadding
                                        y: textOpacitySlider.topPadding + textOpacitySlider.availableHeight / 2 - height / 2
                                        implicitHeight: Style.sliderBgImplicitHeight
                                        width: textOpacitySlider.availableWidth
                                        height: implicitHeight
                                        radius: Style.sliderBgRadius
                                        color: Style.sliderBgColor
                                    }
                                    handle: Rectangle {
                                        x: textOpacitySlider.leftPadding + textOpacitySlider.visualPosition * (textOpacitySlider.availableWidth - width)
                                        y: textOpacitySlider.topPadding + textOpacitySlider.availableHeight / 2 - height / 2
                                        implicitWidth: Style.sliderHandleImplicitWidth
                                        implicitHeight: Style.sliderHandleImplicitHeight
                                        radius: Style.sliderHandleRadius
                                        color: Style.sliderHandleColor
                                        border.color: Style.sliderHandleBorderColor
                                        border.width: Style.sliderHandleBorderWidth
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
                                    Layout.preferredWidth: Style.drawingSettingsWidth
                                    Layout.preferredHeight: Style.inputFieldHeight
                                    Layout.alignment: Qt.AlignCenter
                                    color: Style.baseTextColor
                                    font.pixelSize: Style.inputFieldFontSize
                                    font.weight: Font.Normal
                                    selectionColor: Style.drawingTextSelectionColor
                                    selectedTextColor: Style.baseTextColor
                                    verticalAlignment: TextInput.AlignVCenter
                                    leftPadding: Style.metadataDescriptionPaddingLeft
                                    rightPadding: Style.metadataDescriptionPaddingLeft
                                    topPadding: 0
                                    bottomPadding: 0
                                    background: Item {
                                        Rectangle {
                                            anchors.fill: parent
                                            color: "transparent"
                                        }
                                        Rectangle {
                                            anchors.bottom: parent.bottom
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            height: textInputSource.activeFocus ? Style.editorProgressBarHeight : Style.metadataSeparatorHeight
                                            color: textInputSource.activeFocus ? Style.secondaryTextColor : Style.disabledTextColor
                                        }
                                    }
                                    placeholderTextColor: Style.metadataSeparatorColor
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
                            Layout.preferredHeight: Style.customButtonHeight
                            Layout.bottomMargin: Style.manipulationPanelMargin
                            contentItem: Text {
                                text: confirmBtn.text
                                font.pixelSize: Style.fontBodySize
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                color: confirmBtn.pressed ? Style.manipulationConfirmBtnPressed : (confirmBtn.hovered ? Style.manipulationConfirmBtnHover : Style.manipulationConfirmBtnNormal)
                                radius: Style.manipulationConfirmBtnRadius
                            }
                            onClicked: {
                                drawingScreen.finishDrawing()
                            }
                        }
                    }
                }
            }
            Rectangle {
                color: Style.metadataRightPanelBg
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 0
                Item {
                    id: imageContainer
                    anchors.fill: parent
                    clip: true
                    property real dragOffsetX: 0
                    property real dragOffsetY: 0
                    Image {
                        id: photo
                        source: imageInfo.path
                        scale: fitScale * zoomSlider.value
                        transformOrigin: Item.Center
                        fillMode: Image.PreserveAspectFit
                        rotation: currentMetadata.angle
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: imageContainer.dragOffsetX
                        anchors.verticalCenterOffset: imageContainer.dragOffsetY
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
                            property bool wasImageDrawn: false
                            Image {
                                id: hiddenCanvasLoader
                                source: (drawingScreen.initialCanvasData && drawingScreen.initialCanvasData !== "data:," && drawingScreen.initialCanvasData !== "")
                                            ? drawingScreen.initialCanvasData
                                            : ""
                                visible: false
                                onStatusChanged: {
                                    if (status === Image.Ready && !drawingCanvas.wasImageDrawn) {
                                        drawingCanvas.requestPaint();
                                    }
                                }
                            }
                            onPaint: {
                                if(!finishedInit) return
                                var ctx = getContext("2d")
                                if (hiddenCanvasLoader.status === Image.Ready && !wasImageDrawn) {
                                    ctx.drawImage(hiddenCanvasLoader, 0, 0, width, height);
                                    wasImageDrawn = true;
                                }
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
                                if (originalImageLoader.status !== Image.Ready) return;
                                let scaleX = originalImageLoader.sourceSize.width / originalImageLoader.paintedWidth;
                                let scaleY = originalImageLoader.sourceSize.height / originalImageLoader.paintedHeight;
                                let srcX = Math.max(0, Math.min(Math.floor(mouseX * scaleX), originalImageLoader.sourceSize.width - 1));
                                let srcY = Math.max(0, Math.min(Math.floor(mouseY * scaleY), originalImageLoader.sourceSize.height - 1));
                                let ctx = pickerHelper.getContext("2d");
                                pickerHelper.width = 1;
                                pickerHelper.height = 1;
                                ctx.clearRect(0, 0, 1, 1);
                                ctx.drawImage(originalImageLoader, srcX, srcY, 1, 1, 0, 0, 1, 1);
                                let pixel = ctx.getImageData(0, 0, 1, 1).data;
                                if (pixel[3] > 0) {
                                    let hex = "#" + [pixel[0], pixel[1], pixel[2]].map(v => v.toString(16).padStart(2, '0')).join('');
                                    let opts = Object.assign({}, toolOptions);
                                    opts.color = hex;
                                    toolOptions = opts;
                                }
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
                        property int lastX: 0
                        property int lastY: 0
                        onPressed: (mouse) => {
                           var coords = dragArea.mapToItem(photo, mouse.x, mouse.y)
                           drawingCanvas.currentX = coords.x
                           drawingCanvas.currentY = coords.y
                           if (selectedTool === "Text" && mouse.button === Qt.LeftButton) {
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
                               dragArea.lastX = mouse.x
                               dragArea.lastY = mouse.y
                               mouse.accepted = true
                           }
                           dragArea.lastX = mouse.x
                            dragArea.lastY = mouse.y
                        }
                        onPositionChanged: (mouse) => {
                           if (pressed && (pressedButtons & Qt.MiddleButton || panMode)) {
                               let deltaX = mouse.x - dragArea.lastX
                               let deltaY = mouse.y - dragArea.lastY
                               imageContainer.dragOffsetX += deltaX
                               imageContainer.dragOffsetY += deltaY
                               dragArea.lastX = mouse.x
                               dragArea.lastY = mouse.y
                           }
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
                            refitSize()
                            if (wheel.angleDelta.y > 0) {
                                zoomSlider.value = Math.min(zoomSlider.to, zoomSlider.value + 0.1)
                            } else {
                                zoomSlider.value = Math.max(zoomSlider.from, zoomSlider.value - 0.1)
                            }
                        }
                        onDoubleClicked: {
                            zoomToFit()
                        }
                    }
                }
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.manipulationBottomBarHeight1
            color: Style.dialogBackground
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.manipulationBottomBarHeight2
            color: Style.manipulationBottomBarColor2
            RowLayout {
                anchors.fill: parent
                Item { Layout.fillWidth: true }
                CustomButton {
                    id: handBtn
                    icon.source: "../Resources/drag-hand-gesture.svg"
                    iconSize: Style.metadataActionIconSize
                    Layout.preferredWidth: Style.metadataActionBtnSize; Layout.preferredHeight: Style.metadataActionBtnSize
                    tooltipText: "Przesuń obraz"
                    background: Rectangle {
                        color: panMode ? Style.manipulationPanBtnActiveColor : (handBtn.hovered ? Style.manipulationPanBtnHoverColor : "transparent")
                        radius: Style.dialogRadius
                    }
                    onClicked: {
                        panMode = !panMode
                        selectedTool = ""
                    }
                }
                RowLayout {
                    spacing: Style.manipulationZoomBtnSpacing
                    CustomButton {
                        icon.source: "../Resources/zoom-out.svg"
                        iconSize: Style.metadataActionIconSize
                        Layout.preferredWidth: Style.metadataActionBtnSize; Layout.preferredHeight: Style.metadataActionBtnSize
                        onClicked: {
                            refitSize()
                            zoomSlider.value = Math.max(zoomSlider.from, zoomSlider.value - 0.2)
                        }
                        tooltipText: "Oddal zdjęcie(Ctrl + -)"
                    }
                    Slider {
                        id: zoomSlider
                        from: 0.1
                        to: 5.0
                        value: 1.0
                        Layout.preferredWidth: Style.manipulationZoomSliderWidth
                        ToolTip.visible: pressed
                        ToolTip.delay: 0
                        ToolTip.text: Math.round(value * 100) + "%"
                        onPressedChanged: {
                            refitSize()
                        }
                        background: Rectangle {
                            x: zoomSlider.leftPadding
                            y: zoomSlider.topPadding + zoomSlider.availableHeight / 2 - height / 2
                            implicitWidth: Style.manipulationZoomSliderBgWidth
                            implicitHeight: Style.manipulationZoomSliderBgHeight
                            width: zoomSlider.availableWidth
                            height: implicitHeight
                            radius: Style.manipulationZoomSliderBgRadius
                            color: Style.manipulationZoomSliderBgColor
                        }
                        handle: Rectangle {
                            x: zoomSlider.leftPadding + zoomSlider.visualPosition * (zoomSlider.availableWidth - width)
                            y: zoomSlider.topPadding + zoomSlider.availableHeight / 2 - height / 2
                            implicitWidth: Style.manipulationZoomSliderHandleSize
                            implicitHeight: Style.manipulationZoomSliderHandleSize
                            radius: Style.manipulationZoomSliderHandleRadius
                            color: Style.manipulationZoomSliderHandleColor
                            border.color: Style.manipulationZoomSliderHandleBorderColor
                        }
                    }
                    CustomButton {
                        icon.source: "../Resources/zoom-in.svg"
                        iconSize: Style.metadataActionIconSize
                        Layout.preferredWidth: Style.metadataActionBtnSize; Layout.preferredHeight: Style.metadataActionBtnSize
                        onClicked: {
                            refitSize()
                            zoomSlider.value = Math.min(zoomSlider.to, zoomSlider.value + 0.2)
                        }
                        tooltipText: "Przybliż zdjęcie(Ctrl + +)"
                    }
                }
                CustomButton {
                    id: fullscreenBtn
                    icon.source: "../Resources/maximize.svg"
                    iconSize: Style.metadataActionIconSize
                    Layout.preferredWidth: Style.metadataActionBtnSize; Layout.preferredHeight: Style.metadataActionBtnSize
                    tooltipText: "Dopasuj do ekranu(Ctrl+F)"
                    onClicked: zoomToFit()
                }
            }
        }
    }
    Image {
        id: originalImageLoader
        source: imageInfo.path
        visible: false
        asynchronous: true
    }
    function zoomToFit() {
        if (photo.status !== Image.Ready) return
        refitSize()
        zoomSlider.value = 1.0
        photo.x = (imageContainer.width - photo.width) / 2
        photo.y = (imageContainer.height - photo.height) / 2
        imageContainer.dragOffsetX = 0
        imageContainer.dragOffsetY = 0
    }
    function refitSize() {
        let containerW = imageContainer.width
        let containerH = imageContainer.height
        let finalScale = 1.0
        if (photo.width > 0 && photo.height > 0) {
            let currentRatioX = containerW / photo.width
            let currentRatioY = containerH / photo.height
            finalScale = Math.min(currentRatioX, currentRatioY)
        }
        fitScale = finalScale
    }
}
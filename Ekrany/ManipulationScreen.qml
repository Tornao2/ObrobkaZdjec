import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../Kontrolki"
import QtQuick.Effects
import "../Style"
Rectangle {
    id: manipulationScreen
    color: Style.dialogBackground
    property var imageInfo: ({})
    property var workingInfo: ({
        "crop": { "x": 0, "y": 0, "w": 1000, "h": 1000 },
        "angle": 0,
        "flipH": 1,
        "flipV": 1,
        "path": "",
        "name": ""
    })
    property var originalInfo: ({
        "crop": { "x": 0, "y": 0, "w": 1000, "h": 1000 },
        "angle": 0,
        "flipH": 1,
        "flipV": 1,
        "path": "",
        "name": ""
    })
    property bool panMode: false
    property var history: []
    property int historyIndex: -1
    property bool isShowingOriginal: false
    property string initialCanvasData: ""
    property real fitScale: 1.0
    property bool blockHistory: false
    signal manipulationFinished(var finalInfo)
    function clone(obj) { return JSON.parse(JSON.stringify(obj)); }
    function saveState() {
        if (blockHistory) return;
        let stateToSave = clone(workingInfo)
        stateToSave.angle = rotationSlider.value;
        if (historyIndex < history.length - 1) {
            history = history.slice(0, historyIndex + 1);
        }
        history.push(stateToSave);
        historyIndex = history.length - 1;
    }
    function applyState(state) {
        if (!state) return;
        blockHistory = true;
        workingInfo = clone(state);
        rotationSlider.value = state.angle;
        blockHistory = false;
    }
    Component.onCompleted: {
        workingInfo = JSON.parse(JSON.stringify(imageInfo));
        originalInfo = JSON.parse(JSON.stringify(imageInfo));
        history = [];
        historyIndex = -1;
        saveState()
        zoomToFit()
    }
    function stripExtension(fileName) {
        if (!fileName) return "";
        return fileName.indexOf('.') !== -1 ? fileName.substring(0, fileName.lastIndexOf('.')) : fileName;
    }
    focus: true
    Keys.forwardTo: [manipulationKeyHandler]
    Item {
        id: manipulationKeyHandler
        Keys.onPressed: (event) => {
            let ctrl = event.modifiers & Qt.ControlModifier
            if (ctrl) {
                if (event.key === Qt.Key_Z) {
                    if (undoBtn.enabled) undoBtn.clicked()
                    event.accepted = true
                } else if (event.key === Qt.Key_Y) {
                    if (redoBtn.enabled) redoBtn.clicked()
                    event.accepted = true
                } else if (event.key === Qt.Key_Plus || event.key === Qt.Key_Equal) {
                    zoomSlider.value = Math.min(zoomSlider.to, zoomSlider.value + 0.2)
                    event.accepted = true
                } else if (event.key === Qt.Key_Minus) {
                    zoomSlider.value = Math.max(zoomSlider.from, zoomSlider.value - 0.2)
                    event.accepted = true
                } else if (event.key === Qt.Key_0) {
                    zoomSlider.value = 1.0
                    photo.x = (imageContainer.width - photo.width) / 2
                    photo.y = (imageContainer.height - photo.height) / 2
                    event.accepted = true
                } else if (event.key === Qt.Key_F) {
                    zoomToFit()
                    event.accepted = true
                }
                return
            }
            switch (event.key) {
                case Qt.Key_R:
                    rotationSlider.value += 90
                    workingInfo.angle = rotationSlider.value
                    saveState()
                    event.accepted = true
                    break
                case Qt.Key_L:
                    rotationSlider.value -= 90
                    workingInfo.angle = rotationSlider.value
                    saveState()
                    event.accepted = true
                    break
                case Qt.Key_H:
                    let dataH = JSON.parse(JSON.stringify(workingInfo))
                    dataH.flipH = (workingInfo.flipH === 1 ? -1 : 1)
                    workingInfo = dataH
                    saveState()
                    event.accepted = true
                    break
                case Qt.Key_V:
                    let dataV = JSON.parse(JSON.stringify(workingInfo))
                    dataV.flipV = (workingInfo.flipV === 1 ? -1 : 1)
                    workingInfo = dataV
                    saveState()
                    event.accepted = true
                    break
            }
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
                text: workingInfo.name
                anchors.centerIn: parent
                font.pixelSize: Style.fontTitleSize; color: Style.baseTextColor
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            Rectangle {
                Layout.preferredWidth: Style.manipulationSidePanelWidth
                Layout.fillHeight: true
                color: Style.dialogBackground
                ScrollView {
                    id: sideScroll
                    anchors.fill: parent
                    Layout.preferredWidth: Style.manipulationSidePanelWidth
                    Layout.maximumWidth: Style.manipulationSidePanelWidth
                    clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ColumnLayout {
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
                        RowLayout {
                            spacing: 0
                            CustomButton {
                                id: undoBtn
                                Layout.fillWidth: true
                                Layout.preferredWidth: Style.metadataActionBtnSize; Layout.preferredHeight: Style.metadataActionBtnSize
                                icon.source: "../Resources/undo.svg"
                                iconSize: Style.metadataActionIconSize
                                enabled: historyIndex > 0
                                opacity: enabled ? 1.0 : Style.metadataDisabledIconOpacity
                                tooltipText: "Cofnij (Ctrl+Z)"
                                onClicked: {
                                    historyIndex--;
                                    applyState(history[historyIndex]);
                                }
                            }
                            CustomButton {
                                id: redoBtn
                                Layout.fillWidth: true
                                enabled: historyIndex < history.length - 1
                                opacity: enabled ? 1.0 : Style.metadataDisabledIconOpacity
                                Layout.preferredWidth: Style.metadataActionBtnSize; Layout.preferredHeight: Style.metadataActionBtnSize
                                icon.source: "../Resources/undo.svg"
                                iconSize: Style.metadataActionIconSize
                                contentItem: Item {
                                    Image {
                                        anchors.centerIn: parent
                                        width: redoBtn.iconSize
                                        height: redoBtn.iconSize
                                        sourceSize.width: redoBtn.iconSize
                                        sourceSize.height: redoBtn.iconSize
                                        source: Style.currentTheme === "dark" ? "../Resources/icons-light/undo.svg" :  "../Resources/undo.svg"
                                        mirror: true
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                        opacity: redoBtn.enabled ? 1.0 : Style.metadataDisabledIconOpacity
                                    }
                                }
                                onClicked: {
                                    historyIndex++;
                                    applyState(history[historyIndex]);
                                }
                                tooltipText: "Ponów (Ctrl+Y)"
                            }
                            CustomButton {
                                id: actionBtn
                                Layout.fillWidth: true
                                Layout.preferredWidth: Style.metadataActionBtnSize; Layout.preferredHeight: Style.metadataActionBtnSize
                                icon.source: "../Resources/transition-right.svg"
                                iconSize: Style.metadataActionIconSize
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
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 2
                            Slider {
                                id: rotationSlider
                                from: -180
                                onPressedChanged: if (!pressed) saveState()
                                onMoved: {
                                    workingInfo.angle = value
                                }
                                to: 180
                                value: workingInfo.angle || 0
                                stepSize: 10
                                orientation: Qt.Vertical
                                snapMode: Slider.SnapAlways
                                Layout.preferredHeight: Style.manipulationRotationSliderHeight
                                Layout.alignment: Qt.AlignCenter
                                Layout.fillWidth: true
                                ToolTip {
                                    parent: rotationSlider.handle
                                    visible: rotationSlider.pressed
                                    text: Math.round(rotationSlider.value) + "°"
                                }
                                background: Rectangle {
                                    implicitWidth: Style.manipulationRotationSliderBgWidth
                                    implicitHeight: Style.manipulationRotationSliderBgHeight
                                    x: rotationSlider.leftPadding + rotationSlider.availableWidth / 2 - width / 2
                                    y: rotationSlider.topPadding
                                    width: implicitWidth
                                    height: rotationSlider.availableHeight
                                    color: "transparent"
                                    Rectangle {
                                        width: Style.manipulationRotationSliderTrackWidth
                                        height: parent.height
                                        anchors.centerIn: parent
                                        color: Style.manipulationRotationSliderTrackColor
                                        radius: 2
                                    }
                                    Repeater {
                                        model: 11
                                        delegate: Rectangle {
                                            property int angle: -150 + (index * 30)
                                            width: angle === 0 ? Style.manipulationRotationSliderTickWidthLarge : Style.manipulationRotationSliderTickWidthSmall
                                            height: angle === 0 ? Style.manipulationRotationSliderTickHeightLarge : Style.manipulationRotationSliderTickHeightSmall
                                            color: angle === 0 ? Style.manipulationRotationSliderTickColorActive : Style.manipulationRotationSliderTickColorInactive
                                            x: (parent.width - width) / 2
                                            y: ((index+1) / 12) * parent.height - height / 2
                                        }
                                    }
                                }
                                handle: Rectangle {
                                    y: rotationSlider.topPadding + rotationSlider.visualPosition * (rotationSlider.availableHeight - height)
                                    x: rotationSlider.leftPadding + rotationSlider.availableWidth / 2 - width / 2
                                    implicitWidth: Style.manipulationRotationSliderHandleSize
                                    implicitHeight: Style.manipulationRotationSliderHandleSize
                                    radius: Style.manipulationRotationSliderHandleRadius
                                    color: rotationSlider.pressed ? Style.manipulationRotationSliderHandlePressedColor : Style.manipulationRotationSliderHandleColor
                                    border.color: Style.manipulationRotationSliderHandleBorderColor
                                }
                            }
                        }
                        GridLayout {
                            columns: 2
                            rows: 2
                            Layout.fillWidth: true
                            columnSpacing: Style.manipulationGridSpacing
                            rowSpacing: Style.manipulationGridSpacing
                            CustomButton {
                                tooltipText: "Odbij horyzontalnie(H)"
                                Layout.fillWidth: true
                                Layout.preferredHeight: Style.manipulationGridBtnSize; Layout.preferredWidth: Style.manipulationGridBtnSize
                                icon.source: "../Resources/arrow-separate.svg"
                                onClicked: {
                                    let data = JSON.parse(JSON.stringify(workingInfo));
                                    data.flipH = (workingInfo.flipH === 1 ? -1 : 1)
                                    workingInfo = data;
                                    saveState()
                                }
                            }
                            CustomButton {
                                tooltipText: "Odbij wertykalnie(V)"
                                Layout.fillWidth: true
                                Layout.preferredHeight: Style.manipulationGridBtnSize; Layout.preferredWidth: Style.manipulationGridBtnSize
                                icon.source: "../Resources/arrow-separate-vertical.svg"
                                onClicked: {
                                    let data = JSON.parse(JSON.stringify(workingInfo));
                                    data.flipV = (workingInfo.flipV === 1 ? -1 : 1)
                                    workingInfo = data;
                                    saveState()
                                }
                            }
                            CustomButton {
                                tooltipText: "Przekręć o 90 stopni w lewo(L)"
                                Layout.fillWidth: true
                                Layout.preferredHeight: Style.manipulationGridBtnSize; Layout.preferredWidth: Style.manipulationGridBtnSize
                                icon.source: "../Resources/rotate-camera-left.svg"
                                onClicked: {
                                    rotationSlider.value = (rotationSlider.value - 90)
                                    workingInfo.angle = rotationSlider.value
                                    saveState()
                                }
                            }
                            CustomButton {
                                tooltipText: "Przekręć o 90 stopni w prawo(R)"
                                Layout.fillWidth: true
                                Layout.preferredHeight: Style.manipulationGridBtnSize; Layout.preferredWidth: Style.manipulationGridBtnSize
                                icon.source: "../Resources/rotate-camera-right.svg"
                                onClicked: {
                                    rotationSlider.value = (rotationSlider.value + 90)
                                    workingInfo.angle = rotationSlider.value
                                    saveState()
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
                                saveState();
                                let finalData = {
                                    "image": initialCanvasData,
                                    "metadata": clone(workingInfo)
                                };
                                manipulationFinished(finalData);
                                mainStack.pop();
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
                    MouseArea {
                        id: dragArea
                        anchors.fill: parent
                        hoverEnabled: panMode
                        propagateComposedEvents: true
                        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                        cursorShape: panMode ? Qt.OpenHandCursor : Qt.ArrowCursor
                        property real lastX: 0
                        property real lastY: 0
                        onPressed: (mouse) => {
                            if (panMode || mouse.button === Qt.MiddleButton) {
                                lastX = mouse.x
                                lastY = mouse.y
                                mouse.accepted = true
                            } else {
                                mouse.accepted = false
                            }
                        }
                        onPositionChanged: (mouse) => {
                            if (pressed && (panMode || (mouse.buttons & Qt.MiddleButton))) {
                                imageContainer.dragOffsetX += mouse.x - lastX
                                imageContainer.dragOffsetY += mouse.y - lastY
                                lastX = mouse.x
                                lastY = mouse.y
                            }
                        }
                        WheelHandler {
                            target: dragArea
                            onWheel: (wheel) => {
                                refitSize()
                                let zoomStep = 0.1
                                if (wheel.angleDelta.y > 0) {
                                    zoomSlider.value = Math.min(zoomSlider.to, zoomSlider.value + zoomStep)
                                } else {
                                    zoomSlider.value = Math.max(zoomSlider.from, zoomSlider.value - zoomStep)
                                }
                            }
                        }
                    }
                    Image {
                        id: photo
                        source: workingInfo.path
                        fillMode: Image.PreserveAspectFit
                        rotation: isShowingOriginal ? originalInfo.angle : rotationSlider.value
                        scale: fitScale * zoomSlider.value
                        transformOrigin: Item.Center
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: imageContainer.dragOffsetX
                        anchors.verticalCenterOffset: imageContainer.dragOffsetY
                        transform: Scale {
                            origin.x: photo.width / 2
                            origin.y: photo.height / 2
                            xScale: isShowingOriginal ? originalInfo.flipH : workingInfo.flipH
                            yScale: isShowingOriginal ? originalInfo.flipV : workingInfo.flipV
                        }
                        Image {
                            id: overlayDrawing
                            z: 100
                            anchors.fill: photo
                            source: (initialCanvasData && initialCanvasData !== "data:,") ? initialCanvasData : ""
                            fillMode: Image.PreserveAspectFit
                            visible: initialCanvasData !== ""
                            smooth: false
                        }
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            id: multiEffectItem
                            contrast: isShowingOriginal ? (originalInfo.contrast/100) : (workingInfo.contrast / 100)
                            saturation: isShowingOriginal ? (originalInfo.saturation / 100) : (workingInfo.saturation / 100)
                            brightness: isShowingOriginal ? (originalInfo.exposition / 100) : (workingInfo.exposition / 100)
                            blurEnabled: isShowingOriginal ? (originalInfo.blur > 0) : (workingInfo.blur > 0)
                            blur: isShowingOriginal ? (originalInfo.blur / 100) : (workingInfo.blur / 100)
                            colorization: isShowingOriginal ? Math.abs(originalInfo.temperature / 100) : Math.abs(workingInfo.temperature / 100)
                            colorizationColor: {
                                let temp = isShowingOriginal ? originalInfo.temperature : workingInfo.temperature;
                                return temp > 0 ? "#FFCC00" : "#00CCFF";
                            }
                            layer.enabled: true
                            layer.effect: ShaderEffect {
                                property var source: multiEffectItem
                                property real f_negatyw: (isShowingOriginal ? originalInfo.f_negatyw : workingInfo.f_negatyw) / 100.0
                                property real f_krawedzie: (isShowingOriginal ? originalInfo.f_krawedzie : workingInfo.f_krawedzie) / 100.0
                                property real f_szum: (isShowingOriginal ? originalInfo.f_szum : workingInfo.f_szum) / 100.0
                                property real f_rozmycie_kol: (isShowingOriginal ? originalInfo.f_rozmycie_kol : workingInfo.f_rozmycie_kol) / 100.0
                                property real f_pixel_art: (isShowingOriginal ? originalInfo.f_pixel_art : workingInfo.f_pixel_art) / 100.0
                                property real f_stary_film: (isShowingOriginal ? originalInfo.f_stary_film : workingInfo.f_stary_film) / 100.0
                                property real f_cieple_lato: (isShowingOriginal ? originalInfo.f_cieple_lato : workingInfo.f_cieple_lato) / 100.0
                                property real f_progowanie: (isShowingOriginal ? originalInfo.f_progowanie : workingInfo.f_progowanie) / 100.0
                                property real f_sepia_retro: (isShowingOriginal ? originalInfo.f_sepia_retro : workingInfo.f_sepia_retro) / 100.0
                                property real f_zimna_noc: (isShowingOriginal ? originalInfo.f_zimna_noc : workingInfo.f_zimna_noc) / 100.0
                                property real srcWidth: photo.sourceSize.width
                                property real srcHeight: photo.sourceSize.height
                                fragmentShader: "qrc:/shaders/filters.frag.qsb"
                            }
                        }
                    }
                    Item {
                        id: imagePixels
                        x: photo.x + (photo.width - photo.paintedWidth) / 2
                        y: photo.y + (photo.height - photo.paintedHeight) / 2
                        width: photo.paintedWidth
                        height: photo.paintedHeight
                        scale: photo.scale
                        rotation: photo.rotation
                        transformOrigin: Item.Center
                        transform: Scale {
                            origin.x: photo.width / 2
                            origin.y: photo.height / 2
                            xScale: isShowingOriginal ? originalInfo.flipH : workingInfo.flipH
                            yScale: isShowingOriginal ? originalInfo.flipV : workingInfo.flipV
                        }
                        Rectangle {
                            id: maskTop
                            x: 0; y: 0; width: parent.width; height: (isShowingOriginal ? originalInfo.crop.y : workingInfo.crop.y)
                            color: Style.manipulationCropMaskColor
                        }
                        Rectangle {
                            id: maskBottom
                            x: 0; y: (isShowingOriginal ? (originalInfo.crop.y + originalInfo.crop.h) : (workingInfo.crop.y + workingInfo.crop.h))
                            width: parent.width
                            height: parent.height - y
                            color: Style.manipulationCropMaskColor
                        }
                        Rectangle {
                            id: maskLeft
                            x: 0;
                            y: (isShowingOriginal ? originalInfo.crop.y : workingInfo.crop.y)
                            width: (isShowingOriginal ? originalInfo.crop.x : workingInfo.crop.x)
                            height: (isShowingOriginal ? originalInfo.crop.h : workingInfo.crop.h)
                            color: Style.manipulationCropMaskColor
                        }
                        Rectangle {
                            id: maskRight
                            x: (isShowingOriginal ? (originalInfo.crop.x + originalInfo.crop.w) : (workingInfo.crop.x + workingInfo.crop.w))
                            y: (isShowingOriginal ? originalInfo.crop.y : workingInfo.crop.y)
                            width: parent.width - x
                            height: (isShowingOriginal ? originalInfo.crop.h : workingInfo.crop.h)
                            color: Style.manipulationCropMaskColor
                        }
                        Rectangle {
                            id: cropRect
                            x: (isShowingOriginal ? originalInfo.crop.x : workingInfo.crop.x)
                            y: (isShowingOriginal ? originalInfo.crop.y : workingInfo.crop.y)
                            width: (isShowingOriginal ? originalInfo.crop.w : workingInfo.crop.w)
                            height: (isShowingOriginal ? originalInfo.crop.h : workingInfo.crop.h)
                            color: "transparent"
                            border.color: Style.baseTextColor
                            border.width: Math.max(1, 2 / photo.scale)
                            Rectangle {
                                id: topLeftHandle
                                width: Style.manipulationCropHandleBaseSize / photo.scale; height: Style.manipulationCropHandleBaseSize / photo.scale
                                color: Style.manipulationCropHandleColor; radius: width/2; border.color: Style.manipulationCropHandleBorderColor
                                x: -width/2; y: -height/2
                                z: 10
                                MouseArea {
                                    preventStealing: true
                                    anchors.fill: parent
                                    cursorShape: Qt.SizeFDiagCursor
                                    onReleased: saveState()
                                    onPositionChanged: (mouse) => {
                                       if (pressed) {
                                           let pos = mapToItem(imagePixels, mouse.x, mouse.y)
                                           let anchorX = workingInfo.crop.x + workingInfo.crop.w
                                           let anchorY = workingInfo.crop.y + workingInfo.crop.h
                                           let newX = Math.max(0, Math.min(pos.x, anchorX - 10))
                                           let newY = Math.max(0, Math.min(pos.y, anchorY - 10))
                                           let info = clone(workingInfo)
                                           info.crop = {
                                               "x": newX,
                                               "y": newY,
                                               "w": anchorX - newX,
                                               "h": anchorY - newY
                                           }
                                           workingInfo = info
                                       }
                                    }
                                }
                            }
                            Rectangle {
                                id: bottomRightHandle
                                width: Style.manipulationCropHandleBaseSize / photo.scale; height: Style.manipulationCropHandleBaseSize / photo.scale
                                color: Style.manipulationCropHandleColor; radius: width/2; border.color: Style.manipulationCropHandleBorderColor
                                x: cropRect.width - width / 2
                                y: cropRect.height - height / 2
                                z: 10
                                MouseArea {
                                    preventStealing: true
                                    anchors.fill: parent
                                    cursorShape: Qt.SizeFDiagCursor
                                    onReleased: saveState()
                                    onPositionChanged: (mouse) => {
                                       if (pressed) {
                                            let pos = mapToItem(imagePixels, mouse.x, mouse.y)
                                            let newW = Math.max(10, Math.min(pos.x - workingInfo.crop.x, imagePixels.width - workingInfo.crop.x))
                                            let newH = Math.max(10, Math.min(pos.y - workingInfo.crop.y, imagePixels.height - workingInfo.crop.y))
                                            let info = clone(workingInfo)
                                           info.crop = {
                                               "x": workingInfo.crop.x,
                                               "y": workingInfo.crop.y,
                                               "w": newW,
                                               "h": newH
                                           }
                                           workingInfo = info
                                        }
                                    }
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: 15 / photo.scale
                                cursorShape: Qt.SizeAllCursor
                                property real startXInImage: 0
                                property real startYInImage: 0
                                property real startCropX: 0
                                property real startCropY: 0
                                onReleased: saveState()
                                onPressed: (mouse) => {
                                   let pos = mapToItem(imagePixels, mouse.x, mouse.y)
                                   startXInImage = pos.x
                                   startYInImage = pos.y
                                   startCropX = workingInfo.crop.x
                                   startCropY = workingInfo.crop.y
                                }
                                onPositionChanged: (mouse) => {
                                   if (pressed) {
                                        let currentPosInImage = mapToItem(imagePixels, mouse.x, mouse.y)
                                        let diffX = currentPosInImage.x - startXInImage
                                        let diffY = currentPosInImage.y - startYInImage
                                        let info = clone(workingInfo)
                                        info.crop = {
                                            "x": Math.max(0, Math.min(startCropX + diffX, imagePixels.width - workingInfo.crop.w)),
                                            "y": Math.max(0, Math.min(startCropY + diffY, imagePixels.height - workingInfo.crop.h)),
                                            "w": workingInfo.crop.w,
                                            "h": workingInfo.crop.h
                                        }
                                        workingInfo = info
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
                    onClicked: panMode = !panMode
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
                        onPressedChanged: refitSize()
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
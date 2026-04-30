import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import "../Kontrolki"

Rectangle {
    id: correctionScreen
    color: "#8E9191"
    property var imageInfo: ({})
    property var currentMetadata: ({
        "contrast": 0,
        "saturation": 0,
        "exposition": 0,
        "temperature": 0,
        "blur": 0,
        "flipH": 1,
        "flipV": 1
    })
    property var originalMetadata: currentMetadata
    property bool panMode: false
    property var history: []
    property int historyIndex: -1
    property bool isShowingOriginal: false
    property bool blockHistory: false
    property string initialCanvasData: ""
    signal correctionFinished(var finalInfo)
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
    focus: true
    Keys.forwardTo: [globalKeyHandler]
    Item {
        id: globalKeyHandler
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
        }
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
                            onClicked: {
                                historyIndex++;
                                applyState(history[historyIndex]);
                            }
                            tooltipText: "Ponów (Ctrl+Y)"
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
                    CorrectionSlider {
                        title: "Kontrast"
                        from: -100
                        to: 100
                        value: isShowingOriginal ? originalMetadata.contrast : currentMetadata.contrast
                        Layout.fillWidth: true
                        onMoved: {
                            let data = clone(currentMetadata)
                            data.contrast = value
                            currentMetadata = data

                        }
                        onPressedChanged: {
                                if (!pressed) {
                                    saveState();
                                }
                            }
                    }
                    CorrectionSlider {
                        title: "Nasycenie"
                        from: -100
                        to: 100
                        value: isShowingOriginal ? originalMetadata.saturation : currentMetadata.saturation
                        Layout.fillWidth: true
                        onMoved: {
                            let data = clone(currentMetadata)
                            data.saturation = value
                            currentMetadata = data

                        }
                        onPressedChanged: {
                                if (!pressed) {
                                    saveState();
                                }
                            }
                    }
                    CorrectionSlider {
                        title: "Ekspozycja"
                        from: -100
                        to: 100
                        value: isShowingOriginal ? originalMetadata.exposition : currentMetadata.exposition
                        Layout.fillWidth: true
                        onMoved: {

                                let data = clone(currentMetadata)
                                data.exposition = value
                                currentMetadata = data

                        }
                        onPressedChanged: {
                                if (!pressed) {
                                    saveState();
                                }
                            }
                    }
                    CorrectionSlider {
                        title: "Temperatura"
                        from: -100
                        to: 100
                        value: isShowingOriginal ? originalMetadata.temperature : currentMetadata.temperature
                        Layout.fillWidth: true
                        onMoved: {
                                let data = clone(currentMetadata)
                                data.temperature = value
                                currentMetadata = data

                        }
                        onPressedChanged: {
                                if (!pressed) {
                                    saveState();
                                }
                            }
                    }
                    CorrectionSlider {
                        title: "Rozmycie"
                        from: 0
                        to: 100
                        value: isShowingOriginal ? originalMetadata.blur : currentMetadata.blur
                        Layout.fillWidth: true
                        onMoved: {
                                let data = clone(currentMetadata)
                                data.blur = value
                                currentMetadata = data
                        }
                        onPressedChanged: {
                                if (!pressed) {
                                    saveState();
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
                            let finalImage = drawingCanvas.toDataURL("image/png");
                            let finalData = {
                                "image": finalImage,
                                "metadata": clone(currentMetadata)
                            };
                            correctionFinished(finalData);
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
                        Canvas {
                            id: drawingCanvas
                            z: 100
                            anchors.fill: parent
                            renderTarget: Canvas.Image
                            renderStrategy: Canvas.Threaded
                            property bool contextReady: false
                            onAvailableChanged: {
                                if (available && correctionScreen.initialCanvasData !== "") {
                                    loadImage(correctionScreen.initialCanvasData);
                                }
                            }
                            onImageLoaded: {
                                var ctx = getContext("2d");
                                ctx.imageSmoothingEnabled = false;
                                ctx.drawImage(correctionScreen.initialCanvasData, 0, 0, width, height);
                                requestPaint();
                            }
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
                            if (mouse.button === Qt.MiddleButton) {
                                mouse.accepted = true
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
                    onClicked: panMode = !panMode
                }
                RowLayout {
                    spacing: 5
                    CustomButton {
                        icon.source: "../Resources/zoom-out.svg"
                        iconSize: 35
                        Layout.preferredWidth: 50; Layout.preferredHeight: 50
                        onClicked: zoomSlider.value = Math.max(zoomSlider.from, zoomSlider.value - 0.2)
                        tooltipText: "Oddal zdjęcie(Ctrl + -)"
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
                        tooltipText: "Przybliż zdjęcie(Ctrl + +)"
                    }
                }
                CustomButton {
                    id: fullscreenBtn
                    icon.source: "../Resources/maximize.svg"
                    iconSize: 35
                    Layout.preferredWidth: 50; Layout.preferredHeight: 50
                    tooltipText: "Dopasuj do ekranu(Ctrl+F)"
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
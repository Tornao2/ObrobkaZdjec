import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../Kontrolki"
import QtQuick.Dialogs
import QtCore
import QtQuick.Effects
import "../Style"
Rectangle {
    id: editorScreen
    color: Style.dialogBackground
    property bool isPrinting: false
    property bool isSaving: false
    signal changesSaved(var finalState)
    property bool panMode: false
    property string imagePath: ""
    property string originalImagePath: ""
    property var history: []
    property int historyIndex: -1
    property bool isShowingOriginal: false
    property var currentMetadata: ({})
    property var originalMetadata: ({})
    property var tempMetadata: ({})
    property real fitScale: 1.0
    function initializeMetadata(data) {
        currentMetadata = data
        originalMetadata = Object.assign({}, data)
    }
    function commitState() {
        let state = {
            "metadata": Object.assign({}, currentMetadata)
        }
        let newHistory = history.slice(0, historyIndex + 1)
        newHistory.push(state)
        history = newHistory
        historyIndex = history.length - 1
    }
    function clone(obj) { return JSON.parse(JSON.stringify(obj)); }
    Component.onCompleted: {
        if (originalImagePath === "") {
            originalImagePath = imagePath
        }
        let initialData = {
            "path": editorScreen.imagePath,
            "name": editorScreen.imagePath.split("/").pop(),
            "format": editorScreen.imagePath.split(".").pop(),
            "w": photo.implicitWidth,
            "h": photo.implicitHeight,
            "dpi": "300 dpi",
            "depth": "24-bit",
            "fileSize": "3.2 MB",
            "date": "2024-05-12 14:30",
            "cameraModel": "Sony Alpha a7 IV",
            "iso": "400",
            "fStop": "f/2.8",
            "shutterSpeed": "1/200s",
            "artist": "Jan Kowalski",
            "copyright": "© 2024 Kowalski Studio. All rights reserved.",
            "description": "Sesja plenerowa - Park Narodowy, zachód słońca.",
            "contrast": 0,
            "saturation": 0,
            "exposition": 0,
            "temperature": 0,
            "blur": 0,
            "flipH" : 1,
            "flipV" : 1,
            "angle" : 0,
            "crop": {
                "x": 0,
                "y": 0,
                "w": photo.implicitWidth,
                "h": photo.implicitHeight
            },
            "f_krawedzie": 0,
            "f_szum": 0,
            "f_rozmycie_kol": 0,
            "f_pixel_art": 0,
            "f_stary_film": 0,
            "f_negatyw": 0,
            "f_progowanie": 0,
            "f_sepia_retro": 0,
            "f_zimna_noc": 0,
            "f_cieple_lato": 0
        }
        currentMetadata = initialData
        originalMetadata = Object.assign({}, initialData)
        commitState()
        zoomToFit()
        editorScreen.forceActiveFocus()
    }
    Timer {
        id: saveTimer
        interval: 50
        repeat: true
        onTriggered: {
            if (saveProgressBar.value < 1.0) {
                saveProgressBar.value += 0.02
            } else {
                saveTimer.stop()
                isSaving = false
                saveSuccessMessage.open()
                saveProgressBar.value = 0
            }
        }
    }
    Timer {
        id: printTimer
        interval: 2500
        onTriggered: {
            isPrinting = false
            printSuccessMessage.open()
        }
    }
    focus: true
    Keys.forwardTo: [editorKeyHandler]
    Item {
        id: editorKeyHandler
        Keys.onPressed: (event) => {
            refitSize()
            let ctrl = event.modifiers & Qt.ControlModifier
            if (ctrl) {
                if (event.key === Qt.Key_Z) {
                    if (undoBtn.enabled) undoBtn.clicked()
                    event.accepted = true
                } else if (event.key === Qt.Key_Y) {
                    if (redoBtn.enabled) redoBtn.clicked()
                    event.accepted = true
                } else if (event.key === Qt.Key_S) {
                    if (saveBtn.enabled) saveBtn.clicked()
                    event.accepted = true
                } else if (event.key === Qt.Key_P) {
                    if (printBtn.enabled) printBtn.clicked()
                    event.accepted = true
                } else if (event.key === Qt.Key_C) {
                    copyBtn.clicked()
                    event.accepted = true
                } else if (event.key === Qt.Key_I) {
                    importBtn.clicked()
                    event.accepted = true
                } else if (event.key === Qt.Key_Plus || event.key === Qt.Key_Equal) {
                    zoomSlider.value = Math.min(zoomSlider.to, zoomSlider.value + 0.2)
                    event.accepted = true
                } else if (event.key === Qt.Key_Minus) {
                    zoomSlider.value = Math.max(zoomSlider.from, zoomSlider.value - 0.2)
                    event.accepted = true
                } else if (event.key === Qt.Key_0) {
                    photo.x = (imageContainer.width - photo.width) / 2
                    photo.y = (imageContainer.height - photo.height) / 2
                    zoomSlider.value = 1.0
                    event.accepted = true
                } else if (event.key === Qt.Key_F) {
                    zoomToFit()
                    event.accepted = true
                }
                return
            }
            switch (event.key) {
                case Qt.Key_Delete:
                    deleteBtn.clicked()
                    event.accepted = true
                    break
                case Qt.Key_F1:  case Qt.Key_F2:  case Qt.Key_F3:  case Qt.Key_F4:
                case Qt.Key_F5:  case Qt.Key_F6:  case Qt.Key_F7:  case Qt.Key_F8:
                case Qt.Key_F9:  case Qt.Key_F10: case Qt.Key_F11: case Qt.Key_F12:
                    let btnIndex = event.key - Qt.Key_F1;
                    let btn = repeaterId.itemAt(btnIndex);
                    if (btn) {
                        triggerEditorAction(btn.assignedFunction);
                    }
                    event.accepted = true;
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
                text: currentMetadata.name || ""
                anchors.centerIn: parent
                font.pixelSize: Style.fontTitleSize; color: Style.baseTextColor
            }
            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                CustomButton {
                    id: deleteBtn
                    Layout.preferredWidth: Style.metadataActionBtnSize; Layout.preferredHeight: Style.metadataActionBtnSize
                    icon.source: "../Resources/trash.svg"
                    iconSize: Style.metadataActionIconSize
                    tooltipText: "Usuń(Delete)"
                    onClicked: deleteConfirm.open()
                }
                CustomButton {
                    id: printBtn
                    Layout.preferredWidth: Style.metadataActionBtnSize; Layout.preferredHeight: Style.metadataActionBtnSize
                    icon.source: "../Resources/printer.svg"
                    iconSize: Style.metadataActionIconSize
                    tooltipText: "Drukuj(Ctrl+P)"
                    enabled: !isPrinting
                    opacity: isPrinting ? (printingAnim.running ? 1.0 : Style.editorPrintingBtnDisabledOpacity) : 1.0
                    SequentialAnimation on opacity {
                        id: printingAnim
                        running: editorScreen.isPrinting
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: Style.editorPrintingAnimOpacityMin; duration: 600 }
                        NumberAnimation { from: Style.editorPrintingAnimOpacityMin; to: 1.0; duration: 600 }
                    }
                    onClicked: {
                        isPrinting = true
                        printTimer.start()
                    }
                }
                CustomButton {
                    id: copyBtn
                    Layout.preferredWidth: Style.metadataActionBtnSize; Layout.preferredHeight: Style.metadataActionBtnSize
                    icon.source: "../Resources/copy.svg"
                    iconSize: Style.metadataActionIconSize
                    tooltipText: "Kopiuj(Ctrl+C)"
                    onClicked: {
                        copySuccessDialog.open()
                    }
                }
                CustomButton {
                    id: importBtn
                    Layout.preferredWidth: Style.metadataActionBtnSize; Layout.preferredHeight: Style.metadataActionBtnSize
                    icon.source: "../Resources/download.svg"
                    iconSize: Style.metadataActionIconSize
                    tooltipText: "Importuj(Ctrl+I)"
                    onClicked: importFileDialog.open()
                }
                CustomButton {
                    id: saveBtn
                    Layout.preferredWidth: Style.metadataActionBtnSize; Layout.preferredHeight: Style.metadataActionBtnSize
                    icon.source: "../Resources/floppy-disk.svg"
                    iconSize: Style.metadataActionIconSize
                    tooltipText: "Zapisz(Ctrl+S)"
                    enabled: !isSaving && !isPrinting
                        onClicked: {
                            isSaving = true
                            saveTimer.start()
                        }
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 200
            spacing: 0
            Rectangle {
                Layout.preferredWidth: Style.manipulationSidePanelWidth
                Layout.fillHeight: true
                color: Style.dialogBackground
                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Style.manipulationPanelMargin
                    anchors.rightMargin: Style.manipulationPanelMargin
                    spacing: Style.manipulationPanelSpacing
                    Button {
                        id: resetBtn
                        text: "Reset"
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
                        onClicked: resetConfirm.open()
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
                                historyIndex--
                                let state = JSON.parse(JSON.stringify(history[historyIndex]));
                                currentMetadata = JSON.parse(JSON.stringify(state.metadata));
                                photo.rotation = currentMetadata.angle
                                photo.sourceClipRect = Qt.rect(
                                    currentMetadata.crop.x,
                                    currentMetadata.crop.y,
                                    currentMetadata.crop.w,
                                    currentMetadata.crop.h
                                )
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
                            tooltipText: "Ponów (Ctrl+Y)"
                            onClicked: {
                                historyIndex++
                                let state = JSON.parse(JSON.stringify(history[historyIndex]));
                                currentMetadata = JSON.parse(JSON.stringify(state.metadata));
                                photo.rotation = currentMetadata.angle
                                photo.sourceClipRect = Qt.rect(
                                    currentMetadata.crop.x,
                                    currentMetadata.crop.y,
                                    currentMetadata.crop.w,
                                    currentMetadata.crop.h
                                )
                            }
                        }
                        CustomButton {
                            id: actionBtn
                            Layout.fillWidth: true
                            Layout.preferredWidth: Style.metadataActionBtnSize; Layout.preferredHeight: Style.metadataActionBtnSize
                            icon.source: "../Resources/transition-right.svg"
                            iconSize: Style.metadataActionIconSize
                            tooltipText: "Pokaż zmiany"
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    isShowingOriginal = true
                                    photo.source = originalImagePath
                                    tempMetadata = currentMetadata
                                    currentMetadata = originalMetadata
                                    photo.rotation = currentMetadata.angle
                                    photo.sourceClipRect = Qt.rect(
                                        currentMetadata.crop.x,
                                        currentMetadata.crop.y,
                                        currentMetadata.crop.w,
                                        currentMetadata.crop.h
                                    )
                                }
                                onExited: {
                                    isShowingOriginal = false
                                    photo.source = imagePath
                                    currentMetadata = tempMetadata
                                    photo.rotation = currentMetadata.angle
                                    photo.sourceClipRect = Qt.rect(
                                        currentMetadata.crop.x,
                                        currentMetadata.crop.y,
                                        currentMetadata.crop.w,
                                        currentMetadata.crop.h
                                    )
                                }
                            }
                        }
                    }
                    ListView {
                        id: cornerButtonList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: Style.editorCornerListSpacing
                        clip: true
                        model: 12
                        delegate: CornerButton {
                            width: ListView.view.width
                            height: Style.menuItemHeight
                            settingsCategory: "slot" + (index + 1)
                            onFunctionActivated: (name) => triggerEditorAction(name)
                        }
                        ScrollBar.vertical: ScrollBar {
                            id: scrollB
                            anchors.right: parent.right
                            visible: scrollB.active || scrollB.hovered
                            contentItem: Rectangle {
                                implicitWidth: Style.editorCornerScrollBarWidth
                                radius: Style.editorCornerScrollBarRadius
                                color: scrollB.pressed ? Style.secondaryTextColor : Style.disabledTextColor
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
                        source: isShowingOriginal ? originalImagePath : imagePath
                        fillMode: Image.PreserveAspectFit
                        scale: fitScale * zoomSlider.value
                        transformOrigin: Item.Center
                        asynchronous: false
                        cache: false
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: imageContainer.dragOffsetX
                        anchors.verticalCenterOffset: imageContainer.dragOffsetY
                        transform: Scale {
                            origin.x: photo.width / 2
                            origin.y: photo.height / 2
                            xScale: isShowingOriginal ? originalMetadata.flipH : currentMetadata.flipH
                            yScale: isShowingOriginal ? originalMetadata.flipV : currentMetadata.flipV
                        }
                        onStatusChanged: {
                            if (status === Image.Ready) {
                                let updated = Object.assign({}, currentMetadata)
                                updated.w = sourceSize.width;
                                updated.h = sourceSize.height;
                                if (!updated.crop) {
                                    updated.crop = { "x": 0, "y": 0, "w": 0, "h": 0 };
                                }
                                if (updated.crop.w <= 0) {
                                    updated.crop.x = 0;
                                    updated.crop.y = 0;
                                    updated.crop.w = sourceSize.width;
                                    updated.crop.h = sourceSize.height;
                                }
                                currentMetadata = updated;
                                if (originalMetadata.w <= 0 || !originalMetadata.w){
                                    originalMetadata.w = sourceSize.width;
                                    originalMetadata.h = sourceSize.height;
                                }
                                if (!originalMetadata.crop || originalMetadata.crop.w <= 0) {
                                    originalMetadata.crop = { "x": 0, "y": 0, "w": 0, "h": 0 };
                                    originalMetadata.crop.w = sourceSize.width;
                                    originalMetadata.crop.h = sourceSize.height;
                                }
                                photo.sourceClipRect = Qt.rect(
                                    updated.crop.x, updated.crop.y,
                                    updated.crop.w, updated.crop.h
                                );
                                zoomToFit();
                            }
                        }
                        Canvas {
                            id: drawingCanvas
                            z: 100
                            anchors.fill: parent
                            renderTarget: Canvas.Image
                            renderStrategy: Canvas.Threaded
                            property bool contextReady: false
                            property string pendingImage: ""
                            property string initialCanvasData: ""
                            onAvailableChanged: {
                                if (available && initialCanvasData !== "") {
                                    loadImage(initialCanvasData);
                                }
                            }
                            onImageLoaded: {
                                var ctx = getContext("2d");
                                ctx.imageSmoothingEnabled = false;
                                if (pendingImage !== "") {
                                    ctx.clearRect(0, 0, width, height);
                                    ctx.drawImage(pendingImage, 0, 0, width, height);
                                    pendingImage = "";
                                } else if (manipulationScreen.initialCanvasData !== "") {
                                    ctx.drawImage(manipulationScreen.initialCanvasData, 0, 0, width, height);
                                }
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
                            if (mouse.button === Qt.MiddleButton || panMode) {
                                dragArea.lastX = mouse.x
                                dragArea.lastY = mouse.y
                                mouse.accepted = true
                            }
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
            RowLayout {
                anchors.leftMargin: Style.editorBottomBarMargin
                anchors.rightMargin: Style.editorBottomBarMargin
                anchors.fill: parent
                spacing: Style.editorBottomBarSpacing
                CustomButton {
                    id: cropBtn
                    Layout.minimumWidth: Style.editorToolBtnMinWidth
                    Layout.preferredHeight: Style.editorToolBtnHeight
                    contentItem: Row {
                        id: rowContent
                        spacing: Style.editorToolBtnSpacing
                        leftPadding: Style.editorToolBtnPadding; rightPadding: Style.editorToolBtnPadding
                        Image { source: Style.currentTheme === "dark" ? "../Resources/icons-light/crop.svg" :  "../Resources/crop.svg"; width: Style.editorToolBtnIconSize; height: Style.editorToolBtnIconSize; sourceSize: Qt.size(Style.editorToolBtnIconSize, Style.editorToolBtnIconSize); anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "Kadrowanie"; font.pixelSize: Style.fontTitleSize; color: Style.baseTextColor; anchors.verticalCenter: parent.verticalCenter }
                    }
                    onClicked: {
                        let manipPage = mainStack.push("ManipulationScreen.qml", { "imageInfo": currentMetadata, "initialCanvasData": drawingCanvas.toDataURL("image/png")  })
                        manipPage.manipulationFinished.connect(function(info) {
                            currentMetadata = info.metadata
                            photo.autoTransform = true
                            photo.rotation = currentMetadata.angle
                            photo.sourceClipRect = Qt.rect(currentMetadata.crop.x, currentMetadata.crop.y, currentMetadata.crop.w, currentMetadata.crop.h)
                            drawingCanvas.pendingImage = info.image;
                            drawingCanvas.loadImage(info.image);
                            commitState()
                            editorScreen.forceActiveFocus()
                        })
                        zoomToFit()
                    }
                }
                CustomButton {
                    id: adjustBtn
                    Layout.minimumWidth: Style.editorToolBtnMinWidth
                    Layout.preferredHeight: Style.editorToolBtnHeight
                    contentItem: Row {
                        id: rowContent2
                        spacing: Style.editorToolBtnSpacing
                        leftPadding: Style.editorToolBtnPadding; rightPadding: Style.editorToolBtnPadding
                        Image { source: Style.currentTheme === "dark" ? "../Resources/icons-light/sun-light.svg" :  "../Resources/sun-light.svg"; width: Style.editorToolBtnIconSize; height: Style.editorToolBtnIconSize; sourceSize: Qt.size(Style.editorToolBtnIconSize, Style.editorToolBtnIconSize); anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "Postprodukcja"; font.pixelSize: Style.fontTitleSize; color: Style.baseTextColor; anchors.verticalCenter: parent.verticalCenter }
                    }
                    onClicked: {
                        let correctPage = mainStack.push("CorrectionScreen.qml", { "imageInfo": currentMetadata, "initialCanvasData": drawingCanvas.toDataURL("image/png") })
                        correctPage.correctionFinished.connect(function(info) {
                            currentMetadata = info.metadata
                            drawingCanvas.pendingImage = info.image;
                            drawingCanvas.loadImage(info.image);
                            commitState()
                            editorScreen.forceActiveFocus()
                        })
                        zoomToFit()
                    }
                }
                CustomButton {
                    id: filtersBtn
                    Layout.minimumWidth: Style.editorToolBtnMinWidth
                    Layout.preferredHeight: Style.editorToolBtnHeight
                    contentItem: Row {
                        id: rowContent3
                        spacing: Style.editorToolBtnSpacing
                        leftPadding: Style.editorToolBtnPadding; rightPadding: Style.editorToolBtnPadding
                        Image { source: Style.currentTheme === "dark" ? "../Resources/icons-light/color-filter.svg" :  "../Resources/color-filter.svg"; width: Style.editorToolBtnIconSize; height: Style.editorToolBtnIconSize; sourceSize: Qt.size(Style.editorToolBtnIconSize, Style.editorToolBtnIconSize); anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "Filtry"; font.pixelSize: Style.fontTitleSize; color: Style.baseTextColor; anchors.verticalCenter: parent.verticalCenter }
                    }
                    onClicked: {
                        let filterPage = mainStack.push("FilterScreen.qml", { "imageInfo": currentMetadata, "initialCanvasData": drawingCanvas.toDataURL("image/png") })
                        filterPage.filteringFinished.connect(function(info) {
                            currentMetadata = info.metadata
                            drawingCanvas.pendingImage = info.image;
                            drawingCanvas.loadImage(info.image);
                            commitState()
                            editorScreen.forceActiveFocus()
                        })
                        zoomToFit()
                    }
                }
                CustomButton {
                    id: drawBtn
                    Layout.minimumWidth: Style.editorToolBtnMinWidth
                    Layout.preferredHeight: Style.editorToolBtnHeight
                    contentItem: Row {
                        id: rowContent4
                        spacing: Style.editorToolBtnSpacing
                        leftPadding: Style.editorToolBtnPadding; rightPadding: Style.editorToolBtnPadding
                        Image { source: Style.currentTheme === "dark" ? "../Resources/icons-light/edit-pencil.svg" :  "../Resources/edit-pencil.svg"; width: Style.editorToolBtnIconSize; height: Style.editorToolBtnIconSize; sourceSize: Qt.size(Style.editorToolBtnIconSize, Style.editorToolBtnIconSize); anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "Rysunek"; font.pixelSize: Style.fontTitleSize; color: Style.baseTextColor; anchors.verticalCenter: parent.verticalCenter }
                    }
                    onClicked: {
                        let drawPage = mainStack.push("DrawingScreen.qml", { "imageInfo": currentMetadata, "initialCanvasData": drawingCanvas.toDataURL("image/png") })
                        drawPage.drawingFinished.connect(function(info) {
                            currentMetadata = info.metadata
                            drawingCanvas.pendingImage = info.image;
                            drawingCanvas.loadImage(info.image);
                            commitState()
                            editorScreen.forceActiveFocus()
                        })
                        zoomToFit()
                    }
                }
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.manipulationBottomBarHeight2
            color: Style.manipulationBottomBarColor2
            RowLayout {
                anchors.fill: parent
                CustomButton {
                    icon.source: "../Resources/info-circle.svg"
                    iconSize: Style.metadataActionIconSize
                    Layout.preferredWidth: Style.metadataActionBtnSize; Layout.preferredHeight: Style.metadataActionBtnSize
                    tooltipText: "Edytuj metadane"
                    onClicked: {
                        let pg = mainStack.push("MetadataScreen.qml", { "imageInfo": currentMetadata  })
                        pg.metadataUpdated.connect(function(updatedData) {
                            if (JSON.stringify(currentMetadata) !== JSON.stringify(updatedData)) {
                                currentMetadata = updatedData
                                commitState()
                                editorScreen.forceActiveFocus()
                            }
                        })
                    }
                }
                Row {
                    spacing: Style.manipulationZoomBtnSpacing
                    Layout.alignment: Qt.AlignVCenter
                    Image {
                        source: Style.currentTheme === "dark" ? "../Resources/icons-light/crop.svg" :  "../Resources/crop.svg"
                        width: Style.editorToolBtnIconSize; height: Style.editorToolBtnIconSize
                        sourceSize: Qt.size(Style.editorToolBtnIconSize, Style.editorToolBtnIconSize)
                        fillMode: Image.PreserveAspectFit
                        opacity: Style.editorInfoIconOpacity
                    }
                    Text {
                        text: currentMetadata.w + " x " + currentMetadata.h
                        font.pixelSize: Style.fontTitleSize
                        color: Style.secondaryTextColor
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                Row {
                    Layout.leftMargin: Style.manipulationPanelMargin
                    spacing: Style.manipulationZoomBtnSpacing
                    Layout.alignment: Qt.AlignVCenter
                    Image {
                        source: Style.currentTheme === "dark" ? "../Resources/icons-light/floppy-disk.svg" :  "../Resources/floppy-disk.svg"
                        width: Style.editorToolBtnIconSize; height: Style.editorToolBtnIconSize
                        sourceSize: Qt.size(Style.editorToolBtnIconSize, Style.editorToolBtnIconSize)
                        fillMode: Image.PreserveAspectFit
                        opacity: Style.editorInfoIconOpacity
                    }
                    Text {
                        text: "3.2MB"
                        font.pixelSize: Style.fontTitleSize
                        color: Style.secondaryTextColor
                        verticalAlignment: Text.AlignVCenter
                    }
                }
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
                        onPressedChanged: {
                            refitSize()
                        }
                        ToolTip.text: Math.round(value * 100) + "%"
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
    Rectangle {
        id: printingOverlay
        color: Style.editorOverlayBg
        anchors.fill: parent
        opacity: isPrinting ? Style.editorPrintingOverlayOpacity : 0.0
        visible: opacity > 0
        z: 100
        Behavior on opacity {
            NumberAnimation { duration: 400 }
        }
        MouseArea {
            anchors.fill: parent
            enabled: printingOverlay.visible
        }
        BusyIndicator {
            anchors.centerIn: parent
            running: isPrinting
        }
        Text {
            text: "Drukowanie..."
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.verticalCenter
            anchors.topMargin: Style.editorOverlayTextMargin
            font.pixelSize: Style.editorOverlayTextSizeLarge
            color: Style.editorOverlayTextColor
        }
    }
    Rectangle {
        id: saveOverlay
        anchors.fill: parent
        color: Style.editorOverlayBg
        opacity: isSaving ? Style.editorSaveOverlayOpacity : 0.0
        visible: opacity > 0
        z: 110
        Behavior on opacity { NumberAnimation { duration: 300 } }
        MouseArea { anchors.fill: parent; enabled: saveOverlay.visible }
        ColumnLayout {
            anchors.centerIn: parent
            spacing: Style.filterStrengthSpacing
            Text {
                text: "Zapisywanie zmian..."
                color: Style.editorOverlayTextColor
                font.pixelSize: Style.editorOverlayTextSizeMedium
                Layout.alignment: Qt.AlignHCenter
            }
            ProgressBar {
                id: saveProgressBar
                from: 0
                to: 1.0
                value: 0
                Layout.preferredWidth: Style.filterMenuWidth
                background: Rectangle {
                    implicitHeight: Style.editorProgressBarHeight
                    color: Style.editorProgressBarBgColor
                    radius: Style.editorProgressBarRadius
                }
                contentItem: Item {
                    Rectangle {
                        width: saveProgressBar.visualPosition * parent.width
                        height: parent.height
                        radius: Style.editorProgressBarFillRadius
                        color: Style.editorProgressBarFillColor
                    }
                }
            }
        }
    }
    ConfirmDialog {
        id: copySuccessDialog
        isAlert: true
        title: "Schowek"
        message: "Zdjęcie zostało skopiowane do schowka!"
    }
    ConfirmDialog {
        id: printSuccessMessage
        isAlert: true
        title: "Status drukowania"
        message: "Zdjęcie zostało pomyślnie wysłane do drukarki!"
    }
    ConfirmDialog {
        id: deleteConfirm
        isAlert: false
        message: "Czy na pewno chcesz usunąć zdjęcie: " + imagePath.split("/").pop() + "?"
        onConfirmed: {
            let pathToRemove = imagePath
            let startPage = mainStack.get(0)
            if (startPage && typeof startPage.usunZHistorii === "function") {
                startPage.usunZHistorii(pathToRemove)
            }
            mainStack.pop()
        }
    }
    FileDialog {
        id: importFileDialog
        title: "Wybierz nowe zdjęcie"
        currentFolder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        nameFilters: ["Obrazy (*.jpg *.png *.jpeg)"]
        onAccepted: {
            importConfirm.open()
        }
    }
    ConfirmDialog {
        id: importConfirm
        message: "Czy na pewno chcesz podmienić obecne zdjęcie na: " + importFileDialog.selectedFile.toString().split("/").pop() + "?"
        onConfirmed: {
            let newPath = importFileDialog.selectedFile.toString()
            imagePath = newPath
            originalImagePath = newPath
            history = []
            historyIndex = -1
            panMode = false
            zoomSlider.value = 1.0
            let initialData = {
                "path": imagePath,
                "name": imagePath.split("/").pop(),
                "format": imagePath.split(".").pop(),
                "w": 0,
                "h": 0,
                "dpi": "300 dpi",
                "depth": "24-bit",
                "fileSize": "3.2 MB",
                "date": "2024-05-12 14:30",
                "cameraModel": "Sony Alpha a7 IV",
                "iso": "400",
                "fStop": "f/2.8",
                "shutterSpeed": "1/200s",
                "artist": "Jan Kowalski",
                "copyright": "© 2024 Kowalski Studio. All rights reserved.",
                "description": "Sesja plenerowa - Park Narodowy, zachód słońca.",
                "contrast": 0,
                "saturation": 0,
                "exposition": 0,
                "temperature": 0,
                "blur": 0,
                "flipH" : 1,
                "flipV" : 1,
                "angle" : 0,
                "crop": {
                    "x": 0,
                    "y": 0,
                    "w": 0,
                    "h": 0
                },
                "f_krawedzie": 0,
                "f_szum": 0,
                "f_rozmycie_kol": 0,
                "f_pixel_art": 0,
                "f_stary_film": 0,
                "f_negatyw": 0,
                "f_progowanie": 0,
                "f_sepia_retro": 0,
                "f_zimna_noc": 0,
                "f_cieple_lato": 0
            }
            photo.source = ""
            photo.source = imagePath
            currentMetadata = initialData
            panMode = false
            originalMetadata = initialData
            commitState()
            zoomSlider.value = 1.0
            photo.sourceClipRect = Qt.rect(
                currentMetadata.crop.x,
                currentMetadata.crop.y,
                currentMetadata.crop.w,
                currentMetadata.crop.h
            )
            zoomToFit()
            let startPage = mainStack.get(0)
            if (startPage && typeof startPage.dodajDoHistorii === "function") {
                startPage.dodajDoHistorii(newPath)
            }
            var ctx = drawingCanvas.getContext("2d");
            ctx.clearRect(0, 0, drawingCanvas.width, drawingCanvas.height);
            drawingCanvas.requestPaint();
        }
    }
    ConfirmDialog {
        id: saveSuccessMessage
        isAlert: true
        title: "Zapisano"
        message: "Zmiany zostały pomyślnie zapisane w pliku."
    }
    ConfirmDialog {
        id: resetConfirm
        title: "Potwierdź reset"
        message: "Czy na pewno chcesz cofnąć wszystkie zmiany i powrócić do oryginalnego zdjęcia?"
        onConfirmed: {
            history = []
            historyIndex = -1
            panMode = false
            zoomSlider.value = 1.0
            photo.rotation = 0
            let initialData = {
                "path": imagePath,
                "name": imagePath.split("/").pop(),
                "format": imagePath.split(".").pop(),
                "w": 0,
                "h": 0,
                "dpi": "300 dpi",
                "depth": "24-bit",
                "fileSize": "3.2 MB",
                "date": "2024-05-12 14:30",
                "cameraModel": "Sony Alpha a7 IV",
                "iso": "400",
                "fStop": "f/2.8",
                "shutterSpeed": "1/200s",
                "artist": "Jan Kowalski",
                "copyright": "© 2024 Kowalski Studio. All rights reserved.",
                "description": "Sesja plenerowa - Park Narodowy, zachód słońca.",
                "contrast": 0,
                "saturation": 0,
                "exposition": 0,
                "temperature": 0,
                "blur": 0,
                "flipH" : 1,
                "flipV" : 1,
                "angle" : 0,
                "crop": {
                    "x": 0,
                    "y": 0,
                    "w": 0,
                    "h": 0
                },
                "f_krawedzie": 0,
                "f_szum": 0,
                "f_rozmycie_kol": 0,
                "f_pixel_art": 0,
                "f_stary_film": 0,
                "f_negatyw": 0,
                "f_progowanie": 0,
                "f_sepia_retro": 0,
                "f_zimna_noc": 0,
                "f_cieple_lato": 0
            }
            photo.source = ""
            photo.source = imagePath
            currentMetadata = initialData
            panMode = false
            originalMetadata = initialData
            commitState()
            zoomSlider.value = 1.0
            photo.sourceClipRect = Qt.rect(
                currentMetadata.crop.x,
                currentMetadata.crop.y,
                currentMetadata.crop.w,
                currentMetadata.crop.h
            )
            zoomToFit()
            let startPage = mainStack.get(0)
            if (startPage && typeof startPage.dodajDoHistorii === "function") {
                startPage.dodajDoHistorii(imagePath)
            }
            var ctx = drawingCanvas.getContext("2d");
            ctx.clearRect(0, 0, drawingCanvas.width, drawingCanvas.height);
            drawingCanvas.requestPaint();
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
    function triggerEditorAction(actionName) {
        if (actionName === "Obróć w prawo") {
            if (currentMetadata.angle > 90) return;
            currentMetadata.angle = currentMetadata.angle + 90
            photo.rotation = currentMetadata.angle
            let temp = currentMetadata.w
            currentMetadata.w = currentMetadata.h
            currentMetadata.h = temp
            commitState()
        } else if (actionName === "Obróć w lewo") {
            if (currentMetadata.angle < -90) return;
            currentMetadata.angle = currentMetadata.angle - 90
            photo.rotation = currentMetadata.angle
            let temp = currentMetadata.w
            currentMetadata.w = currentMetadata.h
            currentMetadata.h = temp
            commitState()
        } else if (actionName === "Odbij w bok") {
            let data = JSON.parse(JSON.stringify(currentMetadata));
            data.flipH = (currentMetadata.flipH === 1 ? -1 : 1)
            currentMetadata = data;
            commitState()
        } else if (actionName === "Odbij wertykalnie") {
            let data = JSON.parse(JSON.stringify(currentMetadata));
            data.flipV = (currentMetadata.flipV === 1 ? -1 : 1)
            currentMetadata = data;
            commitState()
        } else if (actionName === "Krawędzie") {
            let snapshot = drawingCanvas.toDataURL("image/png");
            let filterPage = mainStack.push("FilterScreen.qml", { "imageInfo": currentMetadata,
                                                "initialCanvasData": snapshot })
            filterPage.selectedFilterName = "Krawędzie"
            filterPage.filterStrength = currentMetadata["f_krawedzie"]
            filterPage.activeProperty = "f_krawedzie"
            filterPage.filteringFinished.connect(function(info) {
                currentMetadata = info.metadata
                var ctx = drawingCanvas.getContext("2d");
                drawingCanvas.loadImage(info.image);
                drawingCanvas.imageLoaded.connect(function() {
                    ctx.clearRect(0, 0, drawingCanvas.width, drawingCanvas.height);
                    ctx.imageSmoothingEnabled = false;
                    ctx.drawImage(info.image, 0, 0, drawingCanvas.width, drawingCanvas.height);
                    drawingCanvas.requestPaint();
                });
                commitState()
            })
        } else if (actionName === "Szum") {
            let snapshot = drawingCanvas.toDataURL("image/png");
            let filterPage = mainStack.push("FilterScreen.qml", { "imageInfo": currentMetadata,
                                                "initialCanvasData": snapshot  })
            filterPage.selectedFilterName = "Szum"
            filterPage.filterStrength = currentMetadata["f_szum"]
            filterPage.activeProperty = "f_szum"
            filterPage.filteringFinished.connect(function(info) {
                currentMetadata = info.metadata
                var ctx = drawingCanvas.getContext("2d");
                drawingCanvas.loadImage(info.image);
                drawingCanvas.imageLoaded.connect(function() {
                    ctx.clearRect(0, 0, drawingCanvas.width, drawingCanvas.height);
                    ctx.imageSmoothingEnabled = false;
                    ctx.drawImage(info.image, 0, 0, drawingCanvas.width, drawingCanvas.height);
                    drawingCanvas.requestPaint();
                });
                commitState()
            })
        } else if (actionName === "Rozmycie kół") {
            let snapshot = drawingCanvas.toDataURL("image/png");
            let filterPage = mainStack.push("FilterScreen.qml", { "imageInfo": currentMetadata,
                                                "initialCanvasData": snapshot  })
            filterPage.selectedFilterName = "Rozmycie kół"
            filterPage.filterStrength = currentMetadata["f_rozmycie_kol"]
            filterPage.activeProperty = "f_rozmycie_kol"
            filterPage.filteringFinished.connect(function(info) {
                currentMetadata = info.metadata
                var ctx = drawingCanvas.getContext("2d");
                drawingCanvas.loadImage(info.image);
                drawingCanvas.imageLoaded.connect(function() {
                    ctx.clearRect(0, 0, drawingCanvas.width, drawingCanvas.height);
                    ctx.imageSmoothingEnabled = false;
                    ctx.drawImage(info.image, 0, 0, drawingCanvas.width, drawingCanvas.height);
                    drawingCanvas.requestPaint();
                });
                commitState()
            })
        } else if (actionName === "Pixel Art") {
            let snapshot = drawingCanvas.toDataURL("image/png");
            let filterPage = mainStack.push("FilterScreen.qml", { "imageInfo": currentMetadata,
                                                "initialCanvasData": snapshot  })
            filterPage.selectedFilterName = "Pixel Art"
            filterPage.filterStrength = currentMetadata["f_pixel_art"]
            filterPage.activeProperty = "f_pixel_art"
            filterPage.filteringFinished.connect(function(info) {
                currentMetadata = info.metadata
                var ctx = drawingCanvas.getContext("2d");
                drawingCanvas.loadImage(info.image);
                drawingCanvas.imageLoaded.connect(function() {
                    ctx.clearRect(0, 0, drawingCanvas.width, drawingCanvas.height);
                    ctx.imageSmoothingEnabled = false;
                    ctx.drawImage(info.image, 0, 0, drawingCanvas.width, drawingCanvas.height);
                    drawingCanvas.requestPaint();
                });
                commitState()
            })
        } else if (actionName === "Stary Film") {
            let snapshot = drawingCanvas.toDataURL("image/png");
            let filterPage = mainStack.push("FilterScreen.qml", { "imageInfo": currentMetadata,
                                                "initialCanvasData": snapshot })
            filterPage.selectedFilterName = "Stary Film"
            filterPage.filterStrength = currentMetadata["f_stary_film"]
            filterPage.activeProperty = "f_stary_film"
            filterPage.filteringFinished.connect(function(info) {
                currentMetadata = info.metadata
                var ctx = drawingCanvas.getContext("2d");
                drawingCanvas.loadImage(info.image);
                drawingCanvas.imageLoaded.connect(function() {
                    ctx.clearRect(0, 0, drawingCanvas.width, drawingCanvas.height);
                    ctx.imageSmoothingEnabled = false;
                    ctx.drawImage(info.image, 0, 0, drawingCanvas.width, drawingCanvas.height);
                    drawingCanvas.requestPaint();
                });
                commitState()
            })
        } else if (actionName === "Negatyw") {
            let snapshot = drawingCanvas.toDataURL("image/png");
            let filterPage = mainStack.push("FilterScreen.qml", { "imageInfo": currentMetadata,
                                                "initialCanvasData": snapshot })
            filterPage.selectedFilterName = "Negatyw"
            filterPage.filterStrength = currentMetadata["f_negatyw"]
            filterPage.activeProperty = "f_negatyw"
            filterPage.filteringFinished.connect(function(info) {
                currentMetadata = info.metadata
                var ctx = drawingCanvas.getContext("2d");
                drawingCanvas.loadImage(info.image);
                drawingCanvas.imageLoaded.connect(function() {
                    ctx.clearRect(0, 0, drawingCanvas.width, drawingCanvas.height);
                    ctx.imageSmoothingEnabled = false;
                    ctx.drawImage(info.image, 0, 0, drawingCanvas.width, drawingCanvas.height);
                    drawingCanvas.requestPaint();
                });
                commitState()
            })
        } else if (actionName === "Progowanie") {
            let snapshot = drawingCanvas.toDataURL("image/png");
            let filterPage = mainStack.push("FilterScreen.qml", { "imageInfo": currentMetadata,
                                                "initialCanvasData": snapshot  })
            filterPage.selectedFilterName = "Progowanie"
            filterPage.filterStrength = currentMetadata["f_progowanie"]
            filterPage.activeProperty = "f_progowanie"
            filterPage.filteringFinished.connect(function(info) {
                currentMetadata = info.metadata
                var ctx = drawingCanvas.getContext("2d");
                drawingCanvas.loadImage(info.image);
                drawingCanvas.imageLoaded.connect(function() {
                    ctx.clearRect(0, 0, drawingCanvas.width, drawingCanvas.height);
                    ctx.imageSmoothingEnabled = false;
                    ctx.drawImage(info.image, 0, 0, drawingCanvas.width, drawingCanvas.height);
                    drawingCanvas.requestPaint();
                });
                commitState()
            })
        } else if (actionName === "Sepia Retro") {
            let snapshot = drawingCanvas.toDataURL("image/png");
            let filterPage = mainStack.push("FilterScreen.qml", { "imageInfo": currentMetadata,
                                                "initialCanvasData": snapshot  })
            filterPage.selectedFilterName = "Sepia Retro"
            filterPage.filterStrength = currentMetadata["f_sepia_retro"]
            filterPage.activeProperty = "f_sepia_retro"
            filterPage.filteringFinished.connect(function(info) {
                currentMetadata = info.metadata
                var ctx = drawingCanvas.getContext("2d");
                drawingCanvas.loadImage(info.image);
                drawingCanvas.imageLoaded.connect(function() {
                    ctx.clearRect(0, 0, drawingCanvas.width, drawingCanvas.height);
                    ctx.imageSmoothingEnabled = false;
                    ctx.drawImage(info.image, 0, 0, drawingCanvas.width, drawingCanvas.height);
                    drawingCanvas.requestPaint();
                });
                commitState()
            })
        } else if (actionName === "Zimna Noc") {
            let snapshot = drawingCanvas.toDataURL("image/png");
            let filterPage = mainStack.push("FilterScreen.qml", { "imageInfo": currentMetadata,
                                                "initialCanvasData": snapshot  })
            filterPage.selectedFilterName = "Zimna Noc"
            filterPage.filterStrength = currentMetadata["f_zimna_noc"]
            filterPage.activeProperty = "f_zimna_noc"
            filterPage.filteringFinished.connect(function(info) {
                currentMetadata = info.metadata
                var ctx = drawingCanvas.getContext("2d");
                drawingCanvas.loadImage(info.image);
                drawingCanvas.imageLoaded.connect(function() {
                    ctx.clearRect(0, 0, drawingCanvas.width, drawingCanvas.height);
                    ctx.imageSmoothingEnabled = false;
                    ctx.drawImage(info.image, 0, 0, drawingCanvas.width, drawingCanvas.height);
                    drawingCanvas.requestPaint();
                });
                commitState()
            })
        } else if (actionName === "Ciepłe Lato") {
            let snapshot = drawingCanvas.toDataURL("image/png");
            let filterPage = mainStack.push("FilterScreen.qml", { "imageInfo": currentMetadata,
                                                "initialCanvasData": snapshot  })
            filterPage.selectedFilterName = "Ciepłe Lato"
            filterPage.filterStrength = currentMetadata["f_cieple_lato"]
            filterPage.activeProperty = "f_cieple_lato"
            filterPage.filteringFinished.connect(function(info) {
                currentMetadata = info.metadata
                var ctx = drawingCanvas.getContext("2d");
                drawingCanvas.loadImage(info.image);
                drawingCanvas.imageLoaded.connect(function() {
                    ctx.clearRect(0, 0, drawingCanvas.width, drawingCanvas.height);
                    ctx.imageSmoothingEnabled = false;
                    ctx.drawImage(info.image, 0, 0, drawingCanvas.width, drawingCanvas.height);
                    drawingCanvas.requestPaint();
                });
                commitState()
            })
        } else if (actionName === "Ołówek") {
            let snapshot = drawingCanvas.toDataURL("image/png");
            let drawPage = mainStack.push("DrawingScreen.qml", { "imageInfo": currentMetadata,
                                              "initialCanvasData": snapshot })
            drawPage.selectedTool = "Pencil"
            drawPage.drawingFinished.connect(function(info) {
                currentMetadata = info.metadata
                var ctx = drawingCanvas.getContext("2d");
                drawingCanvas.loadImage(info.image);
                drawingCanvas.imageLoaded.connect(function() {
                    ctx.clearRect(0, 0, drawingCanvas.width, drawingCanvas.height);
                    ctx.imageSmoothingEnabled = false;
                    ctx.drawImage(info.image, 0, 0, drawingCanvas.width, drawingCanvas.height);
                    drawingCanvas.requestPaint();
                });
                commitState()
            })
        } else if (actionName === "Pióro") {
            let snapshot = drawingCanvas.toDataURL("image/png");
            let drawPage = mainStack.push("DrawingScreen.qml", { "imageInfo": currentMetadata,
                                              "initialCanvasData": snapshot  })
            drawPage.selectedTool = "Pen"
            drawPage.drawingFinished.connect(function(info) {
                currentMetadata = info.metadata
                var ctx = drawingCanvas.getContext("2d");
                drawingCanvas.loadImage(info.image);
                drawingCanvas.imageLoaded.connect(function() {
                    ctx.clearRect(0, 0, drawingCanvas.width, drawingCanvas.height);
                    ctx.imageSmoothingEnabled = false;
                    ctx.drawImage(info.image, 0, 0, drawingCanvas.width, drawingCanvas.height);
                    drawingCanvas.requestPaint();
                });
                commitState()
            })
        } else if (actionName === "Gumka") {
            let snapshot = drawingCanvas.toDataURL("image/png");
            let drawPage = mainStack.push("DrawingScreen.qml", { "imageInfo": currentMetadata,
                                              "initialCanvasData": snapshot })
            drawPage.selectedTool = "Eraser"
            drawPage.drawingFinished.connect(function(info) {
                currentMetadata = info.metadata
                var ctx = drawingCanvas.getContext("2d");
                drawingCanvas.loadImage(info.image);
                drawingCanvas.imageLoaded.connect(function() {
                    ctx.clearRect(0, 0, drawingCanvas.width, drawingCanvas.height);
                    ctx.imageSmoothingEnabled = false;
                    ctx.drawImage(info.image, 0, 0, drawingCanvas.width, drawingCanvas.height);
                    drawingCanvas.requestPaint();
                });
                commitState()
            })
        } else if (actionName === "Próbnik") {
            let snapshot = drawingCanvas.toDataURL("image/png");
            let drawPage = mainStack.push("DrawingScreen.qml", { "imageInfo": currentMetadata,
                                              "initialCanvasData": snapshot  })
            drawPage.selectedTool = "Picker"
            drawPage.drawingFinished.connect(function(info) {
                currentMetadata = info.metadata
                var ctx = drawingCanvas.getContext("2d");
                drawingCanvas.loadImage(info.image);
                drawingCanvas.imageLoaded.connect(function() {
                    ctx.clearRect(0, 0, drawingCanvas.width, drawingCanvas.height);
                    ctx.imageSmoothingEnabled = false;
                    ctx.drawImage(info.image, 0, 0, drawingCanvas.width, drawingCanvas.height);
                    drawingCanvas.requestPaint();
                });
                commitState()
            })
        } else if (actionName === "Tekst") {
            let snapshot = drawingCanvas.toDataURL("image/png");
            let drawPage = mainStack.push("DrawingScreen.qml", { "imageInfo": currentMetadata,
                                              "initialCanvasData": snapshot })
            drawPage.selectedTool = "Text"
            drawPage.drawingFinished.connect(function(info) {
                currentMetadata = info.metadata
                var ctx = drawingCanvas.getContext("2d");
                drawingCanvas.loadImage(info.image);
                drawingCanvas.imageLoaded.connect(function() {
                    ctx.clearRect(0, 0, drawingCanvas.width, drawingCanvas.height);
                    ctx.imageSmoothingEnabled = false;
                    ctx.drawImage(info.image, 0, 0, drawingCanvas.width, drawingCanvas.height);
                    drawingCanvas.requestPaint();
                });
                commitState()
            })
        } else if (actionName === "Kolor") {
            let snapshot = drawingCanvas.toDataURL("image/png");
            let drawPage = mainStack.push("DrawingScreen.qml", { "imageInfo": currentMetadata,
                                              "initialCanvasData": snapshot })
            drawPage.selectedTool = "Color"
            drawPage.drawingFinished.connect(function(info) {
                currentMetadata = info.metadata
                var ctx = drawingCanvas.getContext("2d");
                drawingCanvas.loadImage(info.image);
                drawingCanvas.imageLoaded.connect(function() {
                    ctx.clearRect(0, 0, drawingCanvas.width, drawingCanvas.height);
                    ctx.imageSmoothingEnabled = false;
                    ctx.drawImage(info.image, 0, 0, drawingCanvas.width, drawingCanvas.height);
                    drawingCanvas.requestPaint();
                });
                commitState()
            })
        }
        editorScreen.forceActiveFocus()
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
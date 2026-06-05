import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import "../Kontrolki"
import "../Style"
Rectangle {
    id: filterScreen
    color: Style.dialogBackground
    property var imageInfo: ({})
    property var currentMetadata: ({})
    property var originalMetadata: currentMetadata
    property bool panMode: false
    property var history: []
    property int historyIndex: -1
    property bool isShowingOriginal: false
    property bool blockHistory: false
    property string selectedFilterName: ""
    property real filterStrength: 30.0
    property string activeProperty: ""
    signal filteringFinished(var finalInfo)
    property real fitScale: 1.0
    property string initialCanvasData: ""
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
    Keys.forwardTo: [filterKeyHandler]
    Item {
        id: filterKeyHandler
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
                Layout.maximumWidth: Style.manipulationSidePanelWidth
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
                        anchors.top: parent.top
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
                            width: parent.width
                            spacing: 0
                            Repeater {
                                model: ["Filtry \nWyostrzania", "Filtry \nRozmycia", "Filtry \nKreatywne", "Filtry \nKorekcyjne", "Filtry \nKoloru"]
                                FIlterButton {
                                    categoryTitle: modelData
                                    onFilterActivated: (filter) => {
                                       selectedFilterName = filter;
                                       let mapping = {
                                           "Krawędzie": "f_krawedzie", "Szum": "f_szum",
                                           "Rozmycie kół": "f_rozmycie_kol", "Pixel Art": "f_pixel_art",
                                           "Stary Film": "f_stary_film", "Negatyw": "f_negatyw",
                                           "Progowanie": "f_progowanie", "Sepia Retro": "f_sepia_retro",
                                           "Zimna Noc": "f_zimna_noc", "Ciepłe Lato": "f_cieple_lato"
                                       };
                                       activeProperty = mapping[filter];
                                    }
                                }
                            }
                        }
                        ColumnLayout {
                            spacing: Style.filterStrengthSpacing
                            Layout.fillWidth: true
                            visible: filterScreen.selectedFilterName !== ""
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Style.filterStrengthSeparatorHeight
                                color: Style.baseTextColor
                                opacity: Style.filterStrengthSeparatorOpacity
                            }
                            Text {
                                text: filterScreen.selectedFilterName
                                font.pixelSize: Style.filterStrengthTextSize
                                font.weight: Style.fontWeight
                                color: Style.baseTextColor
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                Layout.preferredHeight: Style.filterStrengthTextHeight
                            }
                            Slider {
                                id: filterStrengthSlider
                                from: 0
                                to: 100
                                value: (activeProperty !== "" && currentMetadata[activeProperty] !== undefined)
                                           ? currentMetadata[activeProperty] : 0
                                stepSize: 1
                                Layout.preferredHeight: Style.filterStrengthSliderHeight
                                Layout.alignment: Qt.AlignCenter
                                background: Rectangle {
                                    x: filterStrengthSlider.leftPadding
                                    y: filterStrengthSlider.topPadding + filterStrengthSlider.availableHeight / 2 - height / 2
                                    implicitWidth: Style.filterStrengthSliderBgWidth
                                    implicitHeight: Style.sliderBgImplicitHeight
                                    width: filterStrengthSlider.availableWidth
                                    height: implicitHeight
                                    radius: Style.sliderBgRadius
                                    color: Style.sliderBgColor
                                }
                                handle: Rectangle {
                                    x: filterStrengthSlider.leftPadding + filterStrengthSlider.visualPosition * (filterStrengthSlider.availableWidth - width)
                                    y: filterStrengthSlider.topPadding + filterStrengthSlider.availableHeight / 2 - height / 2
                                    implicitWidth: Style.sliderHandleImplicitWidth
                                    implicitHeight: Style.sliderHandleImplicitHeight
                                    radius: Style.sliderHandleRadius
                                    color: Style.sliderHandleColor
                                    border.color: Style.sliderHandleBorderColor
                                    border.width: Style.sliderHandleBorderWidth
                                }
                                onMoved: {
                                    if (activeProperty !== "") {
                                        currentMetadata[activeProperty] = value
                                        let data = JSON.parse(JSON.stringify(currentMetadata));
                                        data.activeProperty = value;
                                        currentMetadata = data;
                                    }
                                }
                                onPressedChanged: {
                                    if (!pressed) {
                                        let data = JSON.parse(JSON.stringify(currentMetadata));
                                        data.activeProperty = value;
                                        currentMetadata = data;
                                        saveState()
                                    }
                                }
                            }
                            Text {
                                text: filterStrengthSlider.value.toFixed(0)
                                font.pixelSize: Style.sliderValueFontSize
                                font.weight: Style.sliderValueFontWeight
                                color: Style.sliderValueColor
                                Layout.alignment: Qt.AlignCenter
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
                                    "image": filterScreen.initialCanvasData,
                                    "metadata": clone(currentMetadata)
                                };
                                filteringFinished(finalData);
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
                    Image {
                        id: photo
                        source: imageInfo.path
                        scale: fitScale * zoomSlider.value
                        transformOrigin: Item.Center
                        fillMode: Image.PreserveAspectFit
                        rotation: isShowingOriginal ? originalMetadata.angle : currentMetadata.angle
                        transform: Scale {
                            origin.x: photo.width / 2
                            origin.y: photo.height / 2
                            xScale: isShowingOriginal ? originalMetadata.flipH : currentMetadata.flipH
                            yScale: isShowingOriginal ? originalMetadata.flipV : currentMetadata.flipV
                        }
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: imageContainer.dragOffsetX
                        anchors.verticalCenterOffset: imageContainer.dragOffsetY
                        Image {
                            id: overlayDrawing
                            z: 100
                            anchors.fill: photo
                            source: (initialCanvasData && initialCanvasData !== "data:,") ? initialCanvasData : ""
                            fillMode: Image.PreserveAspectFit
                            visible: filterScreen.initialCanvasData !== ""
                            smooth: false
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
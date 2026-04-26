import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../Kontrolki"
import QtQuick.Dialogs
import QtCore
import QtQuick.Effects

Rectangle {
    id: editorScreen
    color: "#8E9191"
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
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        Rectangle {
            id: topBar
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "#8E9191"
            Text {
                text: currentMetadata.name || ""
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
                    onClicked: deleteConfirm.open()
                }
                CustomButton {
                    id: printBtn
                    Layout.preferredWidth: 50; Layout.preferredHeight: 50
                    icon.source: "../Resources/printer.svg"
                    iconSize: 35
                    tooltipText: "Drukuj"
                    enabled: !isPrinting
                    opacity: isPrinting ? (printingAnim.running ? 1.0 : 0.6) : 1.0
                    SequentialAnimation on opacity {
                        id: printingAnim
                        running: editorScreen.isPrinting
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 0.3; duration: 600 }
                        NumberAnimation { from: 0.3; to: 1.0; duration: 600 }
                    }

                    onClicked: {
                        isPrinting = true
                        printTimer.start()
                    }
                }
                CustomButton {
                    id: copyBtn
                    Layout.preferredWidth: 50; Layout.preferredHeight: 50
                    icon.source: "../Resources/copy.svg"
                    iconSize: 35
                    tooltipText: "Kopiuj"
                    onClicked: {
                        copySuccessDialog.open()
                    }
                }
                CustomButton {
                    id: importBtn
                    Layout.preferredWidth: 50; Layout.preferredHeight: 50
                    icon.source: "../Resources/download.svg"
                    iconSize: 35
                    tooltipText: "Importuj"
                    onClicked: importFileDialog.open()
                }
                CustomButton {
                    id: saveBtn
                    Layout.preferredWidth: 50; Layout.preferredHeight: 50
                    icon.source: "../Resources/floppy-disk.svg"
                    iconSize: 35
                    tooltipText: "Zapisz"
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
                        onClicked: resetConfirm.open()
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
                            Layout.preferredWidth: 50; Layout.preferredHeight: 50
                            icon.source: "../Resources/transition-right.svg"
                            iconSize: 35
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
                    Repeater {
                        model: 12
                        CornerButton {
                            settingsCategory: "slot" + (index + 1)
                            onFunctionActivated: (name) => triggerEditorAction(name)
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
                Item {
                    id: imageContainer
                    anchors.fill: parent
                    clip: true
                    Image {
                        id: photo
                        source: isShowingOriginal ? originalImagePath : imagePath
                        x: (parent.width - width) / 2
                        y: (parent.height - height) / 2
                        scale: zoomSlider.value
                        transformOrigin: Item.Center
                        width: Math.min(imageContainer.width, imageContainer.height * (sourceSize.width / sourceSize.height))
                        height: Math.min(imageContainer.height, imageContainer.width * (sourceSize.height / sourceSize.width))
                        anchors.centerIn: parent
                        fillMode: Image.Stretch
                        asynchronous: false
                        cache: false
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
                        let manipPage = mainStack.push("ManipulationScreen.qml", { "imageInfo": currentMetadata })
                        manipPage.manipulationFinished.connect(function(info) {
                            photo.autoTransform = true
                            currentMetadata = info
                            photo.rotation = currentMetadata.angle
                            photo.sourceClipRect = Qt.rect(
                                currentMetadata.crop.x,
                                currentMetadata.crop.y,
                                currentMetadata.crop.w,
                                currentMetadata.crop.h
                            )
                            commitState()
                        })
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
                    onClicked: {
                        let correctPage = mainStack.push("CorrectionScreen.qml", { "imageInfo": currentMetadata })
                        correctPage.correctionFinished.connect(function(info) {
                            currentMetadata = info
                            commitState()
                        })
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
                    onClicked: {
                        let filterPage = mainStack.push("FilterScreen.qml", { "imageInfo": currentMetadata })
                        filterPage.filteringFinished.connect(function(info) {
                            currentMetadata = info
                            commitState()
                        })
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
                        let pg = mainStack.push("MetadataScreen.qml", { "imageInfo": currentMetadata })
                        pg.metadataUpdated.connect(function(updatedData) {
                            if (JSON.stringify(currentMetadata) !== JSON.stringify(updatedData)) {
                                currentMetadata = updatedData
                                commitState()
                            }
                        })
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
                        text: currentMetadata.w + " x " + currentMetadata.h
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
    Rectangle {
        id: printingOverlay
        color: "#000000"
        anchors.fill: parent
        opacity: isPrinting ? 0.6 : 0.0
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
            anchors.topMargin: 40
            font.pixelSize: 24
            color: "white"
        }
    }
    Rectangle {
        id: saveOverlay
        anchors.fill: parent
        color: "#000000"
        opacity: isSaving ? 0.7 : 0.0
        visible: opacity > 0
        z: 110
        Behavior on opacity { NumberAnimation { duration: 300 } }
        MouseArea { anchors.fill: parent; enabled: saveOverlay.visible }
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20
            Text {
                text: "Zapisywanie zmian..."
                color: "white"
                font.pixelSize: 22
                Layout.alignment: Qt.AlignHCenter
            }
            ProgressBar {
                id: saveProgressBar
                from: 0
                to: 1.0
                value: 0
                Layout.preferredWidth: 300
                background: Rectangle {
                    implicitHeight: 6
                    color: "#444"
                    radius: 3
                }
                contentItem: Item {
                    Rectangle {
                        width: saveProgressBar.visualPosition * parent.width
                        height: parent.height
                        radius: 2
                        color: "#AC4141"
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
        }
    }
    function zoomToFit() {
        if (photo.status !== Image.Ready) return
        let imgW = photo.sourceSize.width
        let imgH = photo.sourceSize.height
        let containerW = imageContainer.width
        let containerH = imageContainer.height
        let finalScale = 1.0
        if (photo.width > 0 && photo.height > 0) {
            let currentRatioX = containerW / photo.width
            let currentRatioY = containerH / photo.height
            finalScale = Math.min(currentRatioX, currentRatioY)
        }
        zoomSlider.value = finalScale
        photo.x = (imageContainer.width - photo.width) / 2
        photo.y = (imageContainer.height - photo.height) / 2
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
        }

    }
}
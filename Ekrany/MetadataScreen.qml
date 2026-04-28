import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../Kontrolki"

Rectangle {
    id: metadataScreen
    color: "#8E9191"
    property var imageInfo: ({})
    property var workingInfo: ({})
    property var history: []
    property int historyIndex: -1
    property var originalInfo: ({})
    property bool isRestoring: false
    signal metadataUpdated(var updatedData)
    function saveStep() {
        if (isRestoring) return;
        let currentState = JSON.parse(JSON.stringify(workingInfo));
        if (history.length > 0) {
            let last = history[historyIndex];
            if (JSON.stringify(last) === JSON.stringify(currentState)) return;
        }
        if (historyIndex < history.length - 1) history = history.slice(0, historyIndex + 1);
        history.push(currentState);
        historyIndex = history.length - 1;
    }
    Item {
        id: focusThief
        focus: true
    }
    TapHandler {
        onTapped: {
            focusThief.forceActiveFocus()
        }
    }
    Keys.onReturnPressed: focusThief.forceActiveFocus()
    Keys.onEnterPressed: focusThief.forceActiveFocus()
    Keys.onPressed: (event) => {
        if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_Z) {
            if (undoBtn.enabled) undoBtn.clicked();
            event.accepted = true;
        }
        if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_Y) {
            if (redoBtn.enabled) redoBtn.clicked();
            event.accepted = true;
        }
    }
    focus: true
    function hasChanges() {
        return JSON.stringify(workingInfo) !== JSON.stringify(originalInfo);
    }
    Component.onCompleted: {
        workingInfo = JSON.parse(JSON.stringify(imageInfo));
        workingInfo.name = stripExtension(workingInfo.name);
        originalInfo = JSON.parse(JSON.stringify(imageInfo));
        originalInfo.name = stripExtension(workingInfo.name);
        if (!workingInfo.description) workingInfo.description = "";
        history = [];
        historyIndex = -1;
        saveStep();
    }
    function stripExtension(fileName) {
        if (!fileName) return "";
        return fileName.indexOf('.') !== -1 ? fileName.substring(0, fileName.lastIndexOf('.')) : fileName;
    }
    function applyState(state) {
        if (!state) return;
        isRestoring = true;
        workingInfo = JSON.parse(JSON.stringify(state));
        nameRow.value = stripExtension(workingInfo.name || "");
        dateRow.value = workingInfo.date || "";
        artistRow.value = workingInfo.artist || "";
        copyrightRow.value = workingInfo.copyright || "";
        descriptionArea.text = workingInfo.description || "";
        isRestoring = false;
    }
    onVisibleChanged: {
        if (visible && imageInfo) {
            workingInfo = JSON.parse(JSON.stringify(imageInfo));
            originalInfo = JSON.parse(JSON.stringify(imageInfo));
            applyState(workingInfo);
            history = [];
            historyIndex = -1;
            saveStep();
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
                        onClicked: {
                            if (hasChanges()) {
                                confirmExitDialog.open();
                            } else {
                                mainStack.pop();
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        CustomButton {
                            id: undoBtn
                            Layout.fillWidth: true
                            enabled: historyIndex > 0
                            opacity: enabled ? 1.0 : 0.4
                            Layout.preferredWidth: 50; Layout.preferredHeight: 50
                            icon.source: "../Resources/undo.svg"
                            iconSize: 35
                            tooltipText: "Cofnij"
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
                                    opacity: redoBtn.enabled ? 1.0 : 0.25
                                    mirror: true
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                }
                            }
                            onClicked: {
                                historyIndex++;
                                applyState(history[historyIndex]);
                            }
                            tooltipText: "Ponów"
                        }
                        CustomButton {
                            id: actionBtn
                            property bool showingOriginal: false
                            Layout.fillWidth: true
                            enabled: historyIndex > 0
                            Layout.preferredWidth: 50; Layout.preferredHeight: 50
                            icon.source: "../Resources/transition-right.svg"
                            iconSize: 35
                            tooltipText: "Przytrzymaj kursor, aby podejrzeć oryginał"
                            hoverEnabled: true
                            onEntered: applyState(originalInfo)
                            onExited: applyState(history[historyIndex])
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
                Layout.alignment: Qt.AlignHCenter
                Item {
                    id: metadataField
                    anchors.fill: parent
                    anchors.margins: 20
                    Layout.alignment: Qt.AlignHCenter
                    Rectangle {
                        anchors.fill: parent
                        color: "#8E9191"
                        Layout.alignment: Qt.AlignHCenter
                        ScrollView {
                            anchors.fill: parent
                            anchors.margins: 20
                            contentWidth: availableWidth
                            clip: true
                            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                            Layout.alignment: Qt.AlignHCenter
                            ColumnLayout {
                                width: parent.width
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 5
                                MetadataEditRow {
                                    id: nameRow
                                    label: "Nazwa pliku:"
                                    value: stripExtension(workingInfo.name || "")
                                    onEdited: (newValue) => {
                                        workingInfo.name = newValue;
                                        saveStep();
                                    }
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 1000
                                    trailingIcon: "../Resources/edit-pencil.svg"
                                    isReadOnly: false
                                }
                                MetadataEditRow {
                                    id: dateRow
                                    label: "Data wykonania:"
                                    value: workingInfo.date || ""
                                    onEdited: (newValue) => {
                                        workingInfo.date = newValue;
                                        saveStep();
                                    }
                                    inputMask: "0000-00-00 00:00;_"
                                    validator: RegularExpressionValidator {
                                        regularExpression: /^((19|20)\d\d)-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])\s([01][0-9]|2[0-3]):([0-5][0-9])$/
                                    }
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 1000
                                    trailingIcon: "../Resources/edit-pencil.svg"
                                    isReadOnly: false
                                }
                                MetadataEditRow {
                                    label: "Ścieżka:"
                                    value: imageInfo.path || ""
                                    isReadOnly: true
                                    opacity: 0.8
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 1000
                                }
                                Rectangle {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 1000
                                    height: 1
                                    color: "#777"
                                }
                                MetadataEditRow {
                                    label: "Rozdzielczość:"
                                    value: (imageInfo.w || 0) + " x " + (imageInfo.h || 0)
                                    isReadOnly: true
                                    opacity: 0.8
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 1000
                                }
                                MetadataEditRow {
                                    label: "Format pliku:"
                                    value: imageInfo.format || ""
                                    isReadOnly: true; opacity: 0.8
                                    Layout.alignment: Qt.AlignHCenter;
                                    Layout.preferredWidth: 1000
                                }
                                MetadataEditRow {
                                    label: "Dpi:"
                                    value: imageInfo.dpi || ""
                                    isReadOnly: true; opacity: 0.8
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 1000
                                }
                                MetadataEditRow {
                                    label: "Głębia koloru:"
                                    value: imageInfo.depth || ""
                                    isReadOnly: true; opacity: 0.8
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 1000
                                }
                                MetadataEditRow {
                                    label: "Rozmiar pliku:"
                                    value: imageInfo.fileSize || ""
                                    isReadOnly: true; opacity: 0.8
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 1000
                                }
                                Rectangle {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 1000
                                    height: 1
                                    color: "#777"
                                }
                                RowLayout {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 1000
                                    spacing: 0
                                    MetadataEditRow {
                                        label: "Model aparatu:"
                                        value: imageInfo.cameraModel || ""
                                        isReadOnly: true; opacity: 0.8
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: 450
                                    }
                                    MetadataEditRow {
                                        label: "ISO:"
                                        value: imageInfo.iso || ""
                                        isReadOnly: true; opacity: 0.8
                                        Layout.preferredWidth: 300
                                        Layout.alignment: Qt.AlignLeft
                                    }
                                    Item { Layout.fillWidth: true }
                                }
                                RowLayout {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 1000
                                    spacing: 0
                                    MetadataEditRow {
                                        label: "Przysłona:"
                                        value: imageInfo.fStop || ""
                                        isReadOnly: true; opacity: 0.8
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: 450
                                    }
                                    MetadataEditRow {
                                        label: "Czas naświetlania:"
                                        value: imageInfo.shutterSpeed || ""
                                        isReadOnly: true; opacity: 0.8
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: 300
                                        Layout.alignment: Qt.AlignLeft
                                    }
                                    Item { Layout.fillWidth: true }
                                }
                                Rectangle {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 1000
                                    height: 1
                                    color: "#777"
                                }
                                MetadataEditRow {
                                    id: artistRow
                                    label: "Autor/Twórca:"
                                    value: workingInfo.artist || ""
                                    onEdited: (newValue) => {
                                        workingInfo.artist = newValue;
                                        saveStep();
                                    }
                                    Layout.alignment: Qt.AlignHCenter; Layout.preferredWidth: 1000
                                    trailingIcon: "../Resources/edit-pencil.svg"
                                    isReadOnly: false
                                }
                                MetadataEditRow {
                                    id: copyrightRow
                                    label: "Prawa autorskie:"
                                    value: workingInfo.copyright || ""
                                    onEdited: (newValue) => {
                                        workingInfo.copyright = newValue;
                                        saveStep();
                                    }
                                    Layout.alignment: Qt.AlignHCenter; Layout.preferredWidth: 1000
                                    trailingIcon: "../Resources/edit-pencil.svg"
                                    isReadOnly: false
                                }
                                Rectangle {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 1000
                                    height: 1
                                    color: "#777"
                                }
                                RowLayout {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 1000
                                    spacing: 10
                                    Text {
                                        text: "Opis zdjęcia:";
                                        font.pixelSize: 16;
                                        Layout.preferredWidth: 150
                                        Layout.minimumWidth: 150
                                        Layout.maximumWidth: 150
                                        font.bold: true;
                                        color: "#222"
                                        Layout.alignment: Qt.AlignTop
                                        horizontalAlignment: Text.AlignRight
                                        Layout.topMargin: 8
                                    }
                                    TextArea {
                                        id: descriptionArea
                                        onEditingFinished: saveStep()
                                        text: workingInfo.description || ""
                                        color: "#222"
                                        Layout.preferredHeight: 120
                                        onTextChanged: {
                                            if (!isRestoring && workingInfo.description !== text) {
                                                workingInfo.description = text;
                                            }
                                        }
                                        Layout.fillWidth: true
                                        Layout.rightMargin: 50
                                        placeholderText: "Kliknij, aby dodać opis..."
                                        placeholderTextColor: "#222"
                                        font.pixelSize: 16
                                        topPadding: 8
                                        leftPadding: 10
                                        rightPadding: 10
                                        wrapMode: TextEdit.Wrap
                                        background: Rectangle {
                                            color: descriptionArea.activeFocus ? "white" : "transparent"
                                            border.color: descriptionArea.activeFocus ? "#3498db" : "transparent"
                                            radius: 4
                                            Image {
                                                source: "../Resources/edit-pencil.svg"
                                                width: 18
                                                height: 18
                                                anchors.right: parent.right
                                                anchors.rightMargin: 10
                                                opacity: 0.4
                                                visible: !descriptionArea.activeFocus
                                                fillMode: Image.PreserveAspectFit
                                                smooth: true
                                            }
                                        }
                                    }
                                }
                                Button {
                                    id: saveBtn
                                    text: "Zapisz zmiany"
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 150
                                    Layout.preferredHeight: 50
                                    contentItem: Text {
                                        text: saveBtn.text
                                        font.pixelSize: 18
                                        color: "#222"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    background: Rectangle {
                                        color: saveBtn.pressed ? "#2980b9" : (saveBtn.hovered ? "#5dade2" : "#3498db")
                                        radius: 6
                                    }
                                    onClicked: {
                                        let finalState = {
                                            "name": workingInfo.name+"."+originalInfo.format || "",
                                            "date": workingInfo.date || "",
                                            "artist": workingInfo.artist || "",
                                            "copyright": workingInfo.copyright || "",
                                            "description": workingInfo.description || "",
                                            "path": originalInfo.path,
                                            "format": originalInfo.format,
                                            "w": originalInfo.w,
                                            "h": originalInfo.h,
                                            "dpi": originalInfo.dpi,
                                            "depth": originalInfo.depth,
                                            "fileSize": originalInfo.fileSize,
                                            "cameraModel": originalInfo.cameraModel,
                                            "iso": originalInfo.iso,
                                            "fStop": originalInfo.fStop,
                                            "shutterSpeed": originalInfo.shutterSpeed,
                                            "flipH" : workingInfo.flipH,
                                            "flipV" : workingInfo.flipV,
                                            "angle" : workingInfo.angle,
                                            "contrast": workingInfo.contrast,
                                            "saturation": workingInfo.saturation,
                                            "exposition": workingInfo.exposition,
                                            "temperature": workingInfo.temperature,
                                            "blur": workingInfo.blur,
                                            "crop": {
                                                "x": workingInfo.crop.x || 0,
                                                "y": workingInfo.crop.y || 0,
                                                "w": workingInfo.crop.w || originalInfo.crop.w,
                                                "h": workingInfo.crop.h || originalInfo.crop.h
                                            },
                                            "f_krawedzie": workingInfo.f_krawedzie,
                                            "f_szum": workingInfo.f_szum,
                                            "f_rozmycie_kol": workingInfo.f_rozmycie_kol,
                                            "f_pixel_art": workingInfo.f_pixel_art,
                                            "f_stary_film": workingInfo.f_stary_film,
                                            "f_negatyw": workingInfo.f_negatyw,
                                            "f_progowanie": workingInfo.f_progowanie,
                                            "f_sepia_retro": workingInfo.f_sepia_retro,
                                            "f_zimna_noc": workingInfo.f_zimna_noc,
                                            "f_cieple_lato": workingInfo.f_cieple_lato
                                        };
                                        metadataScreen.metadataUpdated(finalState);
                                        mainStack.pop();
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
        }
    }
    ConfirmDialog {
        id: confirmExitDialog
        message: "Masz niezapisane zmiany. Czy na pewno chcesz wyjść?"
        onConfirmed: mainStack.pop()
    }
}
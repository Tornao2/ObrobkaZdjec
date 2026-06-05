import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../Kontrolki"
import "../Style"
Rectangle {
    id: metadataScreen
    color: Style.dialogBackground
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
        let newState = JSON.parse(JSON.stringify(state));
        workingInfo = {};
        workingInfo = newState;
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
    Keys.forwardTo: [historyHandler]
    Item {
        id: historyHandler
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Z && (event.modifiers & Qt.ControlModifier)) {
                undoBtn.clicked();
                event.accepted = true;
            }
            if (event.key === Qt.Key_Y && (event.modifiers & Qt.ControlModifier)) {
                redoBtn.clicked();
                event.accepted = true;
            }
        }
    }
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        Rectangle {
            id: topBar
            Layout.fillWidth: true
            Layout.preferredHeight: Style.metadataTopBarHeight
            color: Style.dialogBackground
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            Rectangle {
                Layout.preferredWidth: Style.metadataLeftPanelWidth
                Layout.fillHeight: true
                color: Style.dialogBackground
                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Style.metadataPanelMargin
                    anchors.rightMargin: Style.metadataPanelMargin
                    spacing: Style.metadataPanelSpacing
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
                        Layout.fillWidth: true
                        CustomButton {
                            id: undoBtn
                            Layout.fillWidth: true
                            enabled: historyIndex > 0
                            opacity: enabled ? 1.0 : 0.4
                            Layout.preferredWidth: Style.metadataActionBtnSize; Layout.preferredHeight: Style.metadataActionBtnSize
                            icon.source: "../Resources/undo.svg"
                            iconSize: Style.metadataActionIconSize
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
                                    opacity: redoBtn.enabled ? 1.0 : Style.metadataDisabledIconOpacity
                                    mirror: true
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
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
                            property bool showingOriginal: false
                            Layout.fillWidth: true
                            enabled: historyIndex > 0
                            Layout.preferredWidth: Style.metadataActionBtnSize; Layout.preferredHeight: Style.metadataActionBtnSize
                            icon.source: "../Resources/transition-right.svg"
                            iconSize: Style.metadataActionIconSize
                            tooltipText: "Przytrzymaj kursor, aby podejrzeć oryginał"
                            hoverEnabled: true
                            onEntered: applyState(originalInfo)
                            onExited: applyState(history[historyIndex])
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Style.metadataSeparatorColor
                        opacity: 0.5
                    }
                    Text {
                        text: "Motyw"
                        font.pixelSize: 14
                        font.weight: Style.fontWeight
                        color: Style.tertiaryTextColor
                        Layout.alignment: Qt.AlignHCenter
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Repeater {
                            model: [
                                { key: "normal", label: "Neutralny" },
                                { key: "light",  label: "Jasny"     },
                                { key: "dark",   label: "Ciemny"    }
                            ]
                            delegate: Button {
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: 38
                                property bool isActive: Style.currentTheme === modelData.key
                                contentItem: Text {
                                    text: modelData.label
                                    font.pixelSize: 14
                                    font.weight: parent.isActive ? Font.DemiBold : Style.fontWeight
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: parent.isActive ? Style.colorWhite : Style.secondaryTextColor
                                }
                                background: Rectangle {
                                    radius: Style.dialogRadius
                                    color: parent.isActive
                                        ? Style.metadataSaveBtnNormal
                                        : (parent.hovered ? Style.customButtonHover : Style.customButtonNormal)
                                    border.color: parent.isActive
                                        ? Style.metadataSaveBtnPressed
                                        : Style.metadataSeparatorColor
                                    border.width: 1
                                }
                                onClicked: {
                                    if (!isActive) {
                                        Style.currentTheme = modelData.key
                                    }
                                }
                            }
                        }
                    }
                    Item { Layout.fillHeight: true }
                }
            }
            Rectangle {
                color: Style.metadataRightPanelBg
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 0
                Rectangle {
                    id: metadataField
                    anchors.fill: parent
                    anchors.margins: Style.metadataContentMargin
                    color: Style.dialogBackground
                    ScrollView {
                        id: scrollView
                        anchors.fill: parent
                        anchors.margins: Style.metadataScrollMargin
                        clip: true
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded
                        ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                        ColumnLayout {
                            id: contentLayout
                            width: scrollView.availableWidth
                            spacing: Style.metadataContentSpacing
                            MetadataEditRow {
                                id: nameRow
                                label: "Nazwa pliku:"
                                value: stripExtension(workingInfo.name || "")
                                onEdited: (newValue) => {
                                    let temp = workingInfo
                                    temp.name = newValue;
                                    workingInfo = temp
                                    saveStep();
                                }
                                Layout.fillWidth: true
                                trailingIcon: "../Resources/edit-pencil.svg"
                                isReadOnly: false
                            }
                            MetadataEditRow {
                                id: dateRow
                                label: "Data wykonania:"
                                value: workingInfo.date || ""
                                onEdited: (newValue) => {
                                    let temp = workingInfo
                                    temp.date = newValue;
                                    workingInfo = temp
                                    saveStep();
                                }
                                inputMask: "0000-00-00 00:00;_"
                                validator: RegularExpressionValidator {
                                    regularExpression: /^((19|20)\d\d)-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])\s([01][0-9]|2[0-3]):([0-5][0-9])$/
                                }
                                Layout.fillWidth: true
                                trailingIcon: "../Resources/edit-pencil.svg"
                                isReadOnly: false
                            }
                            MetadataEditRow {
                                label: "Ścieżka:"
                                value: imageInfo.path || ""
                                isReadOnly: true
                                opacity: Style.metadataReadOnlyOpacity
                                Layout.fillWidth: true
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                height: Style.metadataSeparatorHeight
                                color: Style.metadataSeparatorColor
                            }
                            MetadataEditRow {
                                label: "Rozdzielczość:"
                                value: (imageInfo.w || 0) + " x " + (imageInfo.h || 0)
                                isReadOnly: true
                                opacity: Style.metadataReadOnlyOpacity
                                Layout.fillWidth: true
                            }
                            MetadataEditRow {
                                label: "Format pliku:"
                                value: imageInfo.format || ""
                                isReadOnly: true
                                opacity: Style.metadataReadOnlyOpacity
                                Layout.fillWidth: true
                            }
                            MetadataEditRow {
                                label: "Dpi:"
                                value: imageInfo.dpi || ""
                                isReadOnly: true
                                opacity: Style.metadataReadOnlyOpacity
                                Layout.fillWidth: true
                            }
                            MetadataEditRow {
                                label: "Głębia koloru:"
                                value: imageInfo.depth || ""
                                isReadOnly: true
                                opacity: Style.metadataReadOnlyOpacity
                                Layout.fillWidth: true
                            }
                            MetadataEditRow {
                                label: "Rozmiar pliku:"
                                value: imageInfo.fileSize || ""
                                isReadOnly: true
                                opacity: Style.metadataReadOnlyOpacity
                                Layout.fillWidth: true
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                height: Style.metadataSeparatorHeight
                                color: Style.metadataSeparatorColor
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                MetadataEditRow {
                                    label: "Model aparatu:"
                                    value: imageInfo.cameraModel || ""
                                    isReadOnly: true
                                    opacity: Style.metadataReadOnlyOpacity
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: Style.metadataRowWidthLarge
                                }
                                MetadataEditRow {
                                    label: "ISO:"
                                    value: imageInfo.iso || ""
                                    isReadOnly: true
                                    opacity: Style.metadataReadOnlyOpacity
                                    Layout.preferredWidth: Style.metadataRowWidthSmall
                                    Layout.alignment: Qt.AlignLeft
                                }
                                Item { Layout.fillWidth: true }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                MetadataEditRow {
                                    label: "Przysłona:"
                                    value: imageInfo.fStop || ""
                                    isReadOnly: true
                                    opacity: Style.metadataReadOnlyOpacity
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: Style.metadataRowWidthLarge
                                }
                                MetadataEditRow {
                                    label: "Czas naświetlania:"
                                    value: imageInfo.shutterSpeed || ""
                                    isReadOnly: true
                                    opacity: Style.metadataReadOnlyOpacity
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: Style.metadataRowWidthSmall
                                    Layout.alignment: Qt.AlignLeft
                                }
                                Item { Layout.fillWidth: true }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                height: Style.metadataSeparatorHeight
                                color: Style.metadataSeparatorColor
                            }
                            MetadataEditRow {
                                id: artistRow
                                label: "Autor/Twórca:"
                                value: workingInfo.artist || ""
                                onEdited: (newValue) => {
                                    let temp = workingInfo
                                    temp.artist = newValue;
                                    workingInfo = temp
                                    saveStep();
                                }
                                Layout.fillWidth: true
                                trailingIcon: "../Resources/edit-pencil.svg"
                                isReadOnly: false
                            }
                            MetadataEditRow {
                                id: copyrightRow
                                label: "Prawa autorskie:"
                                value: workingInfo.copyright || ""
                                onEdited: (newValue) => {
                                    let temp = workingInfo
                                    temp.copyright = newValue;
                                    workingInfo = temp
                                    saveStep();
                                }
                                Layout.fillWidth: true
                                trailingIcon: "../Resources/edit-pencil.svg"
                                isReadOnly: false
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                height: Style.metadataSeparatorHeight
                                color: Style.metadataSeparatorColor
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Style.inputRowSpacing
                                Text {
                                    text: "Opis zdjęcia:"
                                    font.pixelSize: Style.inputLabelFontSize
                                    font.bold: Style.inputLabelFontBold
                                    color: Style.inputLabelColor
                                    Layout.preferredWidth: Style.inputLabelWidth
                                    Layout.minimumWidth: Style.inputLabelWidth
                                    Layout.maximumWidth: Style.inputLabelWidth
                                    Layout.alignment: Qt.AlignTop
                                    horizontalAlignment: Text.AlignRight
                                    Layout.topMargin: Style.metadataDescriptionLabelTopMargin
                                }
                                Item {
                                    Layout.fillWidth: true
                                    Layout.rightMargin: Style.inputFieldRightMargin
                                    Layout.preferredHeight: Style.metadataDescriptionHeight
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: Style.inputFieldRadius
                                        color: Style.inputFieldBgNormal
                                        border.color: descriptionArea.activeFocus ? Style.inputFieldFocusBorderColor : "transparent"
                                        border.width: Style.inputFieldBorderWidth
                                        TextArea {
                                            id: descriptionArea
                                            anchors.fill: parent
                                            text: workingInfo.description || ""
                                            color: Style.inputFieldTextNormal
                                            background: null
                                            placeholderText: "Kliknij, aby dodać opis..."
                                            placeholderTextColor: Style.disabledTextColor
                                            font.pixelSize: Style.fontBodySize
                                            topPadding: Style.metadataDescriptionPaddingTop
                                            bottomPadding: Style.metadataDescriptionPaddingBottom
                                            leftPadding: Style.metadataDescriptionPaddingLeft
                                            rightPadding: Style.metadataDescriptionPaddingRight
                                            wrapMode: TextEdit.Wrap
                                            verticalAlignment: TextEdit.AlignTop
                                            onEditingFinished: saveStep()
                                            onTextChanged: {
                                                if (!isRestoring && workingInfo.description !== text) {
                                                    let temp = workingInfo
                                                    temp.description = text;
                                                    workingInfo = temp
                                                    saveStep()
                                                }
                                            }
                                            Keys.onPressed: (event) => {
                                                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                                    nextItemInFocusChain().forceActiveFocus();
                                                    event.accepted = true;
                                                }
                                            }
                                        }
                                        Image {
                                            source: Style.currentTheme === "dark" ? "../Resources/icons-light/edit-pencil.svg" :  "../Resources/edit-pencil.svg"
                                            width: Style.inputIconSize
                                            height: Style.inputIconSize
                                            anchors.right: parent.right
                                            anchors.rightMargin: Style.inputIconRightMargin
                                            anchors.verticalCenter: parent.verticalCenter
                                            opacity: descriptionArea.activeFocus ? Style.inputIconFocusOpacity : Style.inputIconNormalOpacity
                                            fillMode: Image.PreserveAspectFit
                                            smooth: true
                                        }
                                    }
                                }
                            }
                            Button {
                                id: saveBtn
                                text: "Zapisz zmiany"
                                Layout.preferredWidth: Style.metadataSaveBtnWidth
                                Layout.preferredHeight: Style.metadataSaveBtnHeight
                                Layout.alignment: Qt.AlignHCenter
                                contentItem: Text {
                                    text: saveBtn.text
                                    font.pixelSize: Style.metadataSaveBtnFontSize
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Rectangle {
                                    color: saveBtn.pressed ? Style.metadataSaveBtnPressed : (saveBtn.hovered ? Style.metadataSaveBtnHover : Style.metadataSaveBtnNormal)
                                    radius: Style.metadataSaveBtnRadius
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
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.metadataBottomBarHeight1
            color: Style.dialogBackground
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.metadataBottomBarHeight2
            color: Style.metadataBottomBarColor2
        }
    }
}
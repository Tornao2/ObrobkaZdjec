import QtQuick
import QtQuick.Window
import QtQuick.Controls
import "Ekrany"
import "Kontrolki"
import "./Style"
ApplicationWindow {
    id: mainWindow
    width: 1152
    height: 720
    minimumWidth: 800
    minimumHeight: 500
    visible: true
    title: "PhotoEditor"
    Component.onCompleted: {
        x = (Screen.width - width) / 2
        y = (Screen.height - height) / 2 - 20
    }
    flags: Qt.Window | Qt.WindowTitleHint | Qt.WindowMinMaxButtonsHint | Qt.WindowCloseButtonHint
    StackView {
        id: mainStack
        clip: true
        anchors.fill: parent
        initialItem: startComponent
        pushEnter: null
        pushExit: null
        popEnter: null
        popExit: null
        replaceEnter: null
        replaceExit: null
        Component {
            id: startComponent
            StartScreen {
                onFileSelected: function(filePath) {
                    mainStack.push("Ekrany/EditorScreen.qml", { "imagePath": filePath})
                }
            }
        }
    }
    ConfirmChangeDialog {
        id: globalConfirmDialog
        anchors.fill: parent
        parent: mainWindow.contentItem
    }
}
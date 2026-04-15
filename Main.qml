import QtQuick
import QtQuick.Window
import QtQuick.Controls
import "Ekrany"
import "Kontrolki"

ApplicationWindow {
    id: mainWindow
    width: 1280
    height: 960
    visible: true
    title: "PhotoEditor"
    x: (Screen.width - width) / 2
    y: (Screen.height - height) / 2 - 20
    StackView {
        id: mainStack
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
                    mainStack.push("Ekrany/EditorScreen.qml", { "imagePath": filePath })
                }
            }
        }
    }
}
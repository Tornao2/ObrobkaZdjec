import QtQuick
import QtQuick.Window
import QtQuick.Controls
import "Ekrany"

Window {
    width: 1280
    height: 960
    visible: true
    title: "PhotoEditor"

    StackView {
        id: mainStack
        anchors.fill: parent
        initialItem: startComponent
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
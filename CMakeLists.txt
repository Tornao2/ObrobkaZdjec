cmake_minimum_required(VERSION 3.16)

project(KomunikacjaKomputerowa VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Gui Qml Quick QuickControls2 QuickEffects ShaderTools)

qt_standard_project_setup(REQUIRES 6.10)

qt_add_executable(appKomunikacjaKomputerowa
    main.cpp
)

qt6_add_shaders(appKomunikacjaKomputerowa "my_shaders"
    PBR
    PREFIX "/shaders"
    FILES "filters.frag"
)

set(RES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Resources")
file(GLOB_RECURSE IMAGE_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "Resources/*.svg" "Resources/*.png")

set_target_properties(appKomunikacjaKomputerowa PROPERTIES
    UNITY_BUILD ON
)

qt_add_qml_module(appKomunikacjaKomputerowa
    URI KomunikacjaKomputerowa
    QML_FILES
        Main.qml
        Ekrany/StartScreen.qml
        Ekrany/EditorScreen.qml
        Ekrany/MetadataScreen.qml
        Ekrany/ManipulationScreen.qml
        Ekrany/CorrectionScreen.qml
        Ekrany/FilterScreen.qml
        Ekrany/DrawingScreen.qml
        Style/Style.qml
        Kontrolki/CornerButton.qml
        Kontrolki/MetadataEditRow.qml
        Kontrolki/ConfirmDialog.qml
        Kontrolki/CorrectionSlider.qml
        Kontrolki/FIlterButton.qml
        Kontrolki/CustomButton.qml
        Kontrolki/ConfirmChangeDialog.qml
    RESOURCES
        ${IMAGE_FILES}
        filters.frag
        QML_FILES
        RESOURCES Resources/icons-light/arrow-email-forward.svg Resources/icons-light/arrow-left.svg Resources/icons-light/arrow-right.svg Resources/icons-light/arrow-separate-vertical.svg Resources/icons-light/arrow-separate.svg Resources/icons-light/circle.svg Resources/icons-light/color-filter.svg Resources/icons-light/color-picker.svg Resources/icons-light/copy.svg Resources/icons-light/corner-bottom-left.svg Resources/icons-light/crop.svg Resources/icons-light/design-nib.svg Resources/icons-light/download.svg Resources/icons-light/drag-hand-gesture.svg Resources/icons-light/edit-pencil.svg Resources/icons-light/erase.svg Resources/icons-light/fast-arrow-left.svg Resources/icons-light/fast-arrow-right.svg Resources/icons-light/floppy-disk.svg Resources/icons-light/info-circle.svg Resources/icons-light/maximize.svg Resources/icons-light/open-in-window.svg Resources/icons-light/printer.svg Resources/icons-light/rotate-camera-left.svg Resources/icons-light/rotate-camera-right.svg Resources/icons-light/square3d-corner-to-corner.svg Resources/icons-light/sun-light.svg Resources/icons-light/text.svg Resources/icons-light/transition-right.svg Resources/icons-light/trash.svg Resources/icons-light/undo.svg Resources/icons-light/xmark.svg Resources/icons-light/zoom-in.svg Resources/icons-light/zoom-out.svg
        RESOURCES Style/qmldir
        RESOURCES Style/qmldir
)

target_precompile_headers(appKomunikacjaKomputerowa
    PRIVATE
        <QtCore/QDebug>
        <QtGui/QGuiApplication>
        <QtQml/QQmlApplicationEngine>
    )

set_target_properties(appKomunikacjaKomputerowa PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appKomunikacjaKomputerowa
    PRIVATE Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2 Qt6::QuickEffects Qt6::ShaderTools
)

install(TARGETS appKomunikacjaKomputerowa
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
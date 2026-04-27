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
        SOURCES
        QML_FILES Ekrany/StartScreen.qml
        QML_FILES Ekrany/EditorScreen.qml
        QML_FILES Ekrany/MetadataScreen.qml
        QML_FILES Ekrany/ManipulationScreen.qml
        QML_FILES Ekrany/CorrectionScreen.qml
        QML_FILES Ekrany/FilterScreen.qml
        QML_FILES Ekrany/DrawingScreen.qml
    RESOURCES
        ${IMAGE_FILES}
        QML_FILES Kontrolki/CornerButton.qml
        QML_FILES Kontrolki/MetadataEditRow.qml
        QML_FILES Kontrolki/ConfirmDialog.qml
        QML_FILES Kontrolki/CorrectionSlider.qml
        QML_FILES Kontrolki/FilterButton.qml
        QML_FILES Kontrolki/CustomButton.qml
        RESOURCES filters.frag
)

target_precompile_headers(appKomunikacjaKomputerowa
    PRIVATE
        <QtCore/QDebug>
        <QtGui/QGuiApplication>
        <QtQml/QQmlApplicationEngine>
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appKomunikacjaKomputerowa PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appKomunikacjaKomputerowa
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

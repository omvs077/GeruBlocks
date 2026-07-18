cmake_minimum_required(VERSION 3.21)
project(GeruBlocks VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

# --- Qt setup ---
# Adjust this path if your Qt install location differs.
# Example: C:/Qt/6.7.0/msvc2019_64
if(DEFINED ENV{QT_DIR})
    set(CMAKE_PREFIX_PATH "$ENV{QT_DIR}")
endif()

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2)

qt_standard_project_setup()

qt_add_executable(GeruBlocksApp
    src/main.cpp
)

qt_add_resources(GeruBlocksApp "fonts"
    PREFIX "/fonts"
    FILES
        assets/fonts/Poppins-Regular.ttf
        assets/fonts/Poppins-Medium.ttf
        assets/fonts/Poppins-SemiBold.ttf
)

qt_add_qml_module(GeruBlocksApp
    URI GeruBlocks
    VERSION 1.0
    QML_FILES
        qml/Main.qml
    SOURCES
        src/Core/ThemeManager.h
        src/Core/ThemeManager.cpp
        src/Core/LocalizationUtil.h
        src/Core/LocalizationUtil.cpp
)

target_link_libraries(GeruBlocksApp
    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
)

target_include_directories(GeruBlocksApp
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Core
)

# Resources (icons, fonts) will be added here once Batch 1 icons are wired in — Stage 2.

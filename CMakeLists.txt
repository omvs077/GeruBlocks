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

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 QuickDialogs2)

qt_standard_project_setup()

qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

qt_add_executable(GeruBlocksApp
    src/main.cpp
)

qt_add_resources(GeruBlocksApp "fonts"
    PREFIX "/fonts"
    FILES
        # Poppins -- primary voice, Latin+Devanagari merged per family
        assets/fonts/Poppins-Regular.ttf
        assets/fonts/Poppins-Medium.ttf
        assets/fonts/Poppins-SemiBold.ttf
        assets/fonts/Poppins-Light.ttf
        assets/fonts/Poppins-Black.ttf

        # IBM Plex Sans -- dense/numeric data (Phase 3 backlog)
        assets/fonts/IBMPlexSans-Thin.ttf
        assets/fonts/IBMPlexSans-ExtraLight.ttf
        assets/fonts/IBMPlexSans-Light.ttf
        assets/fonts/IBMPlexSans-Regular.ttf
        assets/fonts/IBMPlexSans-Medium.ttf
        assets/fonts/IBMPlexSans-SemiBold.ttf
        assets/fonts/IBMPlexSans-Bold.ttf

        # IBM Plex Sans Devanagari -- dense/numeric data, Devanagari companion
        assets/fonts/IBMPlexSansDevanagari-Thin.ttf
        assets/fonts/IBMPlexSansDevanagari-ExtraLight.ttf
        assets/fonts/IBMPlexSansDevanagari-Light.ttf
        assets/fonts/IBMPlexSansDevanagari-Regular.ttf
        assets/fonts/IBMPlexSansDevanagari-Medium.ttf
        assets/fonts/IBMPlexSansDevanagari-SemiBold.ttf
        assets/fonts/IBMPlexSansDevanagari-Bold.ttf

        # IBM Plex Mono -- Keycap chips, technical/version accents
        assets/fonts/IBMPlexMono-Thin.ttf
        assets/fonts/IBMPlexMono-ExtraLight.ttf
        assets/fonts/IBMPlexMono-Light.ttf
        assets/fonts/IBMPlexMono-Regular.ttf
        assets/fonts/IBMPlexMono-Medium.ttf
        assets/fonts/IBMPlexMono-SemiBold.ttf
        assets/fonts/IBMPlexMono-Bold.ttf

        # Martel -- serif contrast, print/export + formal on-screen UI (covers Latin+Devanagari in one family)
        assets/fonts/Martel-ExtraLight.ttf
        assets/fonts/Martel-Light.ttf
        assets/fonts/Martel-Regular.ttf
        assets/fonts/Martel-SemiBold.ttf
        assets/fonts/Martel-Bold.ttf
        assets/fonts/Martel-ExtraBold.ttf
        assets/fonts/Martel-Black.ttf

        # Kalam + Dancing Script -- marketing/branding script fonts, NOT part of
        # the Phase 3 backlog's 5 UI-typography levers. Embedded but currently
        # have no consumer anywhere in the QML component library -- no website
        # or marketing surface exists yet to use them on (per the locked build
        # sequence). Flagging so this isn't mistaken for dead/unused weight if
        # revisited later: intentional, just ahead of the surface that needs it.
        assets/fonts/Kalam-Light.ttf
        assets/fonts/Kalam-Regular.ttf
        assets/fonts/Kalam-Bold.ttf
        assets/fonts/DancingScript-Regular.ttf
        assets/fonts/DancingScript-Medium.ttf
        assets/fonts/DancingScript-SemiBold.ttf
        assets/fonts/DancingScript-Bold.ttf
)

# ToastManager and CommandRegistry use `pragma Singleton` in the QML file itself,
# but that pragma alone is NOT enough to register them as singletons with
# qt_add_qml_module — this property must be set explicitly, BEFORE the
# qt_add_qml_module() call below.
set_source_files_properties(
    qml/Components/ToastManager.qml
    qml/Components/CommandRegistry.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(GeruBlocksApp
    URI GeruBlocks
    VERSION 1.0
    QML_FILES
    qml/Main.qml
    qml/IconGallery.qml
    qml/Theme/Icon.qml
    qml/Components/Heading.qml
    qml/Components/AppText.qml
    qml/Components/Link.qml
    qml/Components/Button.qml
    qml/Components/Badge.qml
    qml/Components/Card.qml
    qml/Components/DataTable.qml
    qml/Components/AppTextInput.qml
    qml/Components/Skeleton.qml
    qml/Components/Keycap.qml
    qml/Components/NavItem.qml
    qml/Components/Dialog.qml
    qml/Components/ToastManager.qml
    qml/Components/ToastHost.qml
    qml/Components/CommandRegistry.qml
    qml/Components/CommandPalette.qml
    qml/Components/AppShell.qml
    qml/Components/AppCheckbox.qml
    qml/Components/AppRadioButton.qml
    qml/Components/AppRadioGroup.qml
    qml/Components/AppSwitch.qml
    qml/Components/SegmentedControl.qml
    qml/Components/AppSlider.qml
    qml/Components/NumberStepper.qml
    qml/Components/Select.qml
    qml/Components/AppTextArea.qml
    qml/Components/AppCombobox.qml
    qml/Components/FileDropzone.qml
    qml/Components/DatePicker.qml
    qml/Components/TimePicker.qml
    qml/Components/Form.qml
    qml/Components/AppPhoneInput.qml
    qml/Components/IconButton.qml
    qml/Components/IconButton.qml
    qml/Components/ButtonGroup.qml
    qml/Components/SplitButton.qml
    qml/Components/DropdownMenu.qml
    qml/Components/ContextMenu.qml
    qml/Components/MenuBar.qml
    qml/Components/Tabs.qml
    qml/Components/Breadcrumbs.qml
    qml/Components/Pagination.qml
    qml/Components/Accordion.qml
    qml/Components/AccordionSection.qml
    qml/Components/AppTreeView.qml
    qml/Components/TreeNode.qml
    qml/Components/Stepper.qml
    qml/Components/Tooltip.qml
    qml/Components/Popover.qml
    qml/Components/Drawer.qml
    qml/Components/Coachmark.qml
    qml/Components/ProgressBar.qml
    qml/Components/Spinner.qml
    qml/Components/EmptyState.qml
    qml/Components/InlineAlert.qml
    qml/Components/StatusDot.qml
    qml/Components/Divider.qml
    qml/Components/Avatar.qml
    qml/Components/AvatarGroup.qml
    qml/Components/ListItem.qml
    qml/Components/List.qml
    qml/Components/StatTile.qml
    qml/Components/RemovableTag.qml
    qml/Components/Timeline.qml
    qml/Components/KeyValue.qml
    qml/Components/LineChart.qml
    qml/Components/BarChart.qml
    qml/Components/DonutChart.qml
    qml/Components/Sparkline.qml
    qml/Components/GaugeChart.qml
    qml/Components/TitleBar.qml
    qml/Components/ResizeBorders.qml
    qml/Components/Toolbar.qml
    qml/Components/StatusBar.qml
    qml/Components/SplitPane.qml
    qml/Components/Panel.qml
    qml/Components/LayoutStack.qml
    qml/Components/LayoutGrid.qml
    qml/Components/ScrollArea.qml
    qml/Components/BackgroundMotif.qml
    qml/Components/Scrollbar.qml

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
        Qt6::QuickDialogs2
)

target_include_directories(GeruBlocksApp
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Core
)

# Resources (icons, fonts) will be added here once Batch 1 icons are wired in — Stage 2.
file(GLOB ICON_FILES "${CMAKE_CURRENT_SOURCE_DIR}/assets/icons/*.svg")

qt_add_resources(GeruBlocksApp "icons"
    PREFIX "/icons"
    BASE "${CMAKE_CURRENT_SOURCE_DIR}/assets/icons"
    FILES ${ICON_FILES}
)

qt_add_resources(GeruBlocksApp "textures"
    PREFIX "/textures"
    BASE "${CMAKE_CURRENT_SOURCE_DIR}/assets/textures"
    FILES "${CMAKE_CURRENT_SOURCE_DIR}/assets/textures/glow.png"
)


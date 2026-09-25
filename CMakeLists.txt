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

# =====================================================================
# GeruBlocksUI -- the actual design-system library (Section 5 backlog,
# "Option A packaging refactor"). Owns every reusable component (all 72,
# Icon.qml, ThemeManager, LocalizationUtil) plus the fonts/icons/textures
# they depend on. Main.qml and IconGallery.qml deliberately do NOT live
# here -- they're test-harness content, kept in GeruBlocksApp's own
# separate module below, which imports GeruBlocksUI's "GeruBlocks" module
# from the outside -- "an example app depending on the library like any
# real consumer would," per the backlog's own wording, not a specially-
# privileged internal relationship.
#
# STATIC linking chosen for now (not shared/.dll): simpler deployment,
# no separate library file to ship alongside the exe, no plugin-path
# complexity -- reasonable while there's no external consumer yet and no
# real distribution has started. Revisit once actual publishing begins.
# =====================================================================

qt_add_library(GeruBlocksUI STATIC)

# ToastManager and CommandRegistry use `pragma Singleton` in the QML file
# itself, but that pragma alone is NOT enough to register them as
# singletons with qt_add_qml_module — this property must be set
# explicitly, BEFORE the qt_add_qml_module() call below.
set_source_files_properties(
    qml/Components/ToastManager.qml
    qml/Components/CommandRegistry.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(GeruBlocksUI
    URI GeruBlocks
    VERSION 1.0
    QML_FILES
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

# PUBLIC (not PRIVATE): GeruBlocksApp's own main.cpp uses QGuiApplication,
# QQmlApplicationEngine, QQuickStyle etc directly, and needs these Qt
# symbols/headers transitively available just by linking GeruBlocksUI --
# the standard, correct propagation pattern for a library + thin-app split.
target_link_libraries(GeruBlocksUI
    PUBLIC
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::QuickDialogs2
)

target_include_directories(GeruBlocksUI
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/src
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Core
)

# --- Resources: fonts, icons, textures ---
# Attached to GeruBlocksUI, not GeruBlocksApp — these are consumed by
# library components (Icon.qml's masking pipeline, AppText/Heading's
# embedded font families), so they belong with the library, not the app.
#
# KNOWN RISK, FLAGGED: qt_add_resources on a STATIC library target can, in
# some CMake/linker configurations, have its resource-init translation
# unit silently stripped by the linker if nothing else references symbols
# from it (a classic Qt+static-lib gotcha, independent of the QML-module
# auto-import mechanism above). If the app launches but fonts fall back to
# a system font or icons render blank despite a clean build, THIS is the
# first thing to suspect — the standard fix is an explicit
# Q_INIT_RESOURCE() call in main.cpp. Not yet confirmed either way on this
# specific Qt 6.11 / CMake setup — treat as untested until screenshot-
# confirmed, same as every other new technique in this project.

# SPLIT INTO PER-FAMILY BLOCKS, FLAGGED WHY: a single combined "fonts"
# resource (all 64 files at once) generated one qrc_fonts.cpp large enough
# to hit MSVC's cl.exe "C1060: compiler is out of heap space" -- a real
# compiler front-end memory ceiling, not fixable by --parallel tuning
# (confirmed: reducing parallelism didn't help, since it's one compile
# unit's absolute size that's the problem, not contention with other
# jobs). Splitting into small per-family blocks keeps every generated
# .cpp well under that ceiling. Runtime paths are UNCHANGED by this split
# -- a resource block's name (e.g. "fonts_poppins") is purely a build-
# system label; PREFIX "/fonts" on every block below means the actual
# qrc path stays ":/fonts/Poppins-Regular.ttf" etc regardless of which
# block produced it, so nothing in main.cpp or any QML font.family
# string needed to change.

qt_add_resources(GeruBlocksUI "fonts_poppins"
    PREFIX "/fonts"
    FILES
        assets/fonts/Poppins-Regular.ttf
        assets/fonts/Poppins-Medium.ttf
        assets/fonts/Poppins-SemiBold.ttf
        assets/fonts/Poppins-Light.ttf
        assets/fonts/Poppins-Black.ttf
)

qt_add_resources(GeruBlocksUI "fonts_anek_bangla"
    PREFIX "/fonts"
    FILES
        assets/fonts/AnekBangla-Regular.ttf
        assets/fonts/AnekBangla-Medium.ttf
        assets/fonts/AnekBangla-SemiBold.ttf
)

qt_add_resources(GeruBlocksUI "fonts_anek_telugu"
    PREFIX "/fonts"
    FILES
        assets/fonts/AnekTelugu-Regular.ttf
        assets/fonts/AnekTelugu-Medium.ttf
        assets/fonts/AnekTelugu-SemiBold.ttf
)

qt_add_resources(GeruBlocksUI "fonts_anek_tamil"
    PREFIX "/fonts"
    FILES
        assets/fonts/AnekTamil-Regular.ttf
        assets/fonts/AnekTamil-Medium.ttf
        assets/fonts/AnekTamil-SemiBold.ttf
)

qt_add_resources(GeruBlocksUI "fonts_anek_gujarati"
    PREFIX "/fonts"
    FILES
        assets/fonts/AnekGujarati-Regular.ttf
        assets/fonts/AnekGujarati-Medium.ttf
        assets/fonts/AnekGujarati-SemiBold.ttf
)

qt_add_resources(GeruBlocksUI "fonts_anek_kannada"
    PREFIX "/fonts"
    FILES
        assets/fonts/AnekKannada-Regular.ttf
        assets/fonts/AnekKannada-Medium.ttf
        assets/fonts/AnekKannada-SemiBold.ttf
)

qt_add_resources(GeruBlocksUI "fonts_anek_odia"
    PREFIX "/fonts"
    FILES
        assets/fonts/AnekOdia-Regular.ttf
        assets/fonts/AnekOdia-Medium.ttf
        assets/fonts/AnekOdia-SemiBold.ttf
)

qt_add_resources(GeruBlocksUI "fonts_anek_malayalam"
    PREFIX "/fonts"
    FILES
        assets/fonts/AnekMalayalam-Regular.ttf
        assets/fonts/AnekMalayalam-Medium.ttf
        assets/fonts/AnekMalayalam-SemiBold.ttf
)

qt_add_resources(GeruBlocksUI "fonts_anek_gurmukhi"
    PREFIX "/fonts"
    FILES
        assets/fonts/AnekGurmukhi-Regular.ttf
        assets/fonts/AnekGurmukhi-Medium.ttf
        assets/fonts/AnekGurmukhi-SemiBold.ttf
)

qt_add_resources(GeruBlocksUI "fonts_ibmplexsans"
    PREFIX "/fonts"
    FILES
        assets/fonts/IBMPlexSans-Thin.ttf
        assets/fonts/IBMPlexSans-ExtraLight.ttf
        assets/fonts/IBMPlexSans-Light.ttf
        assets/fonts/IBMPlexSans-Regular.ttf
        assets/fonts/IBMPlexSans-Medium.ttf
        assets/fonts/IBMPlexSans-SemiBold.ttf
        assets/fonts/IBMPlexSans-Bold.ttf
)

qt_add_resources(GeruBlocksUI "fonts_ibmplexsansdevanagari"
    PREFIX "/fonts"
    FILES
        assets/fonts/IBMPlexSansDevanagari-Thin.ttf
        assets/fonts/IBMPlexSansDevanagari-ExtraLight.ttf
        assets/fonts/IBMPlexSansDevanagari-Light.ttf
        assets/fonts/IBMPlexSansDevanagari-Regular.ttf
        assets/fonts/IBMPlexSansDevanagari-Medium.ttf
        assets/fonts/IBMPlexSansDevanagari-SemiBold.ttf
        assets/fonts/IBMPlexSansDevanagari-Bold.ttf
)

qt_add_resources(GeruBlocksUI "fonts_ibmplexmono"
    PREFIX "/fonts"
    FILES
        assets/fonts/IBMPlexMono-Thin.ttf
        assets/fonts/IBMPlexMono-ExtraLight.ttf
        assets/fonts/IBMPlexMono-Light.ttf
        assets/fonts/IBMPlexMono-Regular.ttf
        assets/fonts/IBMPlexMono-Medium.ttf
        assets/fonts/IBMPlexMono-SemiBold.ttf
        assets/fonts/IBMPlexMono-Bold.ttf
)

qt_add_resources(GeruBlocksUI "fonts_martel"
    PREFIX "/fonts"
    FILES
        assets/fonts/Martel-ExtraLight.ttf
        assets/fonts/Martel-Light.ttf
        assets/fonts/Martel-Regular.ttf
        assets/fonts/Martel-SemiBold.ttf
        assets/fonts/Martel-Bold.ttf
        assets/fonts/Martel-ExtraBold.ttf
        assets/fonts/Martel-Black.ttf
)

qt_add_resources(GeruBlocksUI "fonts_script"
    PREFIX "/fonts"
    FILES
        assets/fonts/Kalam-Light.ttf
        assets/fonts/Kalam-Regular.ttf
        assets/fonts/Kalam-Bold.ttf
        assets/fonts/DancingScript-Regular.ttf
        assets/fonts/DancingScript-Medium.ttf
        assets/fonts/DancingScript-SemiBold.ttf
        assets/fonts/DancingScript-Bold.ttf
)

file(GLOB ICON_FILES "${CMAKE_CURRENT_SOURCE_DIR}/assets/icons/*.svg")

qt_add_resources(GeruBlocksUI "icons"
    PREFIX "/icons"
    BASE "${CMAKE_CURRENT_SOURCE_DIR}/assets/icons"
    FILES ${ICON_FILES}
)

qt_add_resources(GeruBlocksUI "textures"
    PREFIX "/textures"
    BASE "${CMAKE_CURRENT_SOURCE_DIR}/assets/textures"
    FILES "${CMAKE_CURRENT_SOURCE_DIR}/assets/textures/glow.png"
)

# =====================================================================
# GeruBlocksApp -- thin test-harness executable. Owns ONLY Main.qml and
# IconGallery.qml, in their own module (URI "GeruBlocksTestHarness", NOT
# "GeruBlocks" -- two separate QML modules can't share one URI, and
# Main.qml consuming the library from a distinct module, via a plain
# `import GeruBlocks`, is exactly the "example app depending on the
# library like any real consumer would" pattern the backlog calls for).
# =====================================================================

qt_add_executable(GeruBlocksApp
    src/main.cpp
)

qt_add_qml_module(GeruBlocksApp
    URI GeruBlocksTestHarness
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/IconGallery.qml
)

target_link_libraries(GeruBlocksApp
    PRIVATE
        GeruBlocksUI
)


qt6_import_qml_plugins(GeruBlocksApp)

target_link_libraries(GeruBlocksApp PRIVATE GeruBlocksUIplugin)

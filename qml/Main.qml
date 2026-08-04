import QtQuick
import QtQuick.Window
import QtQuick.Controls.Basic as Basic
import GeruBlocks

// Main.qml — consolidated test/verification window.
//
// Everything built and tested so far lives here in one place, organized
// into labeled sections, instead of being hand-edited every session.
// TEMP overall — once Step 2 components are fully signed off, this gets
// replaced by the real AppShell (Step 4) as the actual app entry point.

Window {
    id: window
    width: 900
    height: 800
    visible: true
    title: "Geru Blocks — Test Harness"
    color: ThemeManager.backgroundPage

    Basic.Button {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Open Test Dialog"
        z: 10
        onClicked: testDialog.open()
    }

    Basic.Button {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 8
        z: 10
        text: window.showAppShell ? "\u2190 Back to Test Harness" : "View AppShell \u2192"
        onClicked: window.showAppShell = !window.showAppShell
    }

    property bool showIconGallery: false
    property bool showAppShell: false

    Loader {
        anchors.fill: parent
        sourceComponent: window.showIconGallery ? galleryComponent : (window.showAppShell ? appShellComponent : mainComponent)
    }

    // ---------- NEW: overlays, sit above everything ----------
    Dialog {
        id: testDialog
        title: "Confirm Action"
        Text {
            text: "Are you sure you want to proceed?"
            color: ThemeManager.textSecondary
            font.family: "Poppins"
            font.pixelSize: 13
            wrapMode: Text.WordWrap
            width: 350
        }
        footer: Component {
            Row {
                spacing: 8
                anchors.right: parent.right
                Button { text: "Cancel"; variant: "ghost"; onClicked: testDialog.close() }
                Button {
                    text: "Confirm"; variant: "primary"
                    onClicked: {
                        testDialog.close()
                        ToastManager.show("Action confirmed", "success")
                    }
                }
            }
        }
    }

    ToastHost {}

    CommandPalette {}

    Component.onCompleted: {
        CommandRegistry.register("open-dialog", "Open Test Dialog", "Actions", "external_link", "", function() {
            testDialog.open()
        })
        CommandRegistry.register("toast-success", "Show Success Toast", "Actions", "checkmark", "", function() {
            ToastManager.show("This is a success toast", "success")
        })
        CommandRegistry.register("toast-error", "Show Error Toast", "Actions", "close", "", function() {
            ToastManager.show("This is an error toast", "error")
        })
    }

    Component {
        id: galleryComponent
        Item {
            IconGallery { anchors.fill: parent }
            Basic.Button {
                text: "\u2190 Back"
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 8
                onClicked: window.showIconGallery = false
            }
        }
    }

    Component {
        id: appShellComponent
        AppShell {}
    }

    Component {
        id: mainComponent

        Flickable {
            anchors.fill: parent
            contentWidth: width
            contentHeight: content.height + 40
            clip: true

            Column {
                id: content
                width: parent.width
                spacing: 28
                topPadding: 20
                bottomPadding: 20

                // ---------- Header / Theme + Density ----------
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 12

                    Heading { anchors.horizontalCenter: parent.horizontalCenter; text: "Geru Blocks" }

                    AppText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        variant: "caption"
                        text: "Mode: " + (ThemeManager.mode === ThemeManager.HighContrast
                                            ? "High Contrast"
                                            : (ThemeManager.isDark ? "Dark" : "Light"))
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 220
                        height: ThemeManager.controlHeight
                        radius: 0
                        color: themeToggleArea.pressed ? ThemeManager.accentPrimaryPressed : ThemeManager.accentPrimary
                        border.width: ThemeManager.borderWidthDefault
                        border.color: ThemeManager.borderDefault

                        Text {
                            anchors.centerIn: parent
                            text: "Toggle Light / Dark"
                            color: "#FFFFFF"
                            font.pixelSize: 14
                        }
                        MouseArea {
                            id: themeToggleArea
                            anchors.fill: parent
                            onClicked: ThemeManager.toggleLightDark()
                        }
                    }

                    AppText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        variant: "caption"
                        text: "Row height @ current density: " + ThemeManager.rowHeight + "px"
                    }
                }

                Rectangle { width: parent.width; height: 1; color: ThemeManager.borderDefault }

                // ---------- Localization ----------
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "subtitle"; text: "LocalizationUtil" }
                    AppText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: LocalizationUtil.formatCurrency(12345670) + " | " +
                              LocalizationUtil.formatDate(new Date()) + " | " +
                              LocalizationUtil.formatTime(new Date())
                    }
                }

                Rectangle { width: parent.width; height: 1; color: ThemeManager.borderDefault }

                // ---------- Font weights + Devanagari ----------
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "subtitle"; text: "Font weights (explicit family strings)" }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Header"; font.family: "Poppins SemiBold"; font.pixelSize: 24; color: ThemeManager.textPrimary }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Title";  font.family: "Poppins Medium";   font.pixelSize: 16; color: ThemeManager.textPrimary }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Base";   font.family: "Poppins";          font.pixelSize: 14; color: ThemeManager.textPrimary }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "गेरू ब्लॉक्स"; font.family: "Poppins Medium"; font.pixelSize: 20; color: ThemeManager.textPrimary }
                }

                Rectangle { width: parent.width; height: 1; color: ThemeManager.borderDefault }

                // ---------- Icons ----------
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "subtitle"; text: "Icon component (sample)" }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 20
                        Icon { name: "home"; size: 32; color: ThemeManager.accentPrimary }
                        Icon { name: "warning"; size: 32; color: ThemeManager.statusError }
                        Icon { name: "settings"; size: 32; color: ThemeManager.textPrimary }
                    }
                    Basic.Button {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "View full Icon Gallery (252 icons)"
                        onClicked: window.showIconGallery = true
                    }
                }

                Rectangle { width: parent.width; height: 1; color: ThemeManager.borderDefault }

                // ---------- Typography trio ----------
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "subtitle"; text: "Typography (Heading / AppText / Link)" }
                    Heading { anchors.horizontalCenter: parent.horizontalCenter; text: "Page Title" }
                    Heading { anchors.horizontalCenter: parent.horizontalCenter; text: "Section Title"; variant: "subheader" }
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; text: "Card title text"; variant: "title" }
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; text: "Secondary heading"; variant: "subtitle" }
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; text: "Default UI text" }
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; text: "Helper / metadata text"; variant: "caption" }
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; text: "Longer-form body copy for descriptions."; variant: "body" }
                    Link { anchors.horizontalCenter: parent.horizontalCenter; text: "Click this link"; onClicked: console.log("Link clicked") }
                }

                Rectangle { width: parent.width; height: 1; color: ThemeManager.borderDefault }

                // ---------- Button + Badge ----------
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 14
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "subtitle"; text: "Button + Badge" }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 12
                        Button { text: "Primary"; variant: "primary" }
                        Button { text: "Secondary"; variant: "secondary" }
                        Button { text: "Ghost"; variant: "ghost" }
                        Button { text: "Disabled"; enabled: false }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 12
                        Badge { text: "Neutral"; variant: "neutral" }
                        Badge { text: "Online"; variant: "success"; style: "outline" }
                        Badge { text: "Failed"; variant: "error"; style: "fill" }
                        Badge { text: "Urgent"; variant: "urgent"; style: "fill" }
                        Badge { variant: "error"; style: "dot" }
                    }

                    // FIXED: was `anchors.centerIn: parent`, which sets
                    // both horizontal AND vertical anchoring — the
                    // vertical half directly conflicts with Column's own
                    // vertical stacking of its children. Changed to
                    // horizontalCenter-only, matching the pattern used
                    // by every other Row/element in this file.
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 16

                        Card {
                            title: "Project Alpha — Status"
                            Text {
                                text: "Active, 3 members"
                                color: ThemeManager.textSecondary
                                font.family: "Poppins"
                                font.pixelSize: 13
                            }
                            footer: Component {
                                Link { text: "View details" }
                            }
                            onClicked: console.log("Card 1 clicked")
                        }

                        Card {
                            title: "No footer example"
                            Text {
                                text: "Just a title and body, no footer slot used."
                                color: ThemeManager.textSecondary
                                font.family: "Poppins"
                                font.pixelSize: 13
                                wrapMode: Text.WordWrap
                                width: 240
                            }
                        }
                    }
                }
          
                Rectangle { width: parent.width; height: 1; color: ThemeManager.borderDefault }

                // ---------- DataTable ----------
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "subtitle"; text: "DataTable" }

                    DataTable {
                        width: 500
                        height: 300
                        columns: [
                            { key: "project", title: "Project" },
                            { key: "progress", title: "Progress (%)", numeric: true, decimals: 1 },
                            { key: "budget", title: "Monthly Budget", numeric: true, currency: true }
                        ]
                        rows: [
                            { project: "Website Redesign", progress: 72.5, budget: 4500000 },
                            { project: "Mobile App", progress: 45.0, budget: 12300000 },
                            { project: "API Migration", progress: 88.0, budget: 3800000 },
                            { project: "Data Pipeline", progress: 33.5, budget: 3950000 }
                        ]
                        onRowClicked: (rowData) => console.log("Clicked:", rowData.project)
                    }
                }
            
                Rectangle { width: parent.width; height: 1; color: ThemeManager.borderDefault }

                // ---------- AppTextInput ----------
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 14
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "subtitle"; text: "AppTextInput" }

                    AppTextInput {
                        label: "Project Name"
                        placeholderText: "Enter project name"
                        helperText: "Shown to team members on the project board"
                    }

                    AppTextInput {
                        label: "Project Name (error)"
                        placeholderText: "Enter project name"
                        validationState: "error"
                        errorMessage: "Project name is required"
                        text: ""
                    }

                    AppTextInput {
                        label: "Project Name (success)"
                        text: "Website Redesign"
                        validationState: "success"
                        helperText: "Looks good"
                    }

                    AppTextInput {
                        label: "Project Name (disabled)"
                        text: "Locked field"
                        enabled: false
                    }
                }
            
                Rectangle { width: parent.width; height: 1; color: ThemeManager.borderDefault }

                // ---------- Skeleton + Keycap ----------
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 14
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "subtitle"; text: "Skeleton + Keycap" }

                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8
                        Skeleton { width: 220; height: 14 }
                        Skeleton { width: 180; height: 14 }
                        Skeleton { variant: "block"; width: 220; height: 100 }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 6
                        Keycap { text: "Ctrl" }
                        AppText { text: "+"; variant: "caption"; anchors.verticalCenter: parent.verticalCenter }
                        Keycap { text: "K" }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: ThemeManager.borderDefault }

                // ---------- NavItem ----------
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "subtitle"; text: "NavItem" }
                    Rectangle {
                        width: 220; height: 3 * 40
                        color: ThemeManager.backgroundSurface
                        border.width: 1
                        border.color: ThemeManager.borderDefault
                        Column {
                            anchors.fill: parent
                            NavItem { iconName: "home"; label: "Dashboard"; selected: true }
                            NavItem { iconName: "settings"; label: "Settings" }
                            NavItem { iconName: "users"; label: "Users" }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: ThemeManager.borderDefault }

                // ---------- Step 5 batch: Form Selection (STUBS) ----------
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 14
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "subtitle"; text: "Step 5 — Form Selection (stub batch)" }

                    AppCheckbox { text: "Enable notifications" }
                    AppCheckbox { text: "Pre-checked"; checked: true }

                    AppRadioGroup {
                        model: [
                            { value: "low", label: "Low priority" },
                            { value: "med", label: "Medium priority" },
                            { value: "high", label: "High priority" }
                        ]
                    }

                    AppSwitch { text: "Dark mode override" }

                    SegmentedControl {
                        width: 300
                        options: [
                            { value: "day", label: "Day" },
                            { value: "week", label: "Week" },
                            { value: "month", label: "Month" }
                        ]
                    }

                    AppSlider { width: 260 }

                    NumberStepper { from: 0; to: 20; value: 4 }
                }

                Rectangle { width: parent.width; height: 1; color: ThemeManager.borderDefault }

                // ---------- Step 6 batch: Form Inputs/Pickers (STUBS, 4 of 7) ----------
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 14
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "subtitle"; text: "Step 6 — Form Inputs (stub batch, 4 of 7)" }

                    Select {
                        model: [
                            { value: "eng", label: "Engineering" },
                            { value: "des", label: "Design" },
                            { value: "pm", label: "Product" }
                        ]
                    }

                    AppTextArea {
                        width: 260
                        height: 80
                        placeholderText: "Enter a description..."
                    }

                    AppCombobox {
                        placeholderText: "Search users..."
                        options: [
                            { value: "u1", label: "Aditi Sharma" },
                            { value: "u2", label: "Rahul Verma" },
                            { value: "u3", label: "Priya Nair" }
                        ]
                    }

                    FileDropzone {}

                    DatePicker {}
                }
            }
        }
    }
}
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
    minimumWidth: 480   // PROPOSAL: not set previously; a frameless window with no OS-enforced
    minimumHeight: 320  // minimum can be resized down to nothing via ResizeBorders. Adjust if needed.
    visible: true
    title: "Geru Blocks — Test Harness"
    color: ThemeManager.backgroundPage

    // Step 13: frameless window — TitleBar.qml + ResizeBorders.qml replace the native
    // OS chrome entirely. See Step13_Integration_Notes.md for the full rationale
    // (in particular: no Qt.WA_TranslucentBackground is needed here, since the sharp-
    // corners rule means the window is always a plain rectangle — nothing to anti-alias).
    flags: Qt.Window | Qt.FramelessWindowHint

    property bool showIconGallery: false
    property bool showAppShell: false
    property int demoCountUpValue: 24

    // ---------- Chrome: title bar + content workspace ----------
    Rectangle {
        id: chromeRoot
        anchors.fill: parent
        color: ThemeManager.backgroundPage
        // Substitute for the native window frame outline, lost along with the native
        // chrome. Hidden when maximized since the OS already snaps the window exactly
        // to the monitor work-area at that point — a native frame wouldn't show one either.
        border.width: window.visibility === Window.Maximized ? 0 : 1
        border.color: ThemeManager.borderDefault

        BackgroundMotif {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }

        TitleBar {
            id: titleBar
            width: parent.width
            title: window.title
        }

        Item {
            id: workspace
            anchors.top: titleBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

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

            Loader {
                anchors.fill: parent
                sourceComponent: window.showIconGallery ? galleryComponent : (window.showAppShell ? appShellComponent : mainComponent)
            }
        }
    }

    // Resize hit-zones for the frameless window — must sit at the Window level (not
    // inside chromeRoot/workspace) per the same rule as toast/dialog hosts: overlays
    // that need to catch input across the whole window belong at the top, not nested
    // inside scrolling/content items (handoff doc, Section 5 carried-forward notes).
    ResizeBorders {
        anchors.fill: parent
        visible: window.visibility !== Window.Maximized
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

    CommandPalette { backdropSource: chromeRoot }

    Drawer 
    {
        id: testDrawer
        edge: "left"
        drawerWidth: 280
        backdropSource: chromeRoot
        Heading { text: "Filters"; variant: "subheader" }
        AppCheckbox { text: "Active only" }
        AppCheckbox { text: "My projects" }
     }

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

        ScrollArea {
            anchors.fill: parent
            contentWidth: width
            contentHeight: content.height + 40

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
                        border.width: 1 // FIXED: was ThemeManager.borderWidthDefault, which doesn't exist on
                                        // ThemeManager (not in the confirmed grep'd property list — see handoff
                                        // doc). Was silently resolving to undefined at runtime. Every other
                                        // hairline border in this file just uses a literal 1, matched here.
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

                    DatePicker {}

                    TimePicker {}

                    Form {
                        id: testForm
                        width: 280

                        AppCheckbox {
                            text: "I agree to the terms"
                            required: true
                        }

                        FileDropzone {
                            required: true
                        }

                        AppTextInput {
                            label: "Project Name"
                            placeholderText: "Enter project name"
                            required: true
                        }

                        AppTextInput {
                            label: "Company Name"
                            placeholderText: "Optional"
                            helperText: "Leave blank if not applicable"
                            // no `required` — defaults to false
                        }

                        AppTextInput {
                            id: emailField
                            label: "Owner Email"
                            placeholderText: "name@company.com"
                            validationType: "email"
                            required: true
                        }

                        AppTextInput {
                            id: passwordField
                            label: "Password"
                            placeholderText: "Choose a password"
                            validationType: "password"
                            masked: true
                            required: true
                        }

                        AppTextInput {
                            label: "Confirm Password"
                            placeholderText: "Re-enter password"
                            masked: true
                            required: true
                            validator: function(value) {
                                return value === passwordField.text || "Passwords do not match"
                            }
                        }

                        AppPhoneInput {
                            label: "Phone Number"
                            required: true
                        }

                        onAccepted: console.log("Form submitted OK")
                        onRejected: (errors) => console.log("Form has", errors.length, "error(s)")
                    }

                    Button {
                        text: "Submit"
                        onClicked: testForm.submit()
                    }
                }

                Rectangle { width: parent.width; height: 1; color: ThemeManager.borderDefault }

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 14
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "subtitle"; text: "Step 7 — Actions & Menus (batch 1 of 2)" }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 16

                        IconButton { iconName: "settings"; onClicked: console.log("Settings clicked") }

                        ButtonGroup {
                            IconButton { iconName: "grid" }
                            IconButton { iconName: "list_bulleted" }
                        }

                        SplitButton {
                            text: "Save"
                            variant: "primary"
                            onClicked: console.log("Save clicked")
                            menuItems: [
                                { label: "Save As...", onTriggered: function() { console.log("Save As") } },
                                { label: "Save a Copy", iconName: "close", onTriggered: function() { console.log("Save a Copy") } }
                            ]
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 16

                        Card {
                            id: contextTestCard
                            title: "Right-click me"
                            Text {
                                text: "Left-click should still work too"
                                color: ThemeManager.textSecondary
                                font.family: "Poppins"
                                font.pixelSize: 13
                            }
                            onClicked: console.log("Card left-clicked normally")

                            ContextMenu {
                                attachedTo: contextTestCard
                                items: [
                                    { label: "Rename", onTriggered: function() { console.log("Rename") } },
                                    { label: "Delete", iconName: "close", onTriggered: function() { console.log("Delete") } }
                                ]
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: ThemeManager.borderDefault }

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 14
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "subtitle"; text: "Step 7 — Menu Bar" }

                    MenuBar {
                        width: 400
                        menus: [
                            { label: "File", mnemonic: "F", items: [
                                { label: "New Project", onTriggered: function() { console.log("New Project") } },
                                { label: "Open...", onTriggered: function() { console.log("Open") } }
                            ]},
                            { label: "Edit", mnemonic: "E", items: [
                                { label: "Undo", onTriggered: function() { console.log("Undo") } },
                                { label: "Redo", onTriggered: function() { console.log("Redo") } }
                            ]},
                            { label: "View", mnemonic: "V", items: [
                                { label: "Zoom In", onTriggered: function() { console.log("Zoom In") } },
                                { label: "Zoom Out", onTriggered: function() { console.log("Zoom Out") } }
                            ]}
                        ]
                    }
                }
                Rectangle { width: parent.width; height: 1; color: ThemeManager.borderDefault }

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 20
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "subtitle"; text: "Step 8 — Navigation" }

                    Tabs {
                        id: navTabs
                        model: [{ label: "Overview" }, { label: "Files" }, { label: "Settings", iconName: "settings" }]
                    }

                    Breadcrumbs {
                        model: ["Dashboard", "Projects", "Website Redesign"]
                        onCrumbClicked: (i) => console.log("Breadcrumb", i)
                    }

                    Pagination {
                        totalPages: 12
                        currentPage: 5
                        onPageChanged: (p) => console.log("Page", p)
                    }

                    Stepper {
                        width: 320
                        currentIndex: 1
                        steps: ["Account", "Details", "Confirm"]
                    }

                    Accordion {
                        width: 320
                        AccordionSection {
                            title: "Project Details"
                            expanded: true
                            AppText { text: "Basic info goes here." }
                        }
                        AccordionSection {
                            title: "Advanced Settings"
                            AppCheckbox { text: "Enable notifications" }
                        }
                    }

                    AppTreeView {
                        width: 260
                        model: [
                            { label: "Website Redesign", iconName: "folder", expanded: true, children: [
                                { label: "Homepage" },
                                { label: "Assets", children: [
                                    { label: "logo.svg" }
                                ]}
                            ]},
                            { label: "Mobile App", iconName: "folder" }
                        ]
                        onNodeClicked: (n) => console.log("Clicked", n.label)
                    }
                }
                Rectangle { width: parent.width; height: 1; color: ThemeManager.borderDefault }

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 20
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "subtitle"; text: "Step 9 — Transient Overlays" }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 40

                        IconButton {
                            id: tooltipBtn
                            iconName: "settings"
                            Tooltip { anchorItem: tooltipBtn; text: "Settings" }
                        }

                        IconButton {
                            id: popoverBtn
                            iconName: "grid"
                            onClicked: quickPopover.open()
                            Popover {
                                id: quickPopover
                                anchorItem: popoverBtn
                                AppText { text: "Quick settings"; variant: "subtitle" }
                                AppSwitch { text: "Dark mode" }
                            }
                        }

                        Button {
                            text: "Open Drawer"
                            onClicked: testDrawer.open()
                        }

                        IconButton {
                            id: coachmarkBtn
                            iconName: "checkmark"
                            onClicked: testCoachmark.visible = !testCoachmark.visible
                        }
                    }

                    Coachmark {
                        id: testCoachmark
                        anchorItem: coachmarkBtn
                        side: "bottom"
                        visible: false
                        title: "New: Quick Actions"
                        body: "Click here anytime to jump to your recent items."
                        step: 2
                        totalSteps: 4
                        onNext: console.log("Coachmark next")
                        onDismissed: testCoachmark.visible = false
                    }
                }
                Rectangle { width: parent.width; height: 1; color: ThemeManager.borderDefault }

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 20
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "subtitle"; text: "Step 10 — Feedback & Status" }

                    ProgressBar { width: 260; value: 0.65 }
                    ProgressBar { width: 260; indeterminate: true }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 24
                        Spinner { size: 28 }
                        StatusDot { status: "success" }
                        StatusDot { status: "error"; pulse: true }
                        StatusDot { status: "pending"; pulse: true }
                    }

                    InlineAlert {
                        width: 320
                        variant: "success"
                        text: "Project saved successfully."
                        dismissible: true
                    }

                    InlineAlert {
                        width: 320
                        variant: "error"
                        text: "Failed to sync — check your connection and try again."
                    }

                    EmptyState {
                        useIllustration: true
                        title: "No projects yet"
                        body: "Create your first project to get started."
                        actionText: "New Project"
                        onActionClicked: console.log("New Project clicked")
                    }
                }
                Rectangle { width: parent.width; height: 1; color: ThemeManager.borderDefault }

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 20
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "subtitle"; text: "Step 11 — Data Display" }

                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "caption"; text: "StatTile -- count-up + tile-flip test" }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 16

                        StatTile {
                            label: "Count-Up Test"
                            value: window.demoCountUpValue.toString()
                        }

                        StatTile {
                            label: "Hover Me"
                            value: "42"
                            backContent: Component {
                                AppText { text: "Flipped!"; anchors.centerIn: parent; color: ThemeManager.textPrimary }
                            }
                        }

                        Button {
                            text: "Bump Count-Up Value"
                            onClicked: window.demoCountUpValue = (window.demoCountUpValue === 24 ? 87 : 24)
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 24

                        Avatar { name: "Priya Nair"; size: 40 }
                        AvatarGroup {
                            people: [
                                { name: "Priya Nair" }, { name: "Rahul Verma" },
                                { name: "Aditi Sharma" }, { name: "Sanjay Gupta" }
                            ]
                            maxVisible: 3
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 16
                        StatTile { label: "Active Projects"; value: "24" }
                        StatTile { label: "Active Projects"; value: "24"; variant: "featured" }
                        StatTile { label: "Monthly Revenue"; value: "₹45,00,000"; trend: "up"; trendText: "+12% vs last month" }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8
                        RemovableTag { text: "Status: Active"; onRemoved: console.log("removed status") }
                        RemovableTag { text: "Owner: Priya"; onRemoved: console.log("removed owner") }
                    }

                    List {
                        width: 320
                        ListItem {
                            title: "Website Redesign"
                            subtitle: "Updated 2 hours ago"
                            leading: Avatar { name: "Priya Nair"; size: 32 }
                            trailing: StatusDot { status: "success" }
                        }
                        ListItem {
                            title: "Mobile App"
                            subtitle: "Updated yesterday"
                            leading: Avatar { name: "Rahul Verma"; size: 32 }
                            trailing: StatusDot { status: "pending"; pulse: true }
                        }
                    }

                    Timeline {
                        width: 320
                        items: [
                            { time: "09:17 AM", title: "Project created", body: "by Priya Nair" },
                            { time: "10:30 AM", title: "First task added" },
                            { time: "02:48 PM", title: "Status changed to Active", current: true }
                        ]
                    }

                    KeyValue {
                        width: 320
                        items: [
                            { key: "Owner", value: "Priya Nair" },
                            { key: "Created", value: "06/08/2026" },
                            { key: "Status", value: "Active" }
                        ]
                    }

                    Divider { width: 200 }
                }
                Rectangle { width: parent.width; height: 1; color: ThemeManager.borderDefault }

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 20
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "subtitle"; text: "Step 12 — Charts" }

                    LineChart {
                        width: 300; height: 160
                        chartData: [12, 19, 8, 25, 30, 22, 28]
                        labels: ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
                    }

                    BarChart {
                        width: 300; height: 160
                        chartData: [45, 72, 88, 33, 60]
                        labels: ["Website", "Mobile", "API", "Pipeline", "Docs"]
                    }

                    DonutChart {
                        width: 140; height: 140
                        centerLabel: "35"
                        chartData: [
                            { label: "Active", value: 24, color: ThemeManager.statusSuccess },
                            { label: "Pending", value: 8 },
                            { label: "Blocked", value: 3, color: ThemeManager.statusError }
                        ]
                    }

                    Sparkline { width: 80; height: 24; chartData: [3,5,4,7,6,9,8] }
                }
                Rectangle { width: parent.width; height: 1; color: ThemeManager.borderDefault }

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 20
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "subtitle"; text: "Step 13 — OS Window Chrome" }
                    AppText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        variant: "caption"
                        text: "TitleBar + ResizeBorders live at the real Window root above — not repeated here."
                    }

                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "caption"; text: "Toolbar" }
                    Toolbar {
                        width: 360
                        IconButton { iconName: "folder" }
                        IconButton { iconName: "upload" }
                        // NOTE: assumes Divider.qml exposes an "orientation" property ("vertical"/
                        // "horizontal") — not verified against Divider.qml's actual source, only
                        // against the existing horizontal Divider usage elsewhere in this file.
                        // Flag if this property name doesn't exist.
                        Divider { orientation: "vertical"; height: ThemeManager.controlHeight }
                        IconButton { iconName: "settings" }
                    }

                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "caption"; text: "StatusBar" }
                    StatusBar {
                        width: 360
                        StatusDot { status: "success" }
                        AppText { text: "Connected"; variant: "caption" }
                        rightContent: [
                            AppText { text: "Ln 12, Col 4"; variant: "caption" },
                            AppText { text: "100%"; variant: "caption" }
                        ]
                    }

                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "caption"; text: "SplitPane" }
                    SplitPane {
                        width: 360
                        height: 160
                        orientation: "horizontal"
                        first: Rectangle {
                            color: ThemeManager.backgroundPanel
                            AppText { anchors.centerIn: parent; text: "First pane" }
                        }
                        second: Rectangle {
                            color: ThemeManager.backgroundSurface
                            AppText { anchors.centerIn: parent; text: "Second pane" }
                        }
                    }

                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "caption"; text: "Panel (Featured)" }
                    Panel {
                        width: 360
                        title: "Featured Summary"
                        variant: "featured"
                        AppText {
                            text: "Body content re-colored manually -- Panel's featured variant only themes its own chrome."
                            color: "#FFFFFF"
                            wrapMode: Text.WordWrap
                            width: 300
                        }
                    }

                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "caption"; text: "Panel / Group-box" }
                    Panel {
                        width: 360
                        title: "Details"
                        trailingContent: IconButton { iconName: "settings" }
                        AppText { text: "Basic project info goes here." }
                        AppText { text: "Second line of content."; variant: "caption" }
                    }

                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "caption"; text: "LayoutStack" }
                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8

                        LayoutStack {
                            id: demoStack
                            width: 360
                            height: 80
                            currentIndex: 0
                            Rectangle { color: ThemeManager.accentPrimary; AppText { anchors.centerIn: parent; text: "Panel A"; color: "#FFFFFF" } }
                            Rectangle { color: ThemeManager.statusSuccess; AppText { anchors.centerIn: parent; text: "Panel B"; color: "#FFFFFF" } }
                            Rectangle { color: ThemeManager.statusError; AppText { anchors.centerIn: parent; text: "Panel C"; color: "#FFFFFF" } }
                        }
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 8
                            Button { text: "A"; onClicked: demoStack.currentIndex = 0 }
                            Button { text: "B"; onClicked: demoStack.currentIndex = 1 }
                            Button { text: "C"; onClicked: demoStack.currentIndex = 2 }
                        }
                    }

                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "caption"; text: "LayoutGrid" }
                    LayoutGrid {
                        width: 360
                        columns: 3
                        cellHeight: 64
                        Rectangle { color: ThemeManager.backgroundPanel; border.width: 1; border.color: ThemeManager.borderDefault; AppText { anchors.centerIn: parent; text: "1" } }
                        Rectangle { color: ThemeManager.backgroundPanel; border.width: 1; border.color: ThemeManager.borderDefault; AppText { anchors.centerIn: parent; text: "2" } }
                        Rectangle { color: ThemeManager.backgroundPanel; border.width: 1; border.color: ThemeManager.borderDefault; AppText { anchors.centerIn: parent; text: "3" } }
                        Rectangle { color: ThemeManager.backgroundPanel; border.width: 1; border.color: ThemeManager.borderDefault; AppText { anchors.centerIn: parent; text: "4" } }
                        Rectangle { color: ThemeManager.backgroundPanel; border.width: 1; border.color: ThemeManager.borderDefault; AppText { anchors.centerIn: parent; text: "5" } }
                    }

                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "caption"; text: "ScrollArea" }
                    ScrollArea {
                        width: 360
                        height: 120
                        contentWidth: width
                        contentHeight: scrollDemoColumn.height

                        Column {
                            id: scrollDemoColumn
                            width: parent.width
                            spacing: 8
                            Repeater {
                                model: 10
                                delegate: AppText { text: "Scrollable row " + (index + 1) }
                            }
                        }
                    }
                }
            }
        }
    }
}


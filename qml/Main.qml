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

    property bool showIconGallery: false

    Loader {
        anchors.fill: parent
        sourceComponent: window.showIconGallery ? galleryComponent : mainComponent
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
                            title: "Zone 3 — AHU Status"
                            Text {
                                text: "Online, 21°C"
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
                            { key: "zone", title: "Zone" },
                            { key: "temp", title: "Temp (°C)", numeric: true, decimals: 1 },
                            { key: "cost", title: "Monthly Cost", numeric: true, currency: true }
                        ]
                        rows: [
                            { zone: "Zone 1 — Lobby", temp: 21.5, cost: 4500000 },
                            { zone: "Zone 2 — Server Room", temp: 18.2, cost: 12300000 },
                            { zone: "Zone 3 — Office East", temp: 23.1, cost: 3800000 },
                            { zone: "Zone 4 — Office West", temp: 22.8, cost: 3950000 }
                        ]
                        onRowClicked: (rowData) => console.log("Clicked:", rowData.zone)
                    }
                }
            
                Rectangle { width: parent.width; height: 1; color: ThemeManager.borderDefault }

                // ---------- AppTextInput ----------
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 14
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "subtitle"; text: "AppTextInput" }

                    AppTextInput {
                        label: "Zone Name"
                        placeholderText: "Enter zone name"
                        helperText: "Shown to technicians on the maintenance queue"
                    }

                    AppTextInput {
                        label: "Zone Name (error)"
                        placeholderText: "Enter zone name"
                        validationState: "error"
                        errorMessage: "Zone name is required"
                        text: ""
                    }

                    AppTextInput {
                        label: "Zone Name (success)"
                        text: "Zone 3 — Office East"
                        validationState: "success"
                        helperText: "Looks good"
                    }

                    AppTextInput {
                        label: "Zone Name (disabled)"
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
            }
        }
    }
}
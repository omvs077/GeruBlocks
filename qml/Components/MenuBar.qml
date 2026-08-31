import QtQuick
import QtQml
import GeruBlocks

// MenuBar — Step 7 Actions & Menus (v2 — real bug fix)
//
// BUG FIXED: the Alt+<letter> mnemonic block originally used a
// Repeater to generate Shortcut objects. Repeater requires visual
// Item-derived delegates -- Shortcut is a non-visual QtObject (same
// category as Timer/Connections), so Qt silently skipped creating every
// one of them rather than crashing ("Delegate must be of Item type").
// This meant Alt+F/E/V never actually existed at runtime, even though
// the visual bar (labels, underlines, hover, click-to-open) worked fine
// the whole time and looked confirmed. The correct QML tool for
// "repeat a non-visual object per model entry" is Instantiator, not
// Repeater -- swapped below.
//
// Top-level File/Edit/View-style bar. Reuses DropdownMenu.qml under
// each top-level entry for the actual menu contents (same item format,
// same visual styling) rather than reimplementing menu rendering a
// third time.
//
// COORDINATED OPEN STATE: only one top-level menu open at a time.
// Clicking an entry opens/closes it; while ANY menu is already open,
// hovering a sibling entry switches to that sibling's menu immediately.
// Tracked as root._openIndex (only the parent can correctly arbitrate
// "only one open at once", not each item independently).
//
// NAMING NOTE: the per-entry computed property is `menuOpen`, not
// `_isOpen` -- deliberately avoiding a leading underscore on anything
// used as an onXChanged target, per this project's own documented
// on_xChanged vs on_XChanged casing-trap lesson (DatePicker session).
//
// MNEMONICS: each entry takes a `mnemonic` letter (e.g. "F" for File).
// Alt+<letter> opens that menu from anywhere in the window; the letter
// is auto-underlined in the label (first case-insensitive match) via
// rich text.
//
// PLATFORM RISK, STILL FLAGGED, STILL NOT VERIFIED: on native Windows
// chrome, a bare Alt press sometimes triggers the OS's own menu-focus
// behavior before Qt sees Alt+<letter> as a combined shortcut. Now that
// the Shortcut objects actually exist (this fix), worth testing whether
// they fire at all.
//
// Usage:
//   MenuBar {
//       menus: [
//           { label: "File", mnemonic: "F", items: [
//               { label: "New", onTriggered: function() { ... } },
//               { label: "Open...", onTriggered: function() { ... } }
//           ]},
//           { label: "Edit", mnemonic: "E", items: [ ... ] },
//           { label: "View", mnemonic: "V", items: [ ... ] }
//       ]
//   }

Rectangle {
    id: root

    // [{ label, mnemonic, items: [...] }]
    property var menus: []
    property int _openIndex: -1

    width: parent ? parent.width : 300
    implicitHeight: ThemeManager.controlHeight
    color: ThemeManager.backgroundSurface

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: ThemeManager.borderDefault
    }

    Row {
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: root.menus

            Item {
                id: entry
                width: label.implicitWidth + ThemeManager.spacing24
                height: root.height

                readonly property int menuIndex: index
                readonly property bool menuOpen: root._openIndex === menuIndex

                onMenuOpenChanged: {
                    if (menuOpen) dropdown.open()
                    else dropdown.close()
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 0
                    color: entry.menuOpen || hoverArea.containsMouse ? ThemeManager.backgroundPage : "transparent"
                }

                Text {
                    id: label
                    anchors.centerIn: parent
                    textFormat: Text.RichText
                    text: {
                        var raw = modelData.label
                        var mnem = modelData.mnemonic
                        if (!mnem) return raw
                        var i = raw.toLowerCase().indexOf(mnem.toLowerCase())
                        if (i === -1) return raw
                        return raw.substring(0, i) + "<u>" + raw.substring(i, i + 1) + "</u>" + raw.substring(i + 1)
                    }
                    font.family: "Poppins"
                    font.pixelSize: 14
                    color: ThemeManager.textPrimary
                }

                MouseArea {
                    id: hoverArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root._openIndex = entry.menuOpen ? -1 : entry.menuIndex
                    onEntered: {
                        if (root._openIndex !== -1 && root._openIndex !== entry.menuIndex) {
                            root._openIndex = entry.menuIndex
                        }
                    }
                }

                DropdownMenu {
                    id: dropdown
                    anchorItem: entry
                    items: modelData.items !== undefined ? modelData.items : []
                    onClosed: if (root._openIndex === entry.menuIndex) root._openIndex = -1
                }
            }
        }
    }

    // FIX: Instantiator, not Repeater -- see header note. Instantiator
    // is the correct QML tool for creating a non-visual object per
    // model entry.
    Instantiator {
        model: root.menus

        Shortcut {
            sequence: modelData.mnemonic ? "Alt+" + modelData.mnemonic : ""
            enabled: modelData.mnemonic !== undefined && modelData.mnemonic !== ""
            onActivated: root._openIndex = index
        }
    }
}

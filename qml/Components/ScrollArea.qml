import QtQuick
import GeruBlocks

// Geru Blocks — ScrollArea.qml (Step 13)
//
// Wraps Flickable with a real Scrollbar component (see Scrollbar.qml) --
// previously this had its own inline duplicated thumb/track code; that
// logic is now extracted into a standalone, reusable, draggable
// Scrollbar so other components with their own Flickable can share it
// instead of re-implementing scrollbar math per-file.
//
// scrollbarStyle defaults to "overlay", matching this component's
// original minimal-chrome look exactly -- backward compatible, no
// breaking change for existing usage. Pass "inline" for a persistent,
// slightly thicker scrollbar in contexts where always-visible affordance
// matters more (see Scrollbar.qml header for the full style rationale).
//
// clip: true is required at the root (Section 5, bug #9) since scrolled
// content genuinely moves outside the visible viewport bounds.
//
// Content is added through Flickable's own default property,
// `flickableData` (NOT `data` -- Flickable redefines its default
// property specifically so declared children are correctly parented
// under its internal contentItem). Aliasing to a name other than `data`
// keeps this safe per Section 5 bug #1 (never redeclare a property
// literally named `data`).
//
// Usage:
//   ScrollArea {
//       width: 300; height: 400
//       contentWidth: width
//       contentHeight: innerColumn.height
//       scrollbarStyle: "inline"   // optional, defaults to "overlay"
//       Column { id: innerColumn; width: parent.width; /* long content */ }
//   }

Item {
    id: root
    default property alias content: flickable.flickableData
    property alias contentWidth: flickable.contentWidth
    property alias contentHeight: flickable.contentHeight
    property string scrollbarStyle: "overlay"   // "overlay" | "inline" -- see Scrollbar.qml
    clip: true

    Flickable {
        id: flickable
        anchors.fill: parent
        clip: true
        boundsBehavior: Flickable.StopAtBounds
    }

    Scrollbar {
        flickable: flickable
        orientation: "vertical"
        style: root.scrollbarStyle
    }

    Scrollbar {
        flickable: flickable
        orientation: "horizontal"
        style: root.scrollbarStyle
    }
}

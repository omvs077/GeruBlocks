import QtQuick

// Geru Blocks — Panel.qml (Step 13, "Panel/group-box" line item)
//
// PROPOSAL: implemented as a bordered box with an optional header row above the content
// (title + optional trailing action slot), rather than the classic HTML <fieldset>
// "legend cut into the border line" style. The cut-in-border look doesn't read well with
// fully sharp corners and a plain 1px hairline border, and a solid header row above the
// content matches the rest of the system's Card/Panel conventions more closely. Flag if
// the classic cut-border look is actually wanted instead.
//
// Positioning note: header and content are positioned with explicit x/y, not nested inside
// a Column — a Column-managed child cannot itself use anchors/margins on ITS children
// without fighting the positioner, so content sits in a plain Item sized/offset directly.
//
// PADDING (backlog 1d, "Card/Panel padding audit"): bumped from spacing16 to spacing24
// throughout — header margins and body content both, so the title and body content stay
// flush on the same left edge. Uses an already-existing token on the locked 4px scale,
// no new token introduced.
//
// FEATURED VARIANT (backlog 1e, signed off): variant: "featured" re-themes the panel's
// own CHROME (outer fill, header divider, title/trailing text color) to a solid
// accentPrimary surface. This is CHROME-ONLY, not automatic content recoloring — Panel's
// body is an open default-property slot for arbitrary caller content (AppText,
// AppCheckbox, whatever), and unlike StatTile (which owns its label/value text directly),
// Panel has no way to know what's inside that slot or safely repaint it. If you use
// variant: "featured", check that whatever you put inside the body reads correctly
// against a solid accent background — override colors on your own content as needed,
// same as any other slot-based container (Card's body slot works the same way today).
//
// Usage:
//   Panel {
//       title: "Details"
//       AppText { text: "Some content" }
//       AppText { text: "More content" }
//       trailingContent: IconButton { icon: "settings" }
//   }
//   Panel {
//       title: "Featured Summary"
//       variant: "featured"
//       AppText { text: "Remember to re-color body content yourself"; color: "#FFFFFF" }
//   }

Item {
    id: root

    property string title: ""
    property string variant: "default"  // "default" | "featured"
    default property alias content: contentColumn.data
    property alias trailingContent: trailingRow.data

    readonly property bool isFeatured: variant === "featured"
    readonly property real headerHeight: root.title.length > 0 ? ThemeManager.controlHeight : 0

    width: parent ? parent.width : 300
    implicitHeight: headerHeight + contentColumn.height + (ThemeManager.spacing24 * 2)

    Rectangle {
        anchors.fill: parent
        color: root.isFeatured ? ThemeManager.accentPrimary : ThemeManager.backgroundSurface
        border.width: root.isFeatured ? 0 : 1
        border.color: ThemeManager.borderDefault
    }

    Item {
        id: headerRow
        x: 0
        y: 0
        width: parent.width
        height: root.headerHeight
        visible: root.title.length > 0

        // Divider is dropped when featured -- a hairline in borderDefault
        // (a light-neutral tone) would have near-zero contrast against a
        // solid accentPrimary fill, and a solid color block reads as its
        // own unit without needing an internal seam.
        Rectangle {
            visible: !root.isFeatured
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: ThemeManager.borderDefault
        }

        AppText {
            text: root.title
            variant: "subtitle"
            color: root.isFeatured ? "#FFFFFF" : ThemeManager.textPrimary
            anchors.left: parent.left
            anchors.leftMargin: ThemeManager.spacing24
            anchors.verticalCenter: parent.verticalCenter
        }

        Row {
            id: trailingRow
            anchors.right: parent.right
            anchors.rightMargin: ThemeManager.spacing24
            anchors.verticalCenter: parent.verticalCenter
            spacing: ThemeManager.spacing8
        }
    }

    Column {
        id: contentColumn
        x: ThemeManager.spacing24
        y: headerRow.height + ThemeManager.spacing24
        width: parent.width - ThemeManager.spacing24 * 2
        spacing: ThemeManager.spacing8
    }
}

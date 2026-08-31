import QtQuick
import GeruBlocks

// InlineAlert — Step 10 Feedback & Status ("Inline alert/banner" in
// the spec's component list)
//
// COLOR GAP, FLAGGED, NOT DECIDED FOR YOU: only 3 variants exist --
// "info" (accentPrimary), "success" (statusSuccess), "error"
// (statusError) -- because those are the only semantic colors actually
// locked in Section 3.1. A 4th "warning" variant is conventional for
// this component type, but accent orange is explicitly locked as
// "tags, urgent badges, warning icons ONLY -- NEVER a UI surface"
// (Governance Principle 4), and an alert banner's fill/border IS a UI
// surface. Rather than quietly break that lock or invent an unlocked
// color myself, "warning" is simply not built. Needs your call: accept
// orange as a deliberate documented exception (would mean amending
// Section 2's principle), pick a different color for it, or decide 3
// variants is enough and route warning-severity messages through
// "error" in practice.
//
// ICON NAME FLAGGED, NOT FULLY VERIFIED: uses "info" for the info
// variant. "Info" is listed in the spec's original Batch 2 icon
// inventory (Section 4.2), so it's very likely real, but it's not on
// this project's own "confirmed successfully used" icon list the way
// checkmark/close are -- worth a quick existence check before trusting
// it blindly, same standing caution as always with icon names.
//
// LAYOUT NOTE: uses anchors (icon anchored left, text anchored between
// icon and dismiss button, dismiss button anchored right) rather than
// a Row with a manually-subtracted width -- same fix already applied
// to Coachmark.qml's footer row this session, not repeating that
// magic-number pattern here.
//
// Usage:
//   InlineAlert {
//       variant: "success"
//       text: "Project saved successfully."
//       dismissible: true
//       onDismissed: banner.visible = false
//   }

Item {
    id: root
    property string variant: "info"  // "info" | "success" | "error"
    property string text: ""
    property bool dismissible: false
    signal dismissed()

    implicitWidth: 320
    implicitHeight: contentRow.height + ThemeManager.spacing12 * 2

    readonly property color _accentColor: {
        if (variant === "success") return ThemeManager.statusSuccess
        if (variant === "error") return ThemeManager.statusError
        return ThemeManager.accentPrimary
    }

    Rectangle {
        anchors.fill: parent
        radius: 0
        color: Qt.rgba(root._accentColor.r, root._accentColor.g, root._accentColor.b, 0.08)
        border.width: 1
        border.color: root._accentColor

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 3
            color: root._accentColor
        }
    }

    Item {
        id: contentRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: ThemeManager.spacing16
        anchors.rightMargin: ThemeManager.spacing12
        height: Math.max(alertIcon.height, alertText.implicitHeight, root.dismissible ? dismissBtn.height : 0, 20)

        Icon {
            id: alertIcon
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            name: root.variant === "success" ? "checkmark" : (root.variant === "error" ? "close" : "info")
            size: 16
            color: root._accentColor
        }

        AppText {
            id: alertText
            anchors.left: alertIcon.right
            anchors.leftMargin: ThemeManager.spacing8
            anchors.right: root.dismissible ? dismissBtn.left : parent.right
            anchors.rightMargin: root.dismissible ? ThemeManager.spacing8 : 0
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            wrapMode: Text.WordWrap
        }

        IconButton {
            id: dismissBtn
            visible: root.dismissible
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            iconName: "close"
            iconSize: 12
            variant: "ghost"
            onClicked: root.dismissed()
        }
    }
}

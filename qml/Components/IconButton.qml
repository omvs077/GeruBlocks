import QtQuick
import QtQuick.Controls.Basic as Basic
import GeruBlocks

// IconButton — Step 7 Actions & Menus
//
// Icon-only button. Reuses Button.qml's press/hover overlay math exactly
// (12%/20% overlay opacity, 0.97 scale on press, system easing curve)
// rather than reinventing it — the spec's state recipe (3.6) is one
// system-wide rule, not a per-component decision.
//
// GLYPH FALLBACK, DELIBERATE: supports either `iconName` (one of the
// 252 icons) or a plain-text `glyph` (e.g. "\u25BC") as an alternative.
// Reason: several needed glyphs (chevron_down/up specifically) aren't
// on the confirmed-existing icon list from past sessions, and this
// project's own lesson is "don't guess icon names — they render blank
// with no error." Select.qml already established a text-glyph fallback
// for exactly this case (its ▲/▼ indicator); this generalizes that same
// precedent rather than inventing a new pattern. Set `iconName` once a
// real chevron icon name is confirmed and `glyph` becomes unnecessary.
//
// ASSUMPTION FLAGGED: sized to ThemeManager.controlHeight square (32px)
// by default — not spec-stated explicitly for icon-only buttons, chosen
// to align with regular Buttons in a shared toolbar row.
//
// Usage:
//   IconButton { iconName: "settings"; onClicked: openSettings() }
//   IconButton { glyph: "\u25BC"; variant: "ghost" }   // unconfirmed-icon fallback

Basic.Button {
    id: root

    property string iconName: ""
    property string glyph: ""
    property int iconSize: 20
    // "ghost" | "primary" — only these two variants are meaningful for
    // an icon-only control (no bordered "secondary" look was asked for)
    property string variant: "ghost"

    hoverEnabled: true
    implicitWidth: ThemeManager.controlHeight
    implicitHeight: ThemeManager.controlHeight

    readonly property color _iconColor: {
        if (!enabled) return ThemeManager.textSecondary
        if (variant === "primary") return "#FFFFFF"
        return ThemeManager.textPrimary
    }

    readonly property color _overlayColor: root.pressed ? "#000000" : "#FFFFFF"
    readonly property real _overlayOpacity: {
        if (!enabled) return 0
        if (root.pressed) return 0.20
        if (root.hovered) return 0.12
        return 0
    }

    scale: enabled && root.pressed ? 0.97 : 1.0
    Behavior on scale {
        NumberAnimation {
            duration: ThemeManager.durationMicro
            easing.type: Easing.BezierSpline
            easing.bezierCurve: ThemeManager.easingCurve
        }
    }

    background: Rectangle {
        radius: 0
        color: root.variant === "primary"
                ? (root.enabled ? ThemeManager.accentPrimary : ThemeManager.borderStrong)
                : "transparent"

        Rectangle {
            anchors.fill: parent
            radius: 0
            color: root.variant === "primary" ? root._overlayColor : ThemeManager.accentPrimary
            opacity: root._overlayOpacity
            Behavior on opacity {
                NumberAnimation {
                    duration: ThemeManager.durationMicro
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: ThemeManager.easingCurve
                }
            }
        }
    }

    contentItem: Item {
        implicitWidth: root.iconSize
        implicitHeight: root.iconSize

        Icon {
            anchors.centerIn: parent
            visible: root.iconName !== ""
            name: root.iconName
            size: root.iconSize
            color: root._iconColor
        }

        Text {
            anchors.centerIn: parent
            visible: root.iconName === "" && root.glyph !== ""
            text: root.glyph
            color: root._iconColor
            font.pixelSize: root.iconSize
        }
    }
}

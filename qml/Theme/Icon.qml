import QtQuick
import QtQuick.Effects
import GeruBlocks

// Icon — Geru Blocks Stage 2 Foundation
//
// Reusable themed icon component. Renders one of the 252 SVGs from
// assets/icons/ and recolors it at runtime via MultiEffect ALPHA MASKING
// (not "colorization" — see note below), so a single flat black-stroke
// source file can be tinted to any ThemeManager color (text, accent,
// status) without needing per-theme icon variants on disk.
//
// CORRECTED APPROACH — colorization vs. masking:
// The first version of this component used MultiEffect's `colorization`
// property, which turned out not to work: colorization is a multiplicative
// tint meant for recoloring already-colored images, and multiplying a
// black source pixel (0,0,0) by any tint color mathematically still
// yields black. Since every icon's opaque pixels are pure black, nothing
// visibly changed regardless of the target color — confirmed by testing
// on-device rather than assumed.
//
// The correct technique is masking: draw a plain solid-color Rectangle
// (colorFill) and use the icon's rendered alpha channel (via maskSource)
// as a stencil that reveals it. This only depends on the icon's
// transparency, never its original fill/stroke color, so it works
// identically whether an icon is stroke-based, solid-filled (the Cloud
// family), or even a text glyph (Underline) — all per Ommy's confirmed
// final edits.
//
// Usage:
//   Icon { name: "home"; size: 24; color: ThemeManager.textPrimary }
//   Icon { name: "warning"; size: 20; color: ThemeManager.statusError }

Item {
    id: root

    // Icon file name, without extension, e.g. "home", "chevron_down".
    // Resolves to qrc:/icons/<name>.svg — all 252 icons live flat in one
    // folder (verified no filename collisions across the original
    // category groupings before flattening).
    property string name: ""

    // Rendered size in px. Default 24 matches the icon canvas size the
    // whole set was designed at (Section 3.3's 4px base grid, fits
    // inside the 32px standard control height with room to spare).
    property int size: 24

    // Tint color. Defaults to the current theme's primary text color;
    // override for accent/status contexts, e.g. color: ThemeManager.accentPrimary
    property color color: ThemeManager.textPrimary

    implicitWidth: size
    implicitHeight: size

    // The icon's rasterized alpha shape — used ONLY as a mask, its own
    // color is irrelevant since maskSource only reads the alpha channel.
    // Rendered at 4x the display size (supersampling) so downscaling
    // smooths jagged edges, since mask edges are hard-cut by default and
    // an attempt to soften them via maskSpreadAtMin/Max instead broke
    // masking entirely on-device — reverted that, using supersampling
    // instead since it doesn't touch mask behavior at all.
    Image {
        id: sourceImage
        anchors.fill: parent
        source: root.name !== "" ? "qrc:/icons/" + root.name + ".svg" : ""
        sourceSize.width: root.size * 4
        sourceSize.height: root.size * 4
        smooth: true
        mipmap: true
        visible: false
        cache: true
    }

    // The actual color that gets shown, masked to the icon's silhouette.
    Rectangle {
        id: colorFill
        anchors.fill: parent
        color: root.color
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: colorFill
        maskEnabled: true
        maskSource: sourceImage
        // Mask edges are hard-cut by default. Setting spread alone
        // (without threshold) previously broke masking entirely on this
        // project — turned every icon into a solid filled square — so
        // this exact pairing is taken from a confirmed-working Qt Forum
        // report and Qt's own "Qt Quick and Blurred Panels" blog post,
        // not guessed: https://forum.qt.io/topic/145956
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
        antialiasing: true
    }
}

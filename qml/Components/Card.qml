import QtQuick
import QtQuick.Controls.Basic as Basic
import GeruBlocks

// Card — Step 2 Typography & Core Primitives
//
// Clickable content container with the "reveal highlight" hover effect
// from spec Section 3.6: "a soft radial glow tracks the cursor position
// within the element (Windows 10's signature 'Reveal' effect, rebuilt
// originally)."
//
// HOW THE GLOW WORKS: QML's built-in Rectangle gradient is linear-only,
// and a true cursor-tracked radial effect needs a real radial falloff.
// Rather than reach for the deprecated Qt5Compat.GraphicalEffects
// RadialGradient module, or write a custom shader for something this
// central, this uses a pre-rendered soft radial-glow PNG
// (assets/textures/glow.png) positioned live at the mouse coordinates
// within the card and clipped to its bounds — same resource-pipeline
// pattern already used for fonts and icons in this project, not a
// one-off inline hack.
//
// Extends QQC2's Button (not a bare Item+MouseArea) for the same
// accessibility/keyboard-focus reason as Button.qml — Card is
// confirmed-clickable per your direction, so it needs real interactive
// semantics, not just visual click handling.
//
// ASSUMED SLOT STRUCTURE, FLAGGED FOR YOUR CONFIRMATION: "defined slots"
// was the direction given, but a fully rigid schema (e.g. title must be
// exactly one Text element) would make Card unusable for the wildly
// different content real cards will hold (KPI tiles, list previews,
// status summaries). This implements a hybrid: `title` as a simple
// convenience string (covers the common case), a flexible default
// `body` slot for arbitrary child content, and an optional `footer`
// Component slot (for action buttons/links at the bottom). If you meant
// something more rigid, tell me and I'll rebuild the API.
//
// Usage:
//   Card {
//       title: "Zone 3 — AHU Status"
//       Text { text: "Online, 21°C"; color: ThemeManager.textSecondary }
//       footer: Component {
//           Link { text: "View details" }
//       }
//       onClicked: console.log("card clicked")
//   }

Basic.Button {
    id: root

    // Simple convenience title — covers the common case without forcing
    // every card to build its own heading manually.
    property string title: ""

    // Body content: whatever the caller puts as children goes here.
    default property alias body: bodyColumn.data

    // Optional footer, e.g. actions/links. Instantiated only if provided.
    property Component footer: null

    hoverEnabled: true
    padding: ThemeManager.spacing24  // bumped from spacing16, backlog 1d -- cards read slightly tight
    implicitWidth: 280
    implicitHeight: contentColumn.implicitHeight + padding * 2

    // --- Reveal glow position tracking ---
    property real _glowX: 0
    property real _glowY: 0

    background: Rectangle {
        id: cardBg
        radius: 0  // sharp corners, no exceptions
        color: ThemeManager.backgroundSurface
        border.width: 1
        border.color: ThemeManager.borderDefault

        // Elevation: resting vs. raised (spec's elevation.1 / elevation.2
        // tokens, Section 3.1). SIMPLIFIED, FLAGGED — this is a plain
        // offset semi-transparent rectangle using the token's alpha/
        // y-offset values directly, not a true soft-blur shadow. I didn't
        // want to guess at MultiEffect's shadow-property exact semantics
        // (blur normalization, etc.) without verifying them the way I did
        // for masking earlier — a real blurred shadow is a reasonable
        // follow-up once that's actually checked, not implemented here.
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: root.hovered ? ThemeManager.elevation2YOffset : ThemeManager.elevation1YOffset
            z: -1
            color: "#000000"
            opacity: root.hovered ? ThemeManager.elevation2Alpha : ThemeManager.elevation1Alpha
            Behavior on opacity {
                NumberAnimation {
                    duration: ThemeManager.durationBase
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: ThemeManager.easingCurve
                }
            }
        }

        MouseArea {
            id: glowTracker
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton  // click handling stays on root Button; this only tracks position
            onPositionChanged: (mouse) => {
                root._glowX = mouse.x
                root._glowY = mouse.y
            }
        }

        Item {
            anchors.fill: parent
            clip: true
            visible: root.hovered

            // SIMPLIFIED after two rounds of trouble with MultiEffect
            // masking (white-on-white invisibility, then a static/frozen
            // glow that stopped tracking the cursor). Rather than keep
            // stacking uncertain fixes on an effects pipeline I couldn't
            // fully verify, this bakes the accent-blue color directly
            // into glow.png itself (see the texture file) and displays
            // it as a plain Image with live position + opacity — no
            // masking, no MultiEffect, nothing running through a
            // multi-stage effect pipeline. Same simple technique already
            // proven to work elsewhere in this project (Button/Link's
            // opacity transitions), just applied to a moving Image.
            Image {
                id: glow
                source: "qrc:/textures/glow.png"
                width: 260
                height: 260
                x: root._glowX - width / 2
                y: root._glowY - height / 2
                smooth: true
                opacity: root.hovered ? 0.35 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: ThemeManager.durationBase
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: ThemeManager.easingCurve
                    }
                }
            }
        }

        // Pressed feedback — reuses the same overlay convention as Button,
        // for consistency, rather than inventing a different press
        // language for Card specifically.
        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: root.pressed ? 0.08 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: ThemeManager.durationMicro
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: ThemeManager.easingCurve
                }
            }
        }
    }

    contentItem: Column {
        id: contentColumn
        spacing: ThemeManager.spacing12

        AppText {
            text: root.title
            variant: "title"
            visible: root.title !== ""
        }

        Column {
            id: bodyColumn
            width: contentColumn.width
        }

        Loader {
            width: contentColumn.width
            active: root.footer !== null
            sourceComponent: root.footer
        }
    }
}


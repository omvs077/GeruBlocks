import QtQuick
import GeruBlocks

// Stepper — Step 8 Navigation ("Stepper/Wizard" in the spec's
// component list)
//
// Header-only step indicator, same header/content split as Tabs.qml —
// caller swaps actual step content separately (Loader/visibility bound
// to currentIndex), this component only shows progress.
//
// DELIBERATE THEMATIC NOTE: circle = node, straight line = connector is
// literally the Warli grammar's own core vocabulary (spec Section 4.1)
// — a step indicator is one of the few components where the grammar and
// the UI pattern are the same shape, not just decorated with it. Worth
// noting, not something to "fix."
//
// Each step circle sits at the LEFT edge of its equal-width segment
// (not centered) so the connector-line math stays simple — a visual
// choice, flagged as a first-pass proposal rather than a locked layout.
//
// MOTION (Phase 2 backlog): step transitions previously had ZERO
// animation — colors snapped instantly when currentIndex changed.
// Added Behavior on color for the node fill/border and the connector,
// at durationSlow (250ms) — "same bucket as panel enter/exit" per the
// backlog's decided mapping. Reduced-motion gated.
//
// Usage:
//   Stepper {
//       width: 400
//       currentIndex: 1
//       steps: ["Account", "Details", "Confirm"]
//   }

Item {
    id: root
    property var steps: []
    property int currentIndex: 0

    implicitWidth: 400
    implicitHeight: 64

    readonly property real _stepWidth: root.steps.length > 0 ? root.width / root.steps.length : root.width

    Row {
        anchors.fill: parent

        Repeater {
            model: root.steps

            Item {
                id: stepItem
                width: root._stepWidth
                height: root.height

                readonly property bool isDone: index < root.currentIndex
                readonly property bool isCurrent: index === root.currentIndex
                readonly property color nodeBorderColor: (isDone || isCurrent) ? ThemeManager.accentPrimary : ThemeManager.borderStrong

                Rectangle {
                    id: connector
                    visible: index < root.steps.length - 1
                    anchors.verticalCenter: circle.verticalCenter
                    anchors.left: circle.right
                    width: stepItem.width - circle.width
                    height: 2
                    color: stepItem.isDone ? ThemeManager.accentPrimary : ThemeManager.borderDefault

                    Behavior on color {
                        enabled: !ThemeManager.reducedMotion
                        ColorAnimation {
                            duration: ThemeManager.durationSlow
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: ThemeManager.easingCurve
                        }
                    }
                }

                Rectangle {
                    id: circle
                    anchors.top: parent.top
                    width: 28
                    height: 28
                    radius: 14
                    color: stepItem.isDone ? ThemeManager.accentPrimary : ThemeManager.backgroundSurface
                    border.width: 2
                    border.color: stepItem.nodeBorderColor

                    Behavior on color {
                        enabled: !ThemeManager.reducedMotion
                        ColorAnimation {
                            duration: ThemeManager.durationSlow
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: ThemeManager.easingCurve
                        }
                    }
                    Behavior on border.color {
                        enabled: !ThemeManager.reducedMotion
                        ColorAnimation {
                            duration: ThemeManager.durationSlow
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: ThemeManager.easingCurve
                        }
                    }

                    Text {
                        visible: stepItem.isDone
                        anchors.centerIn: parent
                        text: "\u2713"
                        color: "#FFFFFF"
                        font.pixelSize: 14
                    }
                    Text {
                        visible: !stepItem.isDone
                        anchors.centerIn: parent
                        text: (index + 1).toString()
                        color: stepItem.isCurrent ? ThemeManager.accentPrimary : ThemeManager.textSecondary
                        font.pixelSize: 13
                        font.family: "Poppins Medium"
                    }
                }

                AppText {
                    anchors.top: circle.bottom
                    anchors.topMargin: ThemeManager.spacing4
                    anchors.horizontalCenter: circle.horizontalCenter
                    text: modelData
                    variant: "caption"
                    color: stepItem.isCurrent ? ThemeManager.textPrimary : ThemeManager.textSecondary
                }
            }
        }
    }
}

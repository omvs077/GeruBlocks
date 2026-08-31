import QtQuick
import GeruBlocks

// GaugeChart — Step 12 Charts ("Gauge/Meter" in the spec's component
// list)
//
// Same arc exception as DonutChart.qml — see that file's header note.
//
// DESIGN CHOICE, FLAGGED NOT SPEC-STATED: a semi-circular FILLED-ARC
// gauge, not a rotating needle against tick marks. Simpler to render
// correctly and reads faster at a glance — a calibrated needle dial is
// real extra engineering for a stub-quality first pass.
//
// _cx/_cy/_radius are exposed as root-level properties (not local
// variables inside Canvas.onPaint) specifically so the value/label text
// underneath can position itself relative to the same arc geometry the
// canvas actually draws, rather than duplicating the math and risking
// the two drifting out of sync.
//
// Usage:
//   GaugeChart { width: 160; height: 100; value: 72; max: 100; label: "CPU" }

Item {
    id: root
    property real value: 0
    property real max: 100
    property string label: ""
    property color trackColor: ThemeManager.borderDefault
    property color fillColor: ThemeManager.accentPrimary

    implicitWidth: 160
    implicitHeight: 100

    readonly property real _fraction: root.max > 0 ? Math.max(0, Math.min(1, root.value / root.max)) : 0
    readonly property real _cx: width / 2
    readonly property real _cy: height - 8
    readonly property real _radius: Math.min(width / 2, height) - 10

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            var thickness = root._radius * 0.28
            var startAngle = Math.PI
            var endAngle = 0

            ctx.beginPath()
            ctx.lineWidth = thickness
            ctx.lineCap = "butt"
            ctx.strokeStyle = root.trackColor
            ctx.arc(root._cx, root._cy, root._radius, startAngle, endAngle, false)
            ctx.stroke()

            var valueAngle = startAngle + (endAngle - startAngle) * root._fraction
            ctx.beginPath()
            ctx.lineWidth = thickness
            ctx.strokeStyle = root.fillColor
            ctx.arc(root._cx, root._cy, root._radius, startAngle, valueAngle, false)
            ctx.stroke()
        }
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: root._cy - root._radius * 0.55
        spacing: 0

        Heading { anchors.horizontalCenter: parent.horizontalCenter; text: Math.round(root.value).toString() }
        AppText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.label
            variant: "caption"
            color: ThemeManager.textSecondary
            visible: root.label !== ""
        }
    }

    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()
    onValueChanged: canvas.requestPaint()
    onMaxChanged: canvas.requestPaint()
    onTrackColorChanged: canvas.requestPaint()
    onFillColorChanged: canvas.requestPaint()
}

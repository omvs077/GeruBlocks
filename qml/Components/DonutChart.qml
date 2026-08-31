import QtQuick
import GeruBlocks

// DonutChart — Step 12 Charts
//
// ARC EXCEPTION, FLAGGED: Section 4.1's "no curves except the full-
// circle primitive" is scoped to iconography, not restated in Section
// 10.1 for charts — and a donut literally cannot exist without arc
// segments. Treating charts as exempt from the icon grammar's no-arc
// rule rather than forcing this into straight-line segments, which
// would be a real usability regression for something that rule was
// never written to cover. Flagged, not silently assumed — say so if
// you want this treated differently.
//
// Usage:
//   DonutChart {
//       width: 160; height: 160
//       chartData: [
//           { label: "Active", value: 24, color: ThemeManager.statusSuccess },
//           { label: "Pending", value: 8 },
//           { label: "Blocked", value: 3, color: ThemeManager.statusError }
//       ]
//       centerLabel: "35"
//   }

Item {
    id: root
    property var chartData: []  // [{ label, value, color? }]
    property string centerLabel: ""
    property real thickness: 0.28  // fraction of radius

    implicitWidth: 160
    implicitHeight: 160

    readonly property var _palette: ["#1A5FD7", "#2E9B57", "#8B5FBF", "#D6A32E", "#2E9B9B", "#B3506B"]
    readonly property real _total: {
        var sum = 0
        for (var i = 0; i < chartData.length; i++) sum += chartData[i].value
        return sum
    }

    function _colorFor(i) {
        if (root.chartData[i].color !== undefined) return root.chartData[i].color
        return root._palette[i % root._palette.length]
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            if (root.chartData.length === 0 || root._total === 0) return

            var cx = width / 2
            var cy = height / 2
            var radius = Math.min(width, height) / 2 - 2
            var innerRadius = radius * (1 - root.thickness)

            var start = -Math.PI / 2
            for (var i = 0; i < root.chartData.length; i++) {
                var slice = (root.chartData[i].value / root._total) * 2 * Math.PI
                var end = start + slice

                ctx.beginPath()
                ctx.moveTo(cx + Math.cos(start) * innerRadius, cy + Math.sin(start) * innerRadius)
                ctx.arc(cx, cy, radius, start, end, false)
                ctx.lineTo(cx + Math.cos(end) * innerRadius, cy + Math.sin(end) * innerRadius)
                ctx.arc(cx, cy, innerRadius, end, start, true)
                ctx.closePath()
                ctx.fillStyle = root._colorFor(i)
                ctx.fill()

                start = end
            }
        }
    }

    AppText {
        anchors.centerIn: parent
        text: root.centerLabel
        variant: "title"
        visible: root.centerLabel !== ""
    }

    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()
    onChartDataChanged: canvas.requestPaint()
    onThicknessChanged: canvas.requestPaint()
}

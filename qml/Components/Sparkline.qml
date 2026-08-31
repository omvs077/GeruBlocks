import QtQuick
import GeruBlocks

// Sparkline — Step 12 Charts
// A tiny, label-free trend line for tight spaces (table cells,
// StatTile.qml footers) — distinct from LineChart.qml, not a stripped-
// down variant of it, since the two have genuinely different use cases
// (a full chart vs. an inline glance-level trend).
//
// Usage:
//   Sparkline { width: 80; height: 24; chartData: [3,5,4,7,6,9,8] }

Item {
    id: root
    property var chartData: []
    property color lineColor: ThemeManager.accentPrimary

    implicitWidth: 80
    implicitHeight: 24

    readonly property real _min: chartData.length > 0 ? Math.min.apply(null, chartData) : 0
    readonly property real _max: chartData.length > 0 ? Math.max.apply(null, chartData) : 1
    readonly property real _range: (_max - _min) === 0 ? 1 : (_max - _min)

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            if (root.chartData.length < 2) return

            ctx.beginPath()
            ctx.strokeStyle = root.lineColor
            ctx.lineWidth = 1.5
            for (var i = 0; i < root.chartData.length; i++) {
                var x = (i / (root.chartData.length - 1)) * width
                var y = height - ((root.chartData[i] - root._min) / root._range) * height
                if (i === 0) ctx.moveTo(x, y)
                else ctx.lineTo(x, y)
            }
            ctx.stroke()
        }
    }

    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()
    onChartDataChanged: canvas.requestPaint()
    onLineColorChanged: canvas.requestPaint()
}

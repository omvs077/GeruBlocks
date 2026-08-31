import QtQuick
import GeruBlocks

// LineChart — Step 12 Charts
// See this batch's top-level note on why Canvas stands in for the
// spec's "pure SVG" wording — same reasoning applies to all 5 chart
// components, not repeated in each file.
//
// Canvas.onPaint is imperative, not a reactive QML binding — it only
// repaints when explicitly told to. Every property that affects the
// drawn output gets an onXChanged -> canvas.requestPaint() below,
// INCLUDING color properties, so a light/dark theme toggle actually
// repaints the chart in the new colors rather than silently going
// stale.
//
// Usage:
//   LineChart {
//       width: 300; height: 160
//       chartData: [12, 19, 8, 25, 30, 22, 28]
//       labels: ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
//   }

Item {
    id: root
    property var chartData: []       // array of numbers
    property var labels: []     // optional, same length as chartData
    property color lineColor: ThemeManager.accentPrimary
    property bool showArea: true
    property bool showDots: true

    implicitWidth: 300
    implicitHeight: 160

    readonly property real _padding: 8
    readonly property real _labelHeight: labels.length > 0 ? 18 : 0
    readonly property real _min: chartData.length > 0 ? Math.min.apply(null, chartData) : 0
    readonly property real _max: chartData.length > 0 ? Math.max.apply(null, chartData) : 1
    readonly property real _range: (_max - _min) === 0 ? 1 : (_max - _min)

    function _plotX(i) {
        if (chartData.length <= 1) return _padding
        return _padding + (i / (chartData.length - 1)) * (width - _padding * 2)
    }
    function _plotY(v) {
        var h = height - _labelHeight - _padding * 2
        return _padding + h - ((v - _min) / _range) * h
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            if (root.chartData.length === 0) return

            if (root.showArea) {
                ctx.beginPath()
                ctx.moveTo(root._plotX(0), root.height - root._labelHeight - root._padding)
                for (var i = 0; i < root.chartData.length; i++) {
                    ctx.lineTo(root._plotX(i), root._plotY(root.chartData[i]))
                }
                ctx.lineTo(root._plotX(root.chartData.length - 1), root.height - root._labelHeight - root._padding)
                ctx.closePath()
                ctx.fillStyle = Qt.rgba(root.lineColor.r, root.lineColor.g, root.lineColor.b, 0.12)
                ctx.fill()
            }

            ctx.beginPath()
            ctx.strokeStyle = root.lineColor
            ctx.lineWidth = 2
            for (var j = 0; j < root.chartData.length; j++) {
                var x = root._plotX(j)
                var y = root._plotY(root.chartData[j])
                if (j === 0) ctx.moveTo(x, y)
                else ctx.lineTo(x, y)
            }
            ctx.stroke()

            if (root.showDots) {
                ctx.fillStyle = root.lineColor
                for (var k = 0; k < root.chartData.length; k++) {
                    ctx.beginPath()
                    ctx.arc(root._plotX(k), root._plotY(root.chartData[k]), 3, 0, 2 * Math.PI)
                    ctx.fill()
                }
            }
        }
    }

    Row {
        visible: root.labels.length > 0
        // Explicit root.* rather than bare parent.* -- defensive, since
        // the earlier data/chartData naming collision (see header note)
        // was scrambling child parenting in exactly this kind of
        // anchor binding. Costs nothing and removes any doubt.
        anchors.bottom: root.bottom
        anchors.left: root.left
        anchors.right: root.right
        height: root._labelHeight

        Repeater {
            model: root.labels
            Text {
                width: root.width / Math.max(1, root.labels.length)
                horizontalAlignment: Text.AlignHCenter
                text: modelData
                font.family: "Poppins"
                font.pixelSize: 10
                color: ThemeManager.textSecondary
            }
        }
    }

    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()
    onChartDataChanged: canvas.requestPaint()
    onLineColorChanged: canvas.requestPaint()
    onShowAreaChanged: canvas.requestPaint()
    onShowDotsChanged: canvas.requestPaint()
}

import QtQuick
import GeruBlocks

// BarChart — Step 12 Charts
// Same Canvas-based approach as LineChart.qml — see that file's header
// note on why Canvas stands in for the spec's "pure SVG" wording, and
// on why every color/chartData property gets an explicit repaint trigger.
//
// Usage:
//   BarChart {
//       width: 300; height: 160
//       chartData: [12, 19, 8, 25, 30]
//       labels: ["Q1","Q2","Q3","Q4","Q5"]
//   }

Item {
    id: root
    property var chartData: []
    property var labels: []
    property color barColor: ThemeManager.accentPrimary

    implicitWidth: 300
    implicitHeight: 160

    readonly property real _padding: 8
    readonly property real _labelHeight: labels.length > 0 ? 18 : 0
    readonly property real _max: chartData.length > 0 ? Math.max.apply(null, chartData) : 1
    readonly property real _barGap: 8

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            if (root.chartData.length === 0) return

            var chartH = root.height - root._labelHeight - root._padding * 2
            var chartW = root.width - root._padding * 2
            var barW = (chartW - root._barGap * (root.chartData.length - 1)) / root.chartData.length

            ctx.fillStyle = root.barColor
            for (var i = 0; i < root.chartData.length; i++) {
                var barH = root._max > 0 ? (root.chartData[i] / root._max) * chartH : 0
                var x = root._padding + i * (barW + root._barGap)
                var y = root._padding + chartH - barH
                ctx.fillRect(x, y, barW, barH)
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
    onBarColorChanged: canvas.requestPaint()
}

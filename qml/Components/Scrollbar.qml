import QtQuick
import GeruBlocks

// Scrollbar — standalone, draggable, design-system-styled scrollbar.
// Attach to any Flickable via `flickable`. Extracted out of ScrollArea's
// former inline implementation so any future component with its own
// Flickable (DataTable, TreeView, dropdown lists, etc.) can reuse the
// same real component instead of duplicating scrollbar logic per-file.
//
// STYLES:
//   "overlay" (default) — thin (spacing4), fully transparent track, thumb
//     fades in only on hover/scroll/drag (Windows 10 "reveal" pattern) —
//     matches ScrollArea's original minimal-chrome scrollbar exactly, so
//     existing usage is visually unchanged.
//   "inline" — thicker (spacing8), a faint always-visible track so the
//     reserved gutter reads as intentional rather than empty space, thumb
//     rests at a dim visible opacity instead of fully invisible — for
//     contexts where a persistent "there's more content" affordance
//     matters more than minimal chrome (e.g. dense data lists).
//
// DRAG BEHAVIOR: thumb position is normally driven BY the flickable's
// contentY/contentX, but while the user is actively dragging the thumb,
// that relationship must invert -- the thumb drives the flickable
// instead. Binding both directions permanently would fight itself (same
// class of bug as this project's documented anchors+animated-x conflict),
// so a `dragging` flag gates which direction is authoritative at any
// moment, and the sync-from-flickable path is skipped entirely while
// dragging is active.
//
// NOT YET SCREENSHOT/DRAG-CONFIRMED on real hardware -- first version of
// this drag technique in this project. Confirm the drag actually feels
// right (no jitter, no fighting) before treating this as locked.
//
// Usage:
//   Scrollbar { flickable: myFlickable; orientation: "vertical" }
//   Scrollbar { flickable: myFlickable; orientation: "horizontal"; style: "inline" }

Item {
    id: root

    property Flickable flickable: null
    property string orientation: "vertical"   // "vertical" | "horizontal"
    property string style: "overlay"          // "overlay" | "inline"

    readonly property bool isVertical: orientation === "vertical"
    readonly property real thickness: style === "inline" ? ThemeManager.spacing8 : ThemeManager.spacing4
    readonly property real restingOpacity: style === "inline" ? 0.4 : 0
    readonly property real activeOpacity: 0.9

    readonly property real contentSize: flickable ? (isVertical ? flickable.contentHeight : flickable.contentWidth) : 1
    readonly property real viewportSize: flickable ? (isVertical ? flickable.height : flickable.width) : 1
    readonly property real trackSize: isVertical ? height : width

    visible: flickable !== null && contentSize > viewportSize

    width: isVertical ? thickness : (parent ? parent.width : thickness)
    height: isVertical ? (parent ? parent.height : thickness) : thickness
    anchors.right: isVertical ? parent.right : undefined
    anchors.top: isVertical ? parent.top : undefined
    anchors.bottom: !isVertical ? parent.bottom : undefined
    anchors.left: !isVertical ? parent.left : undefined

    // Track background -- invisible for "overlay", a faint visible gutter for "inline"
    Rectangle {
        anchors.fill: parent
        radius: 0
        color: root.style === "inline" ? ThemeManager.borderDefault : "transparent"
        opacity: root.style === "inline" ? 0.4 : 1
    }

    Rectangle {
        id: thumb
        radius: 0
        color: ThemeManager.borderStrong

        property bool dragging: false
        readonly property real thumbLength: Math.max(24, (root.viewportSize / Math.max(1, root.contentSize)) * root.trackSize)

        width: root.isVertical ? root.thickness : thumbLength
        height: root.isVertical ? thumbLength : root.thickness

        opacity: (dragging || dragArea.containsMouse || (root.flickable && root.flickable.moving)) ? root.activeOpacity : root.restingOpacity
        Behavior on opacity {
            NumberAnimation { duration: ThemeManager.durationFast; easing.type: Easing.BezierSpline; easing.bezierCurve: ThemeManager.easingCurve }
        }

        // Position synced FROM the flickable, except while actively
        // dragging (see header note on why these two directions can't
        // both be live bindings at once).
        function syncFromFlickable() {
            if (dragging || !root.flickable) return
            var maxScroll = Math.max(1, root.contentSize - root.viewportSize)
            var maxTravel = Math.max(1, root.trackSize - thumbLength)
            var current = root.isVertical ? root.flickable.contentY : root.flickable.contentX
            var ratio = maxScroll > 0 ? current / maxScroll : 0
            if (root.isVertical) y = ratio * maxTravel
            else x = ratio * maxTravel
        }

        Connections {
            target: root.flickable
            function onContentYChanged() { thumb.syncFromFlickable() }
            function onContentXChanged() { thumb.syncFromFlickable() }
        }
        Component.onCompleted: syncFromFlickable()
        onThumbLengthChanged: syncFromFlickable()

        // While dragging, the thumb drives the flickable instead.
        onXChanged: {
            if (!dragging || root.isVertical || !root.flickable) return
            var maxScroll = Math.max(1, root.contentSize - root.viewportSize)
            var maxTravel = Math.max(1, root.trackSize - thumbLength)
            root.flickable.contentX = (x / maxTravel) * maxScroll
        }
        onYChanged: {
            if (!dragging || !root.isVertical || !root.flickable) return
            var maxScroll = Math.max(1, root.contentSize - root.viewportSize)
            var maxTravel = Math.max(1, root.trackSize - thumbLength)
            root.flickable.contentY = (y / maxTravel) * maxScroll
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            hoverEnabled: true
            drag.target: thumb
            drag.axis: root.isVertical ? Drag.YAxis : Drag.XAxis
            drag.minimumX: 0
            drag.maximumX: root.isVertical ? 0 : Math.max(0, root.trackSize - thumb.thumbLength)
            drag.minimumY: 0
            drag.maximumY: root.isVertical ? Math.max(0, root.trackSize - thumb.thumbLength) : 0
            onPressed: thumb.dragging = true
            onReleased: thumb.dragging = false
        }
    }
}

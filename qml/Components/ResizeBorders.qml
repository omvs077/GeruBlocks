import QtQuick
import QtQuick.Window

// Geru Blocks — ResizeBorders.qml (Step 13, companion to TitleBar / Window Frame)
//
// FLAGGED ADDITION: this is not a separately named line-item in the spec's Step 13 list,
// but a frameless ApplicationWindow (Qt.FramelessWindowHint) loses ALL native edge/corner
// resize hit-testing — without something like this, the window cannot be resized by
// dragging its edges at all. Adding it as a companion file follows the same precedent as
// ToastManager+ToastHost (Step 4) and Avatar+AvatarGroup (Step 11): one spec line-item
// implemented as more than one file where the platform genuinely requires it.
//
// Uses Qt 6's native QWindow::startSystemResize() via the Window attached property, so the
// OS performs the actual resize (correct cursor feedback and correct behavior across
// monitors/DPI) rather than reimplementing resize math by hand.
//
// Usage: place as a top-level sibling covering the whole window, above (in z-order) all
// window content, e.g.:
//   ResizeBorders { anchors.fill: parent; visible: window.visibility !== Window.Maximized }

Item {
    id: root
    // 8 matches ThemeManager.spacing8 — kept as a literal default (not a direct token
    // reference) since this is an interaction hit-zone thickness, not a layout spacing
    // value, but it's deliberately picked to land on the same 4px grid as everything else.
    property int borderSize: 8

    function resize(edges) {
        var w = Window.window
        if (w) w.startSystemResize(edges)
    }

    // Edges
    MouseArea {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: root.borderSize
        cursorShape: Qt.SizeVerCursor
        onPressed: root.resize(Qt.TopEdge)
    }
    MouseArea {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: root.borderSize
        cursorShape: Qt.SizeVerCursor
        onPressed: root.resize(Qt.BottomEdge)
    }
    MouseArea {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.borderSize
        cursorShape: Qt.SizeHorCursor
        onPressed: root.resize(Qt.LeftEdge)
    }
    MouseArea {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.borderSize
        cursorShape: Qt.SizeHorCursor
        onPressed: root.resize(Qt.RightEdge)
    }

    // Corners (drawn on top of edges for a larger, diagonal-cursor hit target)
    MouseArea {
        anchors.top: parent.top
        anchors.left: parent.left
        width: root.borderSize * 2
        height: root.borderSize * 2
        cursorShape: Qt.SizeFDiagCursor
        onPressed: root.resize(Qt.TopEdge | Qt.LeftEdge)
    }
    MouseArea {
        anchors.top: parent.top
        anchors.right: parent.right
        width: root.borderSize * 2
        height: root.borderSize * 2
        cursorShape: Qt.SizeBDiagCursor
        onPressed: root.resize(Qt.TopEdge | Qt.RightEdge)
    }
    MouseArea {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: root.borderSize * 2
        height: root.borderSize * 2
        cursorShape: Qt.SizeBDiagCursor
        onPressed: root.resize(Qt.BottomEdge | Qt.LeftEdge)
    }
    MouseArea {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: root.borderSize * 2
        height: root.borderSize * 2
        cursorShape: Qt.SizeFDiagCursor
        onPressed: root.resize(Qt.BottomEdge | Qt.RightEdge)
    }
}

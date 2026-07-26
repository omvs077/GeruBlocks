import QtQuick
import GeruBlocks

// DataTable — Step 3 Inputs & Data
//
// Column-defined, virtualized (ListView-backed) table with the
// "border-reveal" row hover behavior from spec Section 3.6 ("thin accent
// bar glides in from the left edge on hover") — distinct from Card's
// reveal-glow and Button's overlay, this is its own defined hover
// language reserved specifically for list rows / nav items.
//
// Density and number formatting are NOT new logic — this just wires in
// ThemeManager.rowHeight/densityPadding and LocalizationUtil's Indian
// number/currency formatting, both already built and signed off.
//
// TABULAR NUMS: spec Section 3.2 explicitly scopes font-variant-numeric:
// tabular-nums to "table and metric-text components" — this is the first
// component that scope actually applies to (AppText deliberately did NOT
// apply it, staying general-purpose). Implemented via font.features:
// {"tnum": 1}. FLAGGED, NOT VERIFIED: I haven't confirmed Poppins actually
// has a tabular-figures OpenType feature table — if it doesn't, this is a
// harmless no-op (unsupported feature tags are just ignored), not a bug,
// but the visual alignment benefit is unconfirmed either way. Worth an
// actual look once built: do numeric columns actually line up?
//
// ASSUMPTIONS FLAGGED, NOT LOCKED (spec doesn't specify these details):
// - Numeric columns right-align, text columns left-align (common
//   convention, not stated in the spec)
// - Equal column width distribution by default, with an optional
//   per-column `width` override
// - Row click is optional (onRowClicked signal) — spec doesn't describe
//   row-click behavior for DataTable specifically
//
// Usage:
//   DataTable {
//       columns: [
//           { key: "zone", title: "Zone" },
//           { key: "temp", title: "Temp (°C)", numeric: true },
//           { key: "cost", title: "Monthly Cost", numeric: true, currency: true }
//       ]
//       rows: [
//           { zone: "Zone 1", temp: 21.5, cost: 45000 },
//           { zone: "Zone 2", temp: 19.8, cost: 38000 }
//       ]
//       onRowClicked: (rowData) => console.log(rowData.zone)
//   }

Item {
    id: root

    // [{ key, title, numeric: bool, currency: bool, width: optional real }]
    property var columns: []
    // [{ <key>: value, ... }, ...]
    property var rows: []

    signal rowClicked(var rowData)

    implicitHeight: 300  // caller typically constrains height via Layout/anchors

    function _columnWidth(col, index) {
        if (col.width !== undefined) return col.width
        var fixedTotal = 0
        var flexCount = 0
        for (var i = 0; i < root.columns.length; i++) {
            if (root.columns[i].width !== undefined) fixedTotal += root.columns[i].width
            else flexCount++
        }
        return flexCount > 0 ? (width - fixedTotal) / flexCount : 0
    }

    function _formatCell(col, value) {
        if (col.currency) return LocalizationUtil.formatCurrency(value)
        if (col.numeric) return LocalizationUtil.formatNumber(value, col.decimals !== undefined ? col.decimals : 0)
        return value !== undefined && value !== null ? value.toString() : ""
    }

    Column {
        anchors.fill: parent

        // ---------- Header ----------
        Rectangle {
            width: parent.width
            height: ThemeManager.rowHeight
            color: ThemeManager.backgroundSurface
            border.width: 0

            Row {
                anchors.fill: parent
                Repeater {
                    model: root.columns
                    delegate: Item {
                        width: root._columnWidth(modelData, index)
                        height: ThemeManager.rowHeight

                        AppText {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: ThemeManager.densityPadding
                            anchors.rightMargin: ThemeManager.densityPadding
                            horizontalAlignment: modelData.numeric ? Text.AlignRight : Text.AlignLeft
                            variant: "subtitle"
                            text: modelData.title
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: ThemeManager.borderWidthDefault
                color: ThemeManager.borderStrong
            }
        }

        // ---------- Rows ----------
        ListView {
            width: parent.width
            height: parent.height - ThemeManager.rowHeight
            clip: true
            model: root.rows
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
                id: rowDelegate
                width: ListView.view.width
                height: ThemeManager.rowHeight
                color: rowHoverArea.containsMouse ? ThemeManager.backgroundPage : ThemeManager.backgroundSurface

                // Captured here, BEFORE the inner column Repeater's own
                // `index` can shadow the outer (row) index of the same
                // name — this is the standard fix for nested Repeaters
                // both exposing an `index` property. My first attempt at
                // this used a fragile indexAt()-based workaround instead;
                // this is the actually-correct approach.
                property int rowIndex: index

                // Border-reveal: thin accent bar glides in from the left
                // edge on hover (Section 3.6) — x animates from just
                // off-edge (-width, fully hidden) to 0 (revealed), rather
                // than an instant appearance or a width/opacity change,
                // to actually match "glides in."
                Rectangle {
                    id: revealBar
                    width: 3
                    height: parent.height
                    x: rowHoverArea.containsMouse ? 0 : -width
                    color: ThemeManager.accentPrimary

                    Behavior on x {
                        NumberAnimation {
                            duration: ThemeManager.durationBase  // 200ms — "List row hover" per spec's own duration table
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: ThemeManager.easingCurve
                        }
                    }
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 3  // room for the reveal bar, doesn't shift on hover

                    Repeater {
                        model: root.columns
                        delegate: Item {
                            width: root._columnWidth(modelData, index)
                            height: rowDelegate.height

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: ThemeManager.densityPadding
                                anchors.rightMargin: ThemeManager.densityPadding
                                horizontalAlignment: modelData.numeric ? Text.AlignRight : Text.AlignLeft
                                font.family: "Poppins"
                                font.pixelSize: 14
                                font.features: modelData.numeric ? { "tnum": 1 } : ({})
                                color: ThemeManager.textPrimary
                                elide: Text.ElideRight
                                text: root._formatCell(modelData, root.rows[rowDelegate.rowIndex][modelData.key])
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: ThemeManager.borderDefault
                }

                MouseArea {
                    id: rowHoverArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.rowClicked(root.rows[rowDelegate.rowIndex])
                }
            }
        }
    }
}

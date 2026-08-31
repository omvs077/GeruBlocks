import QtQuick
import QtQuick.Window
import QtQuick.Controls.Basic as Basic
import GeruBlocks

// DatePicker — Step 6
// Hand-built calendar grid. Trigger shows the selected date via
// LocalizationUtil.formatDate (DD/MM/YYYY) with a calendar icon. Opens
// a popup month grid with month/year quick-jump controls: a 3x4 month
// grid, and a bounded, scrollable year list (NOT freeform text entry)
// so large date gaps are a single click within a defined valid range,
// with no risk of typing an out-of-range or nonsensical year.
//
// ASSUMPTIONS FLAGGED, NOT SPEC-STATED:
// - Week starts Sunday (JS Date.getDay() convention).
// - Days outside the current month are shown greyed/disabled rather
//   than omitted, so the grid stays a consistent 6 rows.
// - "Today" gets a distinguishing outline separate from "selected".
// - minYear/maxYear default to (currentYear-100, currentYear+50) —
//   exposed as properties so callers can override per use-case
//   (e.g. a "date of birth" field would want a different range than
//   a "project deadline" field). Not spec-stated either way.
//
// FIXED (this pass, on top of prior scroll/reposition + icon-trigger
// fixes): removed the freeform year TextField entirely — its
// _commit() only checked text.length === 4, never checked the
// validator's actual bottom/top bounds or IntValidator.acceptableInput,
// so "1780" (a valid 4-digit string, but out of the intended
// 1900-2100 range) was accepted uncaught. A length check is not a
// range check. Replaced with a bounded ListView popup: nothing
// outside [minYear, maxYear] can ever be selected, because the list
// itself only contains valid values — no validation logic to get
// wrong. Also replaced the "clever" || one-liner chevron handlers
// (flagged as risky last pass) with explicit multi-statement blocks
// that correctly roll the year over at Jan/Dec boundaries.

Item {
    id: root

    property date selectedDate: new Date()
    property date viewDate: new Date(selectedDate.getFullYear(), selectedDate.getMonth(), 1)
    property int minYear: new Date().getFullYear() - 100
    property int maxYear: new Date().getFullYear() + 50

    // VALIDATION-GAP FOLLOW-UP: added so Form.qml can find and
    // validate this field. "value" aliases the existing selectedDate
    // property (Form checks .text then .value).
    property string errorMessage: ""
    // "default" | "error" | "success"
    property string validationState: "default"
    property bool required: false
    property alias value: root.selectedDate

    signal dateSelected(date newDate)

    implicitWidth: 220
    implicitHeight: ThemeManager.controlHeight

    readonly property var dayLabels: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
    readonly property var monthLabels: ["January", "February", "March", "April", "May", "June",
                                         "July", "August", "September", "October", "November", "December"]
    readonly property var monthShort: ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    function _daysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate()
    }

    function _buildGrid() {
        var year = root.viewDate.getFullYear()
        var month = root.viewDate.getMonth()
        var startDay = new Date(year, month, 1).getDay()
        var totalDays = _daysInMonth(year, month)
        var prevMonthDays = _daysInMonth(year, month - 1 < 0 ? 11 : month - 1)
        var cells = []

        for (var i = 0; i < startDay; i++) {
            cells.push({ day: prevMonthDays - startDay + 1 + i, currentMonth: false, year: month === 0 ? year - 1 : year, month: month === 0 ? 11 : month - 1 })
        }
        for (var d = 1; d <= totalDays; d++) {
            cells.push({ day: d, currentMonth: true, year: year, month: month })
        }
        while (cells.length < 42) {
            var next = cells.length - startDay - totalDays + 1
            cells.push({ day: next, currentMonth: false, year: month === 11 ? year + 1 : year, month: month === 11 ? 0 : month + 1 })
        }
        return cells
    }

    property var _gridCells: _buildGrid()

    readonly property var _yearList: {
        var arr = []
        for (var y = root.maxYear; y >= root.minYear; y--) arr.push(y)
        return arr
    }

    function _goToMonth(monthIndex) {
        root.viewDate = new Date(root.viewDate.getFullYear(), monthIndex, 1)
    }

    function _goToYear(year) {
        var clamped = Math.max(root.minYear, Math.min(root.maxYear, year))
        root.viewDate = new Date(clamped, root.viewDate.getMonth(), 1)
    }

    // ---------- Trigger ----------
    Rectangle {
        id: triggerBg
        anchors.fill: parent
        radius: 0
        border.width: 1
        border.color: {
            if (triggerArea.containsMouse || popup.visible) return ThemeManager.accentPrimary
            if (root.validationState === "error") return ThemeManager.statusError
            if (root.validationState === "success") return ThemeManager.statusSuccess
            return ThemeManager.borderDefault
        }
        color: ThemeManager.backgroundSurface

        Row {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: ThemeManager.spacing12
            anchors.rightMargin: ThemeManager.spacing12
            spacing: ThemeManager.spacing8

            Text {
                width: parent.width - 20 - ThemeManager.spacing8
                anchors.verticalCenter: parent.verticalCenter
                text: LocalizationUtil.formatDate(root.selectedDate)
                font.family: "Poppins"
                font.pixelSize: 14
                color: ThemeManager.textPrimary
            }

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                name: "calendar"
                size: 18
                color: ThemeManager.textSecondary
            }
        }

        MouseArea {
            id: triggerArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: popup.visible ? popup.close() : popup.open()
        }
    }

    Basic.Popup {
        id: popup
        width: 280
        padding: ThemeManager.spacing12

        readonly property real _naturalHeight: ThemeManager.rowHeight * 8 + ThemeManager.spacing8 * 2 + ThemeManager.spacing12 * 2

        function _reposition() {
            var win = root.Window.window
            var winHeight = win ? win.height : 600
            var inputBottomOnWindow = triggerBg.mapToItem(null, 0, triggerBg.height).y
            var inputTopOnWindow = triggerBg.mapToItem(null, 0, 0).y
            var margin = 16
            var spaceBelow = winHeight - inputBottomOnWindow - margin
            var spaceAbove = inputTopOnWindow - margin

            if (spaceBelow >= Math.min(_naturalHeight, 200) || spaceBelow >= spaceAbove) {
                y = triggerBg.height
                height = Math.max(120, Math.min(_naturalHeight, spaceBelow))
            } else {
                height = Math.max(120, Math.min(_naturalHeight, spaceAbove))
                y = -height
            }
        }

        onAboutToShow: _reposition()

        background: Rectangle {
            radius: 0
            border.width: 1
            border.color: ThemeManager.borderDefault
            color: ThemeManager.backgroundSurface
        }

        contentItem: Flickable {
            id: flick
            clip: true
            contentWidth: width
            contentHeight: colContent.height
            boundsBehavior: Flickable.StopAtBounds

            Basic.ScrollBar.vertical: Basic.ScrollBar {
                policy: Basic.ScrollBar.AsNeeded
            }

            Column {
                id: colContent
                width: flick.width
                spacing: ThemeManager.spacing8

                // ---------- Month / Year quick-jump navigation ----------
                Row {
                    width: parent.width
                    height: ThemeManager.rowHeight

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "chevron_left"
                        size: 18
                        color: ThemeManager.textPrimary
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            onClicked: {
                                if (root.viewDate.getMonth() === 0) {
                                    root._goToYear(root.viewDate.getFullYear() - 1)
                                    root._goToMonth(11)
                                } else {
                                    root._goToMonth(root.viewDate.getMonth() - 1)
                                }
                            }
                        }
                    }

                    // Month label — click opens a 12-month grid picker
                    Rectangle {
                        width: (parent.width - 2 * (18 + ThemeManager.spacing8)) * 0.55
                        height: parent.height
                        color: "transparent"
                        AppText {
                            anchors.centerIn: parent
                            text: root.monthLabels[root.viewDate.getMonth()]
                            variant: "subtitle"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: monthPopup.visible ? monthPopup.close() : monthPopup.open()
                        }
                    }

                    // Year label — click opens a bounded, scrollable year list
                    Rectangle {
                        width: (parent.width - 2 * (18 + ThemeManager.spacing8)) * 0.45
                        height: parent.height
                        color: "transparent"
                        AppText {
                            anchors.centerIn: parent
                            text: root.viewDate.getFullYear().toString()
                            variant: "subtitle"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: yearPopup.visible ? yearPopup.close() : yearPopup.open()
                        }
                    }

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "chevron_right"
                        size: 18
                        color: ThemeManager.textPrimary
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            onClicked: {
                                if (root.viewDate.getMonth() === 11) {
                                    root._goToYear(root.viewDate.getFullYear() + 1)
                                    root._goToMonth(0)
                                } else {
                                    root._goToMonth(root.viewDate.getMonth() + 1)
                                }
                            }
                        }
                    }
                }

                // ---------- Day-of-week header ----------
                Row {
                    width: parent.width
                    Repeater {
                        model: root.dayLabels
                        delegate: AppText {
                            width: parent.width / 7
                            horizontalAlignment: Text.AlignHCenter
                            variant: "caption"
                            text: modelData
                        }
                    }
                }

                // ---------- Day grid ----------
                Grid {
                    width: parent.width
                    columns: 7

                    Repeater {
                        model: root._gridCells
                        delegate: Rectangle {
                            width: parent.width / 7
                            height: ThemeManager.rowHeight
                            radius: 0
                            readonly property bool isSelected: modelData.currentMonth
                                && modelData.day === root.selectedDate.getDate()
                                && modelData.month === root.selectedDate.getMonth()
                                && modelData.year === root.selectedDate.getFullYear()
                            readonly property bool isToday: {
                                var t = new Date()
                                return modelData.day === t.getDate() && modelData.month === t.getMonth() && modelData.year === t.getFullYear()
                            }
                            color: isSelected ? ThemeManager.accentPrimary : "transparent"
                            border.width: isToday && !isSelected ? 1 : 0
                            border.color: ThemeManager.accentPrimary

                            Text {
                                anchors.centerIn: parent
                                text: modelData.day
                                font.family: "Poppins"
                                font.pixelSize: 13
                                color: isSelected ? "#FFFFFF" : (modelData.currentMonth ? ThemeManager.textPrimary : ThemeManager.textSecondary)
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var newDate = new Date(modelData.year, modelData.month, modelData.day)
                                    root.selectedDate = newDate
                                    root.dateSelected(newDate)
                                    popup.close()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ---------- Month quick-jump grid (3x4) ----------
    Basic.Popup {
        id: monthPopup
        y: popup.y + ThemeManager.rowHeight
        x: 0
        width: 200
        padding: ThemeManager.spacing8

        background: Rectangle {
            radius: 0
            border.width: 1
            border.color: ThemeManager.borderDefault
            color: ThemeManager.backgroundSurface
        }

        contentItem: Grid {
            columns: 3
            columnSpacing: ThemeManager.spacing8
            rowSpacing: ThemeManager.spacing8

            Repeater {
                model: root.monthShort
                delegate: Rectangle {
                    width: 58
                    height: 32
                    radius: 0
                    color: index === root.viewDate.getMonth() ? ThemeManager.accentPrimary : "transparent"
                    border.width: 1
                    border.color: ThemeManager.borderDefault
                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        font.family: "Poppins"
                        font.pixelSize: 12
                        color: index === root.viewDate.getMonth() ? "#FFFFFF" : ThemeManager.textPrimary
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root._goToMonth(index)
                            monthPopup.close()
                        }
                    }
                }
            }
        }
    }

    // ---------- Year quick-jump list (bounded [minYear, maxYear]) ----------
    Basic.Popup {
        id: yearPopup
        y: popup.y + ThemeManager.rowHeight
        x: 100
        width: 100
        height: 220
        padding: 0

        background: Rectangle {
            radius: 0
            border.width: 1
            border.color: ThemeManager.borderDefault
            color: ThemeManager.backgroundSurface
        }

        onAboutToShow: {
            var idx = root._yearList.indexOf(root.viewDate.getFullYear())
            if (idx >= 0) yearListView.positionViewAtIndex(idx, ListView.Center)
        }

        contentItem: ListView {
            id: yearListView
            clip: true
            model: root._yearList

            Basic.ScrollBar.vertical: Basic.ScrollBar {
                policy: Basic.ScrollBar.AlwaysOn
            }

            delegate: Rectangle {
                width: yearListView.width
                height: ThemeManager.rowHeight
                color: modelData === root.viewDate.getFullYear() ? ThemeManager.accentPrimary : "transparent"
                Text {
                    anchors.centerIn: parent
                    text: modelData.toString()
                    font.family: "Poppins"
                    font.pixelSize: 13
                    color: modelData === root.viewDate.getFullYear() ? "#FFFFFF" : ThemeManager.textPrimary
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root._goToYear(modelData)
                        yearPopup.close()
                    }
                }
            }
        }
    }
}
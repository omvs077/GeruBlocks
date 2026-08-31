import QtQuick
import QtQuick.Window
import QtQuick.Controls.Basic as Basic
import GeruBlocks

// TimePicker — Step 6
// Trigger shows the selected time via LocalizationUtil.formatTime
// (12-hour, AM/PM default per India localization) with a clock icon,
// matching DatePicker's icon-trigger pattern. Popup has three bounded
// columns — Hour (1-12), Minute (stepped by minuteStep, default 5),
// AM/PM (reuses SegmentedControl) — deliberately dropdown/list-based
// rather than iOS-style scroll wheels, consistent with DatePicker's
// year-list approach: simpler to get right, no wheel-scroll physics.
//
// ASSUMPTIONS FLAGGED, NOT SPEC-STATED:
// - minuteStep defaults to 5 (12 options: 00,05,...,55), overridable
//   per instance (e.g. minuteStep: 1 for exact-minute entry,
//   minuteStep: 15 for coarser scheduling UIs).
// - If selectedTime's minute isn't an exact multiple of minuteStep,
//   no minute row will show as highlighted/selected (e.g. a time of
//   14:07 with the default 5-minute step) — not resolved here, flagged
//   as a real edge case if callers pass in arbitrary pre-set times.
//
// Reuses SegmentedControl for AM/PM rather than hand-building a third
// toggle style — dogfoods the existing Step 5 component. Binding note:
// currentValue starts bound to the derived AM/PM of selectedTime, but
// QML destroys that binding the moment the user clicks a segment
// (standard QML behavior for any property). That's intentional and
// safe here — unlike DatePicker's _gridCells bug, AM/PM is a genuinely
// user-driven toggle after first render, not a value that must stay
// continuously derived from other state.

Item {
    id: root

    property date selectedTime: new Date()

    // VALIDATION-GAP FOLLOW-UP: added so Form.qml can find and
    // validate this field. "value" aliases the existing selectedTime
    // property (Form checks .text then .value).
    property string errorMessage: ""
    // "default" | "error" | "success"
    property string validationState: "default"
    property bool required: false
    property alias value: root.selectedTime
    property int minuteStep: 5

    signal timeSelected(date newTime)

    implicitWidth: 160
    implicitHeight: ThemeManager.controlHeight

    readonly property var hourList: {
        var arr = []
        for (var h = 1; h <= 12; h++) arr.push(h)
        return arr
    }
    readonly property var minuteList: {
        var arr = []
        for (var m = 0; m < 60; m += root.minuteStep) arr.push(m)
        return arr
    }

    function _get12Hour(d) {
        var h = d.getHours() % 12
        return h === 0 ? 12 : h
    }
    function _getPeriod(d) {
        return d.getHours() < 12 ? "AM" : "PM"
    }
    function _pad2(n) {
        return n < 10 ? "0" + n : n.toString()
    }

    function _setHour(h12) {
        var d = new Date(root.selectedTime)
        var period = _getPeriod(root.selectedTime)
        var h24 = (h12 % 12) + (period === "PM" ? 12 : 0)
        d.setHours(h24)
        root.selectedTime = d
        root.timeSelected(d)
    }
    function _setMinute(m) {
        var d = new Date(root.selectedTime)
        d.setMinutes(m)
        root.selectedTime = d
        root.timeSelected(d)
    }
    function _setPeriod(period) {
        var d = new Date(root.selectedTime)
        var h = d.getHours()
        var isPM = h >= 12
        if (period === "PM" && !isPM) d.setHours(h + 12)
        else if (period === "AM" && isPM) d.setHours(h - 12)
        root.selectedTime = d
        root.timeSelected(d)
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
                text: LocalizationUtil.formatTime(root.selectedTime)
                font.family: "Poppins"
                font.pixelSize: 14
                color: ThemeManager.textPrimary
            }

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                name: "clock"
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
        width: 240
        padding: ThemeManager.spacing12

        readonly property real _naturalHeight: 260

        function _reposition() {
            var win = root.Window.window
            var winHeight = win ? win.height : 600
            var triggerBottomOnWindow = triggerBg.mapToItem(null, 0, triggerBg.height).y
            var triggerTopOnWindow = triggerBg.mapToItem(null, 0, 0).y
            var margin = 16
            var spaceBelow = winHeight - triggerBottomOnWindow - margin
            var spaceAbove = triggerTopOnWindow - margin

            if (spaceBelow >= Math.min(_naturalHeight, 200) || spaceBelow >= spaceAbove) {
                y = triggerBg.height
                height = Math.max(160, Math.min(_naturalHeight, spaceBelow))
            } else {
                height = Math.max(160, Math.min(_naturalHeight, spaceAbove))
                y = -height
            }
        }

        onAboutToShow: {
            _reposition()
            var hIdx = root.hourList.indexOf(root._get12Hour(root.selectedTime))
            if (hIdx >= 0) hourListView.positionViewAtIndex(hIdx, ListView.Center)
            var mIdx = root.minuteList.indexOf(root.selectedTime.getMinutes())
            if (mIdx >= 0) minuteListView.positionViewAtIndex(mIdx, ListView.Center)
        }

        background: Rectangle {
            radius: 0
            border.width: 1
            border.color: ThemeManager.borderDefault
            color: ThemeManager.backgroundSurface
        }

        contentItem: Column {
            spacing: ThemeManager.spacing8

            Row {
                width: parent.width
                spacing: ThemeManager.spacing8

                // ---------- Hour column ----------
                Column {
                    width: (parent.width - 2 * ThemeManager.spacing8) / 3
                    spacing: ThemeManager.spacing8
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "caption"; text: "Hour" }
                    Rectangle {
                        width: parent.width
                        height: 180
                        radius: 0
                        border.width: 1
                        border.color: ThemeManager.borderDefault
                        color: ThemeManager.backgroundSurface

                        ListView {
                            id: hourListView
                            anchors.fill: parent
                            clip: true
                            model: root.hourList

                            Basic.ScrollBar.vertical: Basic.ScrollBar {
                                policy: Basic.ScrollBar.AsNeeded
                            }

                            delegate: Rectangle {
                                width: hourListView.width
                                height: ThemeManager.rowHeight
                                readonly property bool isSelected: modelData === root._get12Hour(root.selectedTime)
                                color: isSelected ? ThemeManager.accentPrimary : "transparent"
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.toString()
                                    font.family: "Poppins"
                                    font.pixelSize: 13
                                    color: isSelected ? "#FFFFFF" : ThemeManager.textPrimary
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: root._setHour(modelData)
                                }
                            }
                        }
                    }
                }

                // ---------- Minute column ----------
                Column {
                    width: (parent.width - 2 * ThemeManager.spacing8) / 3
                    spacing: ThemeManager.spacing8
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "caption"; text: "Min" }
                    Rectangle {
                        width: parent.width
                        height: 180
                        radius: 0
                        border.width: 1
                        border.color: ThemeManager.borderDefault
                        color: ThemeManager.backgroundSurface

                        ListView {
                            id: minuteListView
                            anchors.fill: parent
                            clip: true
                            model: root.minuteList

                            Basic.ScrollBar.vertical: Basic.ScrollBar {
                                policy: Basic.ScrollBar.AsNeeded
                            }

                            delegate: Rectangle {
                                width: minuteListView.width
                                height: ThemeManager.rowHeight
                                readonly property bool isSelected: modelData === root.selectedTime.getMinutes()
                                color: isSelected ? ThemeManager.accentPrimary : "transparent"
                                Text {
                                    anchors.centerIn: parent
                                    text: root._pad2(modelData)
                                    font.family: "Poppins"
                                    font.pixelSize: 13
                                    color: isSelected ? "#FFFFFF" : ThemeManager.textPrimary
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: root._setMinute(modelData)
                                }
                            }
                        }
                    }
                }

                // ---------- AM/PM column (reuses SegmentedControl) ----------
                Column {
                    width: (parent.width - 2 * ThemeManager.spacing8) / 3
                    spacing: ThemeManager.spacing8
                    AppText { anchors.horizontalCenter: parent.horizontalCenter; variant: "caption"; text: "Period" }
                    SegmentedControl {
                        width: parent.width
                        options: [
                            { value: "AM", label: "AM" },
                            { value: "PM", label: "PM" }
                        ]
                        currentValue: root._getPeriod(root.selectedTime)
                        onCurrentValueChanged: root._setPeriod(currentValue)
                    }
                }
            }

            Basic.Button {
                width: parent.width
                text: "Done"
                onClicked: popup.close()
            }
        }
    }
}
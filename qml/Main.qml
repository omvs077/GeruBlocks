import QtQuick
import QtQuick.Window
import GeruBlocks

Window {
    width: 800
    height: 600
    visible: true
    title: "Geru Blocks"
    color: ThemeManager.backgroundPage

    Column {
        anchors.centerIn: parent
        spacing: ThemeManager.spacing24

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Geru Blocks"
            color: ThemeManager.textPrimary
            font.pixelSize: ThemeManager.spacing24
            font.weight: Font.DemiBold
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Mode: " + (ThemeManager.mode === ThemeManager.HighContrast
                                ? "High Contrast"
                                : (ThemeManager.isDark ? "Dark" : "Light"))
            color: ThemeManager.textSecondary
            font.pixelSize: 14
        }

        // TEMP — sanity-check button, sharp corners per spec, remove before Step 2 begins
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 220
            height: ThemeManager.controlHeight
            radius: 0
            color: toggleArea.pressed ? ThemeManager.accentPrimaryPressed : ThemeManager.accentPrimary
            border.width: ThemeManager.borderWidthDefault
            border.color: ThemeManager.borderDefault

            Text {
                anchors.centerIn: parent
                text: "Toggle Light / Dark"
                color: "#FFFFFF"
                font.pixelSize: 14
                font.weight: Font.Medium
            }

            MouseArea {
                id: toggleArea
                anchors.fill: parent
                onClicked: ThemeManager.toggleLightDark()
            }
        }

        // TEMP — quick density check, remove before Step 2 begins
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Row height @ current density: " + ThemeManager.rowHeight + "px"
            color: ThemeManager.textSecondary
            font.pixelSize: 12
        }

        // TEMP — LocalizationUtil sanity check, remove before Step 2 begins
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: LocalizationUtil.formatCurrency(12345670) + " | " +
                  LocalizationUtil.formatDate(new Date()) + " | " +
                  LocalizationUtil.formatTime(new Date())
            color: ThemeManager.textPrimary
            font.pixelSize: 12
        }

        // TEMP — font weight test, remove before Step 2 begins
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Header"
            font.family: "Poppins SemiBold"
            font.pixelSize: 24
            color: ThemeManager.textPrimary
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Title"
            font.family: "Poppins Medium"
            font.pixelSize: 16
            color: ThemeManager.textPrimary
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Base"
            font.family: "Poppins"
            font.pixelSize: 14
            color: ThemeManager.textPrimary
        }

        // TEMP — Devanagari shaping test, remove before Step 2 begins
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "गेरू ब्लॉक्स"
            font.family: "Poppins"
            font.pixelSize: 20
            font.weight: Font.Medium
            color: ThemeManager.textPrimary
        }
    }
}
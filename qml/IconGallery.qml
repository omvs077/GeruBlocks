import QtQuick
import QtQuick.Controls.Basic
import GeruBlocks

// IconGallery — Stage 2 verification tool, TEMP: remove after icon review.
// Displays all 252 icons through the actual Icon component (mask +
// colorization) in a scrollable grid, so problems can be caught visually
// in one pass rather than checking files individually.

Rectangle {
    anchors.fill: parent
    color: ThemeManager.backgroundPage

    property var iconNames: [
        "bookmark",
        "calendar",
        "card_view",
        "clock",
        "dashboard",
        "external_link",
        "globe",
        "grid",
        "heart",
        "help",
        "home",
        "info",
        "kebab",
        "launch",
        "layers",
        "list_view",
        "location_pin",
        "map",
        "meatball",
        "menu",
        "navigation",
        "notification",
        "notification_active",
        "profile",
        "search",
        "settings",
        "share",
        "star",
        "terminal",
        "users",
        "add",
        "checkmark",
        "close",
        "copy",
        "cut",
        "download",
        "edit",
        "export",
        "eye",
        "eye_closed",
        "filter",
        "history",
        "import_",
        "key",
        "lock",
        "login",
        "logout",
        "paste",
        "pin",
        "print",
        "redo",
        "refresh",
        "save",
        "search_check",
        "sort",
        "sync",
        "terminal_exec",
        "trash",
        "tune",
        "undo",
        "unlock",
        "unpin",
        "upload",
        "zoom_in",
        "zoom_out",
        "attachment",
        "book",
        "briefcase",
        "camera",
        "certificate",
        "crown",
        "diamond",
        "document",
        "file_code",
        "file_pdf",
        "file_text",
        "file_zip",
        "folder",
        "folder_add",
        "folder_shared",
        "gift",
        "headphones",
        "image",
        "link",
        "medal",
        "microphone",
        "music",
        "newspaper",
        "presentation",
        "trophy",
        "unlink",
        "video",
        "volume_high",
        "volume_low",
        "volume_mute",
        "bag",
        "bank",
        "bar_chart",
        "barcode",
        "calculator",
        "cart",
        "cash",
        "coin",
        "credit_card",
        "delivery_truck",
        "line_chart",
        "package",
        "package_open",
        "percent",
        "pie_chart",
        "piggy_bank",
        "qr_code",
        "receipt",
        "safe",
        "storefront",
        "tag",
        "ticket",
        "trending_down",
        "trending_up",
        "wallet",
        "at_sign",
        "chat_bubble",
        "chat_bubbles",
        "flag",
        "hashtag",
        "id_card",
        "mail",
        "mail_open",
        "megaphone",
        "phone_call",
        "phone_missed",
        "send",
        "sparkles",
        "thumbs_down",
        "thumbs_up",
        "user_add",
        "user_check",
        "user_remove",
        "user_x",
        "video_call",
        "battery_charging",
        "battery_full",
        "battery_low",
        "block",
        "bluetooth",
        "cloud",
        "cloud_download",
        "cloud_off",
        "cloud_upload",
        "cpu",
        "critical_alarm",
        "database",
        "desktop",
        "error",
        "fingerprint",
        "hard_drive",
        "help_circle",
        "info_circle",
        "kernel_os_core",
        "laptop",
        "lightning_bolt",
        "memory_ram",
        "mobile_phone",
        "moon",
        "process",
        "server",
        "sun",
        "tablet",
        "verified",
        "warning",
        "watch",
        "wifi_high",
        "wifi_low",
        "wifi_off",
        "arrow_down",
        "arrow_down_left",
        "arrow_down_right",
        "arrow_left",
        "arrow_right",
        "arrow_up",
        "arrow_up_left",
        "arrow_up_right",
        "caret_down",
        "caret_left",
        "caret_right",
        "caret_up",
        "chevron_down",
        "chevron_left",
        "chevron_right",
        "chevron_up",
        "corner_down_left",
        "corner_down_right",
        "double_chevron_left",
        "double_chevron_right",
        "drag_handle",
        "enter",
        "escape",
        "expand",
        "move",
        "refresh_alt",
        "scroll_down",
        "shrink",
        "switch_horizontal",
        "switch_vertical",
        "airplay",
        "cast",
        "eject",
        "equalizer",
        "fast_forward",
        "pause",
        "play",
        "repeat",
        "repeat_one",
        "rewind",
        "shuffle",
        "skip_next",
        "skip_previous",
        "stop",
        "subtitles",
        "align_center",
        "align_justify",
        "align_left",
        "align_right",
        "bold",
        "font_family",
        "font_size",
        "indent_decrease",
        "indent_increase",
        "italic",
        "list_bulleted",
        "list_numbered",
        "strikethrough",
        "text_format",
        "underline",
        "file_audio",
        "file_config",
        "file_csv",
        "file_error",
        "file_excel",
        "file_font",
        "file_image",
        "file_locked",
        "file_shared",
        "file_starred",
        "file_video",
        "folder_download",
        "folder_empty",
        "folder_error",
        "folder_locked",
        "folder_starred",
        "folder_upload",
        "folder_zip"
    ]

    Column {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        Row {
            spacing: 12
            Text {
                text: "Icon Gallery — " + iconNames.length + " icons"
                font.family: "Poppins SemiBold"
                font.pixelSize: 18
                color: ThemeManager.textPrimary
            }
            Rectangle {
                width: 140; height: 32
                color: toggleArea.pressed ? ThemeManager.accentPrimaryPressed : ThemeManager.accentPrimary
                border.width: ThemeManager.borderWidthDefault
                border.color: ThemeManager.borderDefault
                Text {
                    anchors.centerIn: parent
                    text: "Toggle Theme"
                    color: "#FFFFFF"
                    font.pixelSize: 12
                }
                MouseArea {
                    id: toggleArea
                    anchors.fill: parent
                    onClicked: ThemeManager.toggleLightDark()
                }
            }
        }

        GridView {
            width: parent.width
            height: parent.height - 50
            cellWidth: 88
            cellHeight: 88
            clip: true
            model: iconNames

            delegate: Rectangle {
                width: 84
                height: 84
                color: ThemeManager.backgroundSurface
                border.width: 1
                border.color: ThemeManager.borderDefault

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    Icon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        name: modelData
                        size: 28
                        color: ThemeManager.textPrimary
                    }

                    Text {
                        width: 80
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        font.pixelSize: 8
                        color: ThemeManager.textSecondary
                        wrapMode: Text.WrapAnywhere
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}

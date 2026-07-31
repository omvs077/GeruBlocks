pragma Singleton
import QtQuick

// ToastManager — Step 4 Overlays & App Shell
//
// Pure-QML singleton (not C++-backed like ThemeManager/LocalizationUtil)
// — this is just UI queue state (a list of active toasts + their
// auto-dismiss timers), no reason to reach for C++ for that. Needs
// `pragma Singleton` and to be listed in QML_FILES same as any other
// component; Qt6's qt_add_qml_module handles the registration from that
// pragma automatically.
//
// Exposes a ListModel so any ListView/Repeater watching `model` updates
// reactively on append/remove, rather than manually managing a JS array
// and hand-rolled change signals.
//
// Callable from anywhere in the app once imported:
//   ToastManager.show("Zone saved successfully", "success")
//   ToastManager.show("Failed to connect to sensor", "error", 6000)

QtObject {
    id: root

    readonly property ListModel model: ListModel {}

    // type: "neutral" | "success" | "error"
    function show(message, type, durationMs) {
        model.append({
            message: message,
            type: type || "neutral",
            durationMs: durationMs || 4000,
        })
    }

    function dismissAt(index) {
        if (index >= 0 && index < model.count) {
            model.remove(index)
        }
    }
}

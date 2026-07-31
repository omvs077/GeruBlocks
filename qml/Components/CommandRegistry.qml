pragma Singleton
import QtQuick

// CommandRegistry — Step 4 Overlays & App Shell
//
// Pure-QML singleton, same pattern as ToastManager. Any part of the app
// registers commands here; CommandPalette searches/executes against
// this list rather than owning command definitions itself, so the
// palette UI stays decoupled from what commands actually exist.
//
// Usage:
//   CommandRegistry.register("save-zone", "Save Zone", "Actions", "save", "Ctrl+S", function() { ... })

QtObject {
    id: root

    readonly property ListModel commands: ListModel {}
    property var _actions: ({})

    function register(id, title, category, iconName, shortcutText, action) {
        commands.append({
            commandId: id,
            title: title,
            category: category || "",
            iconName: iconName || "",
            shortcutText: shortcutText || ""
        })
        _actions[id] = action
    }

    function execute(id) {
        if (_actions[id]) _actions[id]()
    }
}

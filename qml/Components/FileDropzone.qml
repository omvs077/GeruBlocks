import QtQuick
import QtQuick.Dialogs
import GeruBlocks

// FileDropzone — Step 6, STUB (batch 4 of 4)
// No naming collision. Drag-and-drop accept plus click-to-browse via
// Qt6's native QtQuick.Dialogs FileDialog. Border is solid, not dashed
// — QML Rectangle has no native dashed-border support; a true dashed
// border would need a Canvas/Shape-based implementation in the real
// pass if the spec calls for that visual language. FLAGGED, not
// resolved here.
// NEW DEPENDENCY: this file requires the Qt6::QuickDialogs2 module,
// which is NOT yet in CMakeLists.txt — see accompanying CMake edit.

Rectangle {
    id: root
    implicitWidth: 320
    implicitHeight: 120
    radius: 0
    color: dropArea.containsDrag ? ThemeManager.backgroundPage : ThemeManager.backgroundSurface
    border.width: 1
    border.color: dropArea.containsDrag ? ThemeManager.accentPrimary : ThemeManager.borderStrong

    property var selectedFiles: []
    signal filesDropped(var urls)

    Column {
        anchors.centerIn: parent
        spacing: ThemeManager.spacing8

        Icon {
            anchors.horizontalCenter: parent.horizontalCenter
            name: "upload"
            size: 24
            color: ThemeManager.textSecondary
        }
        AppText {
            anchors.horizontalCenter: parent.horizontalCenter
            variant: "caption"
            text: root.selectedFiles.length > 0
                ? root.selectedFiles.length + " file(s) selected"
                : "Drag files here or click to browse"
        }
    }

    DropArea {
        id: dropArea
        anchors.fill: parent
        onDropped: (drop) => {
            if (drop.hasUrls) {
                root.selectedFiles = drop.urls
                root.filesDropped(drop.urls)
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: fileDialog.open()
    }

    FileDialog {
        id: fileDialog
        fileMode: FileDialog.OpenFiles
        onAccepted: {
            root.selectedFiles = fileDialog.selectedFiles
            root.filesDropped(fileDialog.selectedFiles)
        }
    }
}
import QtQuick
import QtQuick.Controls as QC
import GeruBlocks

// AppRadioGroup — Step 5, STUB (batch scaffolding pass)
// Wraps AppRadioButton instances generated from `model`
// ([{value, label}, ...]), managing mutual exclusivity via QQC2's
// ButtonGroup. Vertical layout only — FLAGGED ASSUMPTION, not
// spec-stated (spec just says "Radio group").

Column {
    id: root
    spacing: ThemeManager.spacing8

    property var model: []
    property string currentValue: model.length > 0 ? model[0].value : ""

    QC.ButtonGroup { id: group }

    Repeater {
        model: root.model
        delegate: AppRadioButton {
            text: modelData.label
            checked: modelData.value === root.currentValue
            QC.ButtonGroup.group: group
            onCheckedChanged: if (checked) root.currentValue = modelData.value
        }
    }
}
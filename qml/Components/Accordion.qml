import QtQuick
import GeruBlocks

// Accordion — Step 8 Navigation
//
// Container for AccordionSection.qml children. Coordinates "only one
// section open at a time" (allowMultiple: false, the default) the same
// way MenuBar.qml coordinates "only one top-level menu open at once" —
// only the parent can correctly arbitrate exclusivity across siblings,
// so each section doesn't try to police its neighbors itself.
//
// Uses the same child-scanning + dynamic signal-connecting pattern as
// Form.qml (scan children for a recognizable shape, connect a closure
// per child in Component.onCompleted) rather than a new mechanism.
//
// Usage:
//   Accordion {
//       AccordionSection { title: "Details"; expanded: true
//           AppText { text: "..." }
//       }
//       AccordionSection { title: "Settings"
//           AppCheckbox { text: "..." }
//       }
//   }

Column {
    id: root

    default property alias content: contentColumn.children
    property bool allowMultiple: false
    spacing: 0

    Column {
        id: contentColumn
        width: root.width
        spacing: 0
    }

    function _sections() {
        var out = []
        for (var i = 0; i < contentColumn.children.length; i++) {
            var c = contentColumn.children[i]
            if (c.hasOwnProperty("expanded") && c.hasOwnProperty("title") && c.toggled !== undefined) {
                out.push(c)
            }
        }
        return out
    }

    Component.onCompleted: {
        var list = _sections()
        for (var i = 0; i < list.length; i++) {
            list[i].toggled.connect((function(section) {
                return function() {
                    if (!root.allowMultiple) {
                        var all = root._sections()
                        for (var j = 0; j < all.length; j++) {
                            if (all[j] !== section) all[j].expanded = false
                        }
                    }
                    section.expanded = !section.expanded
                }
            })(list[i]))
        }
    }
}

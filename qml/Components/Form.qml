import QtQuick
import GeruBlocks

// Form — field layout + validation orchestration (Step 6, Geru Blocks)
//
// THIN WRAPPER: Form does not instantiate field types. It scans children
// for a contract:
//   validationState (string)  "default" | "error" | "success"
//   errorMessage    (string)
//   required        (bool, optional, default false)
//   text OR value                        — field's current content
//   validationType  (string, optional)   "text" | "email" | "password" |
//                                         "phone" | "custom" (default "text")
//   minLength / maxLength (int, optional)
//   validator       (function, optional) value => true | "error message"
//
// CONTRACT NOW COVERS: AppTextInput, AppPhoneInput, AppCheckbox (boolean),
// Select, AppCombobox, AppTextArea, FileDropzone (array), DatePicker,
// TimePicker (date). Each field type needed different "empty" handling —
// see _isEmpty() and _validateField() below — a checkbox's "empty" is
// `false`, a dropzone's is `[]`, a date picker's is never really empty
// (it always holds a Date), etc. Handled per-type rather than pretending
// one string-emptiness check covers all of them.
//
// FORMAT CHECKS ARE DELIBERATELY SIMPLE, FLAGGED NOT LOCKED:
//   - email: standard "something@something.something" shape, not full
//     RFC 5322.
//   - password: length >= minLength (default 8) + at least one uppercase
//     + at least one digit — a common baseline, not a stated spec
//     requirement.
//   - phone: 6–15 digits after stripping non-digits — a loose sanity
//     check, not real per-country validation.
//
// Validation trigger: on blur (per-field) + full pass on submit().
// Submit mechanism: no built-in button — call form.submit() yourself.

Column {
    id: root

    default property alias content: contentColumn.children
    property alias fieldSpacing: contentColumn.spacing

    // True after the most recent validate()/submit() pass found no errors.
    property bool isValid: true

    // PROPOSAL, not requested explicitly: once a field passes validation
    // on blur, mark it validationState "success" (green border) rather
    // than leaving it "default". Turn off if that reads as too noisy.
    property bool showSuccessState: true

    signal accepted()
    signal rejected(var errors)

    spacing: ThemeManager.spacing24

    Column {
        id: contentColumn
        width: root.width
        spacing: ThemeManager.spacing16
    }

    // --- Field discovery -------------------------------------------------

    function _hasContract(item) {
        return item && item.hasOwnProperty("validationState")
            && item.hasOwnProperty("errorMessage")
    }

    function _collectFields(item, out) {
        for (let i = 0; i < item.children.length; i++) {
            const child = item.children[i]
            if (_hasContract(child)) {
                out.push(child)
            }
            if (child.children && child.children.length > 0) {
                _collectFields(child, out)
            }
        }
        return out
    }

    // Returns the live list of every field Form currently recognizes.
    function fields() {
        return _collectFields(contentColumn, [])
    }

    function _fieldRequired(field) {
        return field.required === true
    }

    function _fieldType(field) {
        return field.validationType !== undefined ? field.validationType : "text"
    }

    function _fieldValue(field) {
        if (field.text !== undefined) return field.text
        if (field.value !== undefined) return field.value
        return undefined
    }

    // "Empty" means something different per value type:
    //   string  -> "" (or undefined/null)
    //   boolean -> false (an unchecked required checkbox/switch)
    //   array   -> length 0 (an empty FileDropzone selection)
    //   Date    -> never treated as empty; DatePicker/TimePicker always
    //     hold a real Date once constructed, so "required" on those
    //     doesn't mean much beyond "the field must exist," which it
    //     already does. Left non-empty deliberately rather than
    //     inventing a fake "unset" sentinel.
    function _isEmpty(value) {
        if (value === undefined || value === null) return true
        if (typeof value === "boolean") return value === false
        if (Array.isArray(value)) return value.length === 0
        if (value instanceof Date) return false
        return value === ""
    }

    // --- Format checks -------------------------------------------------

    // Returns null if valid, or an error-message string if not.
    // Only runs for string-valued fields — booleans/arrays/dates don't
    // have a "format," just a required/not-required check.
    function _runTypeCheck(field, value) {
        if (typeof value !== "string") return null

        const type = _fieldType(field)

        if (type === "email") {
            const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
            if (!re.test(value)) return "Enter a valid email address"
        }

        if (type === "password") {
            const minLen = field.minLength !== undefined ? field.minLength : 8
            if (value.length < minLen) return "Must be at least " + minLen + " characters"
            if (!/[A-Z]/.test(value)) return "Include at least one uppercase letter"
            if (!/[0-9]/.test(value)) return "Include at least one number"
        }

        if (type === "phone") {
            const digits = value.replace(/[^0-9]/g, "")
            if (digits.length < 6 || digits.length > 15) return "Enter a valid phone number"
        }

        if (field.minLength !== undefined && type !== "password" && value.length < field.minLength) {
            return "Must be at least " + field.minLength + " characters"
        }
        if (field.maxLength !== undefined && value.length > field.maxLength) {
            return "Must be at most " + field.maxLength + " characters"
        }

        if (field.validator !== undefined && field.validator !== null) {
            const result = field.validator(value)
            if (result !== true) return (typeof result === "string") ? result : "Invalid value"
        }

        return null
    }

    // --- Validation --------------------------------------------------

    // Validates one field in place (used for on-blur checks and submit).
    function _validateField(field) {
        const value = _fieldValue(field)
        const empty = _isEmpty(value)

        if (_fieldRequired(field) && empty) {
            field.validationState = "error"
            if (field.errorMessage === "" || field.errorMessage === undefined) {
                field.errorMessage = (typeof value === "boolean")
                    ? "This is required"
                    : "This field is required"
            }
            return false
        }

        if (empty) {
            field.validationState = "default"
            field.errorMessage = ""
            return true
        }

        const typeError = _runTypeCheck(field, value)
        if (typeError) {
            field.validationState = "error"
            field.errorMessage = typeError
            return false
        }

        field.validationState = root.showSuccessState ? "success" : "default"
        field.errorMessage = ""
        return true
    }

    // Full pass over every recognized field without submitting. Returns
    // an array of { field, message } for anything currently invalid.
    function validate() {
        const list = fields()
        const errors = []

        for (let i = 0; i < list.length; i++) {
            const field = list[i]
            if (!_validateField(field)) {
                errors.push({ field: field, message: field.errorMessage })
            }
        }

        return errors
    }

    // --- Submit / reset ----------------------------------------------

    function submit() {
        const errors = validate()
        root.isValid = errors.length === 0

        if (errors.length === 0) {
            root.accepted()
        } else {
            root.rejected(errors)
            if (errors[0].field.forceActiveFocus) {
                errors[0].field.forceActiveFocus()
            }
        }

        return errors.length === 0
    }

    function reset() {
        const list = fields()
        for (let i = 0; i < list.length; i++) {
            const field = list[i]
            const current = _fieldValue(field)
            if (typeof current === "boolean") {
                if (field.checked !== undefined) field.checked = false
            } else if (Array.isArray(current)) {
                if (field.value !== undefined) field.value = []
            } else if (field.text !== undefined) {
                field.text = ""
            }
            if (field.validationState !== undefined) field.validationState = "default"
            if (field.errorMessage !== undefined) field.errorMessage = ""
        }
        root.isValid = true
    }

    // --- Wire up on-blur validation for every discovered field --------

    Component.onCompleted: {
        const list = fields()
        for (let i = 0; i < list.length; i++) {
            const field = list[i]
            if (field.activeFocusChanged) {
                field.activeFocusChanged.connect((function(f) {
                    return function() {
                        if (!f.activeFocus) {
                            root._validateField(f)
                        }
                    }
                })(field))
            }
        }
    }
}

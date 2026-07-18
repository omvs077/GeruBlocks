# Geru Blocks

An original, India-native, OS-grade design system — Windows 10 structural clarity fused with Warli folk-art geometric grammar (circle/triangle/line). C++ / Qt / QML reference implementation.

Full specification: see `docs/Geru-Blocks-Design-System-Specification.docx` (copy this in from your Claude Projects download — treat it as the authoritative source of truth for all design decisions).

## Build status

**Stage 1 — Project scaffold.** Confirms the CMake + Qt/QML build pipeline works end to end. `ThemeManager` and `LocalizationUtil` are stubs — real implementation lands in Stage 2 (Foundation).

## Requirements

- Qt 6.7+ (Core, Gui, Qml, Quick, QuickControls2)
- CMake 3.21+
- A C++17 compiler (MSVC recommended on Windows)

## Build

```powershell
cmake -B build -S . -DCMAKE_PREFIX_PATH="C:\Qt\6.7.0\msvc2019_64"
cmake --build build
```

## Build stages

1. **Project scaffold** — this milestone. Blank window, builds and runs.
2. **Foundation** — Theme (light/dark/high-contrast), density modes, localization utility, full icon set. Review gate before anything else proceeds.
3. **Component waves A–F** — 72 components across 13 steps, per the spec's Section 6.
4. **Integration pass** — real demo screen assembling components together.
5. **Documentation website** — only after the package works.

#pragma once

#include <QObject>
#include <QColor>
#include <QtQml/qqmlregistration.h>

class QQmlEngine;
class QJSEngine;

// ThemeManager — Geru Blocks Stage 2 Foundation
//
// Exposes light / dark / high-contrast color tokens and
// compact / comfortable / spacious density tokens to QML as a singleton.
//
// Source of truth: Geru-Blocks-Design-System-Specification.docx
//   Section 3.1  Color System
//   Section 3.3  Spacing & Layout Grid
//   Section 3.6  Motion & Interaction
//   Section 7.3  Density Modes
//   Section 8     Accessibility (high-contrast, focus ring, reduced motion)
//
// NOTE ON HIGH-CONTRAST COLORS (confirmed with Ommy):
// High-contrast mode reuses the dark theme's accent/status colors as-is
// (#3D74E0 accent, #2E9B57 success, #D64545 error) rather than inventing
// separate high-contrast variants — verified these already clear WCAG AA
// (4.5:1) against pure black. Background/text/border use pure black/white
// per Section 8's "no grays" rule. border.strong (dark) and
// background.panel (light) are also confirmed — see ThemeManager.cpp.

class ThemeManager : public QObject
{
    Q_OBJECT
        QML_ELEMENT
        QML_SINGLETON

        // --- Mode ---
        Q_PROPERTY(ThemeMode mode READ mode WRITE setMode NOTIFY themeChanged)
        Q_PROPERTY(DensityMode density READ density WRITE setDensity NOTIFY densityChanged)
        Q_PROPERTY(bool isDark READ isDark NOTIFY themeChanged)
        Q_PROPERTY(bool glassEnabled READ glassEnabled NOTIFY themeChanged)
        // NOTE: Qt's QStyleHints has no OS-level "reduce motion" query as of
        // 6.11 (I initially assumed one existed — it doesn't). This is a
        // plain app-level setting for now; wire it to a real OS signal later
        // if/when one becomes available on your target platforms, or drive
        // it from an in-app accessibility setting instead.
        Q_PROPERTY(bool reducedMotion READ reducedMotion WRITE setReducedMotion NOTIFY reducedMotionChanged)

        // --- Color tokens (Section 3.1) ---
        Q_PROPERTY(QColor backgroundPage READ backgroundPage NOTIFY themeChanged)
        Q_PROPERTY(QColor backgroundSurface READ backgroundSurface NOTIFY themeChanged)
        Q_PROPERTY(QColor backgroundPanel READ backgroundPanel NOTIFY themeChanged)
        Q_PROPERTY(QColor borderDefault READ borderDefault NOTIFY themeChanged)
        Q_PROPERTY(QColor borderStrong READ borderStrong NOTIFY themeChanged)
        Q_PROPERTY(QColor textPrimary READ textPrimary NOTIFY themeChanged)
        Q_PROPERTY(QColor textSecondary READ textSecondary NOTIFY themeChanged)

        Q_PROPERTY(QColor accentPrimary READ accentPrimary NOTIFY themeChanged)
        Q_PROPERTY(QColor accentPrimaryPressed READ accentPrimaryPressed NOTIFY themeChanged)
        // Tags / urgent badges / warning icons ONLY — never a UI surface (Governance Principle 4)
        Q_PROPERTY(QColor accentSecondary READ accentSecondary NOTIFY themeChanged)

        // Scoped strictly to status indicators — dots, badges, table status cells (Section 3.1)
        Q_PROPERTY(QColor statusSuccess READ statusSuccess NOTIFY themeChanged)
        Q_PROPERTY(QColor statusError READ statusError NOTIFY themeChanged)

        // --- Border width (thicker in high-contrast, Section 8) ---
        Q_PROPERTY(int borderWidthDefault READ borderWidthDefault NOTIFY themeChanged)

        // --- Focus ring (Section 8: 2px accent outline, 3px offset) ---
        Q_PROPERTY(QColor focusRingColor READ focusRingColor NOTIFY themeChanged)
        Q_PROPERTY(int focusRingWidth READ focusRingWidth CONSTANT)
        Q_PROPERTY(int focusRingOffset READ focusRingOffset CONSTANT)

        // --- Elevation tokens (Section 3.1) ---
        // Exposed as alpha (0-1) + blur radius + y-offset per level, since QML
        // has no native CSS box-shadow string; components compose these into
        // a drop-shadow effect or layered Rectangle.
        Q_PROPERTY(qreal elevation1Alpha READ elevation1Alpha CONSTANT)
        Q_PROPERTY(int elevation1Blur READ elevation1Blur CONSTANT)
        Q_PROPERTY(int elevation1YOffset READ elevation1YOffset CONSTANT)

        Q_PROPERTY(qreal elevation2Alpha READ elevation2Alpha CONSTANT)
        Q_PROPERTY(int elevation2Blur READ elevation2Blur CONSTANT)
        Q_PROPERTY(int elevation2YOffset READ elevation2YOffset CONSTANT)

        Q_PROPERTY(qreal elevation3Alpha READ elevation3Alpha CONSTANT)
        Q_PROPERTY(int elevation3Blur READ elevation3Blur CONSTANT)
        Q_PROPERTY(int elevation3YOffset READ elevation3YOffset CONSTANT)

        // --- Density tokens (Section 7.3) ---
        Q_PROPERTY(int rowHeight READ rowHeight NOTIFY densityChanged)
        Q_PROPERTY(int densityPadding READ densityPadding NOTIFY densityChanged)

        // --- Spacing scale (Section 3.3 — fixed, not density-dependent) ---
        Q_PROPERTY(int spacing4 READ spacing4 CONSTANT)
        Q_PROPERTY(int spacing8 READ spacing8 CONSTANT)
        Q_PROPERTY(int spacing12 READ spacing12 CONSTANT)
        Q_PROPERTY(int spacing16 READ spacing16 CONSTANT)
        Q_PROPERTY(int spacing24 READ spacing24 CONSTANT)
        Q_PROPERTY(int spacing32 READ spacing32 CONSTANT)
        Q_PROPERTY(int spacing48 READ spacing48 CONSTANT)
        Q_PROPERTY(int spacing64 READ spacing64 CONSTANT)
        Q_PROPERTY(int controlHeight READ controlHeight CONSTANT)
        Q_PROPERTY(int cardGutter READ cardGutter CONSTANT)
        Q_PROPERTY(int sectionSpacing READ sectionSpacing CONSTANT)

        // --- Motion (Section 3.6) ---
        // QML anim "easing.bezierCurve" wants 6 numbers (two control points);
        // cubic-bezier(0.16, 1, 0.3, 1) maps directly: [0.16, 1, 0.3, 1, 1, 1]
        Q_PROPERTY(int durationMicro READ durationMicro CONSTANT)
        Q_PROPERTY(int durationFast READ durationFast CONSTANT)
        Q_PROPERTY(int durationBase READ durationBase CONSTANT)
        Q_PROPERTY(int durationSlow READ durationSlow CONSTANT)
        Q_PROPERTY(int durationPanel READ durationPanel CONSTANT)

public:
    enum class ThemeMode { Light, Dark, HighContrast };
    Q_ENUM(ThemeMode)

        enum class DensityMode { Compact, Comfortable, Spacious };
    Q_ENUM(DensityMode)

        explicit ThemeManager(QObject* parent = nullptr);

    // Required by QML_SINGLETON for C++-instantiated singletons
    static ThemeManager* create(QQmlEngine* qmlEngine, QJSEngine* jsEngine);

    ThemeMode mode() const { return m_mode; }
    void setMode(ThemeMode mode);

    DensityMode density() const { return m_density; }
    void setDensity(DensityMode density);

    bool isDark() const;
    bool glassEnabled() const;
    bool reducedMotion() const { return m_reducedMotion; }
    void setReducedMotion(bool value);

    QColor backgroundPage() const;
    QColor backgroundSurface() const;
    QColor backgroundPanel() const;
    QColor borderDefault() const;
    QColor borderStrong() const;
    QColor textPrimary() const;
    QColor textSecondary() const;

    QColor accentPrimary() const;
    QColor accentPrimaryPressed() const;
    QColor accentSecondary() const;

    QColor statusSuccess() const;
    QColor statusError() const;

    int borderWidthDefault() const;

    QColor focusRingColor() const;
    int focusRingWidth() const { return 2; }
    int focusRingOffset() const { return 3; }

    qreal elevation1Alpha() const { return 0.08; }
    int elevation1Blur() const { return 2; }
    int elevation1YOffset() const { return 1; }

    qreal elevation2Alpha() const { return 0.12; }
    int elevation2Blur() const { return 12; }
    int elevation2YOffset() const { return 4; }

    qreal elevation3Alpha() const { return 0.18; }
    int elevation3Blur() const { return 24; }
    int elevation3YOffset() const { return 8; }

    int rowHeight() const;
    int densityPadding() const;

    int spacing4() const { return 4; }
    int spacing8() const { return 8; }
    int spacing12() const { return 12; }
    int spacing16() const { return 16; }
    int spacing24() const { return 24; }
    int spacing32() const { return 32; }
    int spacing48() const { return 48; }
    int spacing64() const { return 64; }
    int controlHeight() const { return 32; }
    int cardGutter() const { return 16; }
    int sectionSpacing() const { return 24; }

    int durationMicro() const { return 100; }
    int durationFast() const { return 150; }
    int durationBase() const { return 200; }
    int durationSlow() const { return 250; }
    int durationPanel() const { return 320; }

    // Invokable so QML (e.g. a theme-toggle icon button) can flip modes directly
    Q_INVOKABLE void toggleLightDark();

signals:
    void themeChanged();
    void densityChanged();
    void reducedMotionChanged();

private:
    ThemeMode m_mode = ThemeMode::Light;
    DensityMode m_density = DensityMode::Comfortable;
    bool m_reducedMotion = false;
};
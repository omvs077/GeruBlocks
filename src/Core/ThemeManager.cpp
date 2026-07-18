#include "ThemeManager.h"

#include <QQmlEngine>

ThemeManager::ThemeManager(QObject* parent)
    : QObject(parent)
{
    // m_reducedMotion defaults to false (see header note — no OS-level
    // "reduce motion" query exists in Qt as of 6.11). Toggle it via
    // setReducedMotion() from an in-app accessibility setting.
}

ThemeManager* ThemeManager::create(QQmlEngine* qmlEngine, QJSEngine* jsEngine)
{
    Q_UNUSED(jsEngine)
        auto* manager = new ThemeManager();
    QQmlEngine::setObjectOwnership(manager, QQmlEngine::CppOwnership);
    Q_UNUSED(qmlEngine)
        return manager;
}

void ThemeManager::setReducedMotion(bool value)
{
    if (value == m_reducedMotion)
        return;
    m_reducedMotion = value;
    emit reducedMotionChanged();
}

void ThemeManager::setMode(ThemeMode mode)
{
    if (m_mode == mode)
        return;
    m_mode = mode;
    emit themeChanged();
}

void ThemeManager::setDensity(DensityMode density)
{
    if (m_density == density)
        return;
    m_density = density;
    emit densityChanged();
}

void ThemeManager::toggleLightDark()
{
    // Only toggles between Light and Dark; High-Contrast is opted into
    // explicitly (e.g. via a system-accessibility setting or menu item),
    // not cycled through casually.
    setMode(m_mode == ThemeMode::Dark ? ThemeMode::Light : ThemeMode::Dark);
}

bool ThemeManager::isDark() const
{
    return m_mode == ThemeMode::Dark || m_mode == ThemeMode::HighContrast;
}

bool ThemeManager::glassEnabled() const
{
    // Section 8: "glass material disabled entirely" in high-contrast mode
    return m_mode != ThemeMode::HighContrast;
}

// ---------------------------------------------------------------------
// Color tokens — values transcribed exactly from Spec Section 3.1.
// High-Contrast values are a first-pass implementation only (see header
// note) and are NOT locked; confirm with Ommy before treating as final.
// ---------------------------------------------------------------------

QColor ThemeManager::backgroundPage() const
{
    switch (m_mode) {
    case ThemeMode::Light:        return QColor("#F4F4F5");
    case ThemeMode::Dark:         return QColor("#1A1A1D");
    case ThemeMode::HighContrast: return QColor("#000000");
    }
    return QColor();
}

QColor ThemeManager::backgroundSurface() const
{
    switch (m_mode) {
    case ThemeMode::Light:        return QColor("#FFFFFF");
    case ThemeMode::Dark:         return QColor("#222225");
    case ThemeMode::HighContrast: return QColor("#000000");
    }
    return QColor();
}

QColor ThemeManager::backgroundPanel() const
{
    switch (m_mode) {
        // Confirmed with Ommy: white is already the light theme's brightness
        // ceiling, so panel = surface. Popover/panel depth is conveyed via
        // elevation.3 (shadow), not a color difference — see elevation tokens.
    case ThemeMode::Light:        return QColor("#FFFFFF");
    case ThemeMode::Dark:         return QColor("#2A2A2E");
    case ThemeMode::HighContrast: return QColor("#000000");
    }
    return QColor();
}

QColor ThemeManager::borderDefault() const
{
    switch (m_mode) {
    case ThemeMode::Light:        return QColor("#E4E4E5");
    case ThemeMode::Dark:         return QColor("#38383D");
    case ThemeMode::HighContrast: return QColor("#FFFFFF");
    }
    return QColor();
}

QColor ThemeManager::borderStrong() const
{
    switch (m_mode) {
    case ThemeMode::Light:        return QColor("#BFC0C0");
        // Confirmed with Ommy: #55555C gives better distinguishability from
        // border.default (#38383D) than the original placeholder.
    case ThemeMode::Dark:         return QColor("#55555C");
    case ThemeMode::HighContrast: return QColor("#FFFFFF");
    }
    return QColor();
}

QColor ThemeManager::textPrimary() const
{
    switch (m_mode) {
    case ThemeMode::Light:        return QColor("#2D3142");
    case ThemeMode::Dark:         return QColor("#F2F2F3");
    case ThemeMode::HighContrast: return QColor("#FFFFFF");
    }
    return QColor();
}

QColor ThemeManager::textSecondary() const
{
    switch (m_mode) {
    case ThemeMode::Light:        return QColor("#6B6E7A");
    case ThemeMode::Dark:         return QColor("#A6A6AC");
        // High-contrast mode: "no grays" per Section 8 — secondary text
        // collapses to primary white rather than a muted tone.
    case ThemeMode::HighContrast: return QColor("#FFFFFF");
    }
    return QColor();
}

QColor ThemeManager::accentPrimary() const
{
    switch (m_mode) {
    case ThemeMode::Light:        return QColor("#1A5FD7");
    case ThemeMode::Dark:         return QColor("#3D74E0");
    case ThemeMode::HighContrast: return QColor("#3D74E0");
    }
    return QColor();
}

QColor ThemeManager::accentPrimaryPressed() const
{
    // Same across all themes per spec (Section 3.1)
    return QColor("#14479E");
}

QColor ThemeManager::accentSecondary() const
{
    // Tags / urgent badges / warning icons ONLY — never a UI surface.
    // Same across all themes per spec (Section 3.1).
    return QColor("#F26327");
}

QColor ThemeManager::statusSuccess() const
{
    return QColor("#2E9B57");
}

QColor ThemeManager::statusError() const
{
    return QColor("#D64545");
}

int ThemeManager::borderWidthDefault() const
{
    // Section 8: high-contrast mode uses thicker borders
    return m_mode == ThemeMode::HighContrast ? 2 : 1;
}

QColor ThemeManager::focusRingColor() const
{
    return accentPrimary();
}

// ---------------------------------------------------------------------
// Density tokens — Section 7.3
// ---------------------------------------------------------------------

int ThemeManager::rowHeight() const
{
    switch (m_density) {
    case DensityMode::Compact:     return 32;
    case DensityMode::Comfortable: return 40;
    case DensityMode::Spacious:    return 48;
    }
    return 40;
}

int ThemeManager::densityPadding() const
{
    switch (m_density) {
    case DensityMode::Compact:     return 12;
    case DensityMode::Comfortable: return 16;
    case DensityMode::Spacious:    return 20;
    }
    return 16;
}
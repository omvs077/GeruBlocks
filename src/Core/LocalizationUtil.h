#pragma once

#include <QObject>
#include <QDate>
#include <QTime>
#include <QDateTime>
#include <QtQml/qqmlregistration.h>

class QQmlEngine;
class QJSEngine;

// LocalizationUtil — Geru Blocks Stage 2 Foundation
//
// India-locale formatting exposed to QML as a singleton.
// Source of truth: Geru-Blocks-Design-System-Specification.docx, Section 9.
//
//   Number grouping | Indian system — 12,34,567 (Lakh/Crore)
//   Currency        | ₹ prefix, Indian grouping, e.g. ₹1,23,45,670.00
//   Date format     | DD/MM/YYYY
//   Time format     | 12-hour default; 24-hour available as user preference
//   Units           | Metric (°C, meters) — not handled here, no unit
//                     conversion needed since the app is metric-only
//
// NOTE: Only time format is documented as user-toggleable in the spec.
// Date format / number grouping / currency are fixed India defaults with
// no alternate mode described — so those are NOT exposed as runtime
// toggles here. If you want a locale switch later, that's a new decision
// to make explicitly, not something to infer from this ticket.

class LocalizationUtil : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    // Section 9: "12-hour with AM/PM default; 24-hour available as user preference"
    Q_PROPERTY(bool use24HourTime READ use24HourTime WRITE setUse24HourTime NOTIFY timeFormatChanged)

public:
    explicit LocalizationUtil(QObject *parent = nullptr);

    static LocalizationUtil *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);

    bool use24HourTime() const { return m_use24HourTime; }
    void setUse24HourTime(bool value);

    // --- Number / currency ---

    // Indian digit grouping, e.g. 12345678 -> "1,23,45,678"
    // decimals: how many decimal places to show (0 for plain counts)
    Q_INVOKABLE QString formatNumber(double value, int decimals = 0) const;

    // ₹ prefix + Indian grouping + 2 decimal places, e.g. "₹1,23,45,670.00"
    Q_INVOKABLE QString formatCurrency(double value) const;

    // --- Date / time ---

    // DD/MM/YYYY, e.g. "14/07/2026"
    Q_INVOKABLE QString formatDate(const QDate &date) const;

    // Respects use24HourTime: "02:30 PM" or "14:30"
    Q_INVOKABLE QString formatTime(const QTime &time) const;

    // Combined date + time using the two formatters above
    Q_INVOKABLE QString formatDateTime(const QDateTime &dateTime) const;

    Q_INVOKABLE void toggleTimeFormat();

signals:
    void timeFormatChanged();

private:
    QString groupIndianDigits(const QString &digits) const;

    bool m_use24HourTime = false; // Section 9: 12-hour is the default
};

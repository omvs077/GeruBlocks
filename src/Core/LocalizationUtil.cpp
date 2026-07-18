#include "LocalizationUtil.h"

#include <QQmlEngine>
#include <QStringList>
#include <cmath>

LocalizationUtil::LocalizationUtil(QObject *parent)
    : QObject(parent)
{
}

LocalizationUtil *LocalizationUtil::create(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    Q_UNUSED(jsEngine)
    Q_UNUSED(qmlEngine)
    auto *util = new LocalizationUtil();
    QQmlEngine::setObjectOwnership(util, QQmlEngine::CppOwnership);
    return util;
}

void LocalizationUtil::setUse24HourTime(bool value)
{
    if (value == m_use24HourTime)
        return;
    m_use24HourTime = value;
    emit timeFormatChanged();
}

void LocalizationUtil::toggleTimeFormat()
{
    setUse24HourTime(!m_use24HourTime);
}

// Groups a plain digit string (no sign, no decimal point) using the
// Indian numbering system: the last 3 digits stand alone, then every
// group of 2 digits moving left. E.g. "12345678" -> "1,23,45,678"
QString LocalizationUtil::groupIndianDigits(const QString &digits) const
{
    if (digits.length() <= 3)
        return digits;

    QString last3 = digits.right(3);
    QString rest = digits.left(digits.length() - 3);

    QStringList groups;
    while (rest.length() > 2) {
        groups.prepend(rest.right(2));
        rest.chop(2);
    }
    if (!rest.isEmpty())
        groups.prepend(rest);

    return groups.join(",") + "," + last3;
}

QString LocalizationUtil::formatNumber(double value, int decimals) const
{
    bool negative = value < 0;
    double absValue = std::fabs(value);

    // QString::number with 'f' handles rounding to the requested decimals
    QString fixed = QString::number(absValue, 'f', decimals);

    QString integerPart;
    QString fractionalPart;
    int dotIndex = fixed.indexOf('.');
    if (dotIndex >= 0) {
        integerPart = fixed.left(dotIndex);
        fractionalPart = fixed.mid(dotIndex + 1);
    } else {
        integerPart = fixed;
    }

    QString grouped = groupIndianDigits(integerPart);

    QString result = grouped;
    if (!fractionalPart.isEmpty())
        result += "." + fractionalPart;

    return (negative ? QStringLiteral("-") : QString()) + result;
}

QString LocalizationUtil::formatCurrency(double value) const
{
    // ₹ prefix, Indian grouping, always 2 decimal places (Section 9 example:
    // ₹1,23,45,670.00). Sign goes before the ₹ symbol for negative amounts,
    // e.g. "-₹500.00" — not locked by the spec explicitly, but matches how
    // Indian banking apps commonly render negative currency.
    bool negative = value < 0;
    QString formatted = formatNumber(std::fabs(value), 2);
    return (negative ? QStringLiteral("-") : QString()) + QStringLiteral("\u20B9") + formatted;
}

QString LocalizationUtil::formatDate(const QDate &date) const
{
    return date.toString("dd/MM/yyyy");
}

QString LocalizationUtil::formatTime(const QTime &time) const
{
    return m_use24HourTime ? time.toString("HH:mm") : time.toString("hh:mm AP");
}

QString LocalizationUtil::formatDateTime(const QDateTime &dateTime) const
{
    return formatDate(dateTime.date()) + " " + formatTime(dateTime.time());
}

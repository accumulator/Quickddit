#include "appsettings.h"

#include <QtCore/QSettings>

AppSettings::AppSettings(QObject *parent) :
    QObject(parent), m_settings(new QSettings(this))
{
    m_whiteTheme = m_settings->value("whiteTheme", false).toBool();
    m_fontSize = static_cast<FontSize>(m_settings->value("fontSize", 1).toInt());
    m_refreshToken = m_settings->value("refreshToken").toByteArray();
}

bool AppSettings::whiteTheme() const
{
    return m_whiteTheme;
}

void AppSettings::setWhiteTheme(bool whiteTheme)
{
    if (m_whiteTheme != whiteTheme) {
        m_whiteTheme = whiteTheme;
        m_settings->setValue("whiteTheme", m_whiteTheme);
        emit whiteThemeChanged();
    }
}

AppSettings::FontSize AppSettings::fontSize() const
{
    return m_fontSize;
}

void AppSettings::setFontSize(AppSettings::FontSize fontSize)
{
    if (m_fontSize != fontSize) {
        m_fontSize = fontSize;
        m_settings->setValue("fontSize", static_cast<int>(m_fontSize));
        emit fontSizeChanged();
    }
}

QByteArray AppSettings::refreshToken() const
{
    return m_refreshToken;
}

void AppSettings::setRefreshToken(const QByteArray &token)
{
    m_refreshToken = token;

    if (!m_refreshToken.isEmpty())
        m_settings->setValue("refreshToken", m_refreshToken);
    else
        m_settings->remove("refreshToken");
}

bool AppSettings::hasRefreshToken() const
{
    return !m_refreshToken.isEmpty();
}

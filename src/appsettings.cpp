/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see [http://www.gnu.org/licenses/].
*/

#include "appsettings.h"

#include <QtCore/QSettings>

AppSettings::AppSettings(QObject *parent) :
    QObject(parent), m_settings(new QSettings(this))
{
    m_whiteTheme = m_settings->value("whiteTheme", false).toBool();
    m_fontSize = static_cast<FontSize>(m_settings->value("fontSize", 1).toInt());
    m_redditUsername = m_settings->value("redditUsername").toString();
    m_refreshToken = m_settings->value("refreshToken").toByteArray();
    m_orientationProfile = static_cast<OrientationProfile>(m_settings->value("orientationProfile", 0).toInt());
    m_lastSeenMessage = m_settings->value("lastSeenMessage").toString();
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

QString AppSettings::redditUsername() const
{
    return m_redditUsername;
}

void AppSettings::setRedditUsername(const QString &username)
{
    m_redditUsername = username;

    if (!m_redditUsername.isEmpty())
        m_settings->setValue("redditUsername", m_redditUsername);
    else
        m_settings->remove("redditUsername");
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

AppSettings::OrientationProfile AppSettings::orientationProfile() const
{
    return m_orientationProfile;
}

void AppSettings::setOrientationProfile(const AppSettings::OrientationProfile profile)
{
    if (m_orientationProfile != profile) {
        m_orientationProfile = profile;
        m_settings->setValue("orientationProfile", m_orientationProfile);
        emit orientationProfileChanged();
    }
}

QString AppSettings::lastSeenMessage() const
{
    return m_lastSeenMessage;
}

void AppSettings::setLastSeenMessage(const QString &lastSeenMessage)
{
    if (m_lastSeenMessage != lastSeenMessage) {
        m_lastSeenMessage = lastSeenMessage;
        m_settings->setValue("lastSeenMessage", m_lastSeenMessage);
    }
}

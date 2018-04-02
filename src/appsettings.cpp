/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2015-2018  Sander van Grieken

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
#include <QDebug>

AppSettings::AppSettings(QObject *parent) :
    QObject(parent), m_settings(new QSettings(this))
{
    m_whiteTheme = m_settings->value("whiteTheme", false).toBool();
    m_fontSize = static_cast<FontSize>(m_settings->value("fontSize", AppSettings::SmallFontSize).toInt());
    m_redditUsername = m_settings->value("redditUsername").toString();
    m_refreshToken = m_settings->value("refreshToken").toByteArray();
    m_orientationProfile = static_cast<OrientationProfile>(m_settings->value("orientationProfile", AppSettings::DynamicProfile).toInt());
    m_lastSeenMessage = m_settings->value("lastSeenMessage").toString();
    m_pollUnread = m_settings->value("pollUnread", true).toBool();
    m_thumbnailScale = static_cast<ThumbnailScale>(m_settings->value("thumbnailScale", AppSettings::ScaleAuto).toInt());
    m_loopVideos = m_settings->value("loopVideos", false).toBool();
    m_subredditSection = m_settings->value("subredditSection", 0).toInt();
    m_commentSort = m_settings->value("commentSort", 0).toInt();
    m_useTor = m_settings->value("useTor", false).toBool();
    m_preferredVideoSize = static_cast<VideoSize>(m_settings->value("preferredVideoSize", AppSettings::VS360).toInt());
    m_filteredSubreddits = m_settings->value("filteredSubreddits").toStringList();

    // read accounts
    m_accounts = QList<AccountData>();
    int size = m_settings->beginReadArray("accounts");
    for (int i = 0; i < size; ++i) {
        m_settings->setArrayIndex(i);
        AccountData data;
        data.accountName = m_settings->value("acctUsername").toString();
        data.refreshToken = m_settings->value("acctRefreshToken").toByteArray();
        data.lastSeenMessage = m_settings->value("acctLastSeenMessage").toString();
        m_accounts.append(data);
    }
    m_settings->endArray();

    // if no account list yet, initialize with current account, if set.
    if (m_accounts.size() == 0 && !m_refreshToken.isEmpty()) {
        QList<AccountData> initial_accounts = QList<AccountData>();
        AccountData data;
        data.accountName = m_redditUsername;
        data.refreshToken = m_refreshToken;
        data.lastSeenMessage = m_lastSeenMessage;
        initial_accounts.append(data);
        setAccounts(initial_accounts);
    }
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
    if (m_redditUsername != username) {
        m_redditUsername = username;
        if (!m_redditUsername.isEmpty())
            m_settings->setValue("redditUsername", m_redditUsername);
        else
            m_settings->remove("redditUsername");
        emit usernameChanged();
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

bool AppSettings::pollUnread() const
{
    return m_pollUnread;
}

void AppSettings::setPollUnread(const bool pollUnread)
{
    if (m_pollUnread != pollUnread) {
        m_pollUnread = pollUnread;
        m_settings->setValue("pollUnread", m_pollUnread);
        emit pollUnreadChanged();
    }
}

AppSettings::ThumbnailScale AppSettings::thumbnailScale() const
{
    return m_thumbnailScale;
}

void AppSettings::setThumbnailScale(const AppSettings::ThumbnailScale scale)
{
    if (m_thumbnailScale != scale) {
        m_thumbnailScale = scale;
        m_settings->setValue("thumbnailScale", m_thumbnailScale);
        emit thumbnailScaleChanged();
    }
}

bool AppSettings::loopVideos() const
{
    return m_loopVideos;
}

void AppSettings::setLoopVideos(const bool loopVideos)
{
    if (m_loopVideos != loopVideos) {
        m_loopVideos = loopVideos;
        m_settings->setValue("loopVideos", m_loopVideos);
        emit loopVideosChanged();
    }
}

int AppSettings::subredditSection() const
{
    return m_subredditSection;
}

void AppSettings::setSubredditSection(const int subredditSection)
{
    if (m_subredditSection != subredditSection) {
        m_subredditSection = subredditSection;
        m_settings->setValue("subredditSection", m_subredditSection);
        emit subredditSectionChanged();
    }
}

int AppSettings::commentSort() const
{
    return m_commentSort;
}

void AppSettings::setCommentSort(const int commentSort)
{
    if (m_commentSort != commentSort) {
        m_commentSort = commentSort;
        m_settings->setValue("commentSort", m_commentSort);
        emit commentSortChanged();
    }
}

bool AppSettings::useTor() const
{
    return m_useTor;
}

void AppSettings::setUseTor(const bool useTor)
{
    if (m_useTor != useTor) {
        m_useTor = useTor;
        m_settings->setValue("useTor", m_useTor);
        emit useTorChanged();
    }
}

AppSettings::VideoSize AppSettings::preferredVideoSize() const
{
    return m_preferredVideoSize;
}

void AppSettings::setPreferredVideoSize(const AppSettings::VideoSize preferredVideoSize)
{
    if (m_preferredVideoSize != preferredVideoSize) {
        m_preferredVideoSize = preferredVideoSize;
        m_settings->setValue("preferredVideoSize", m_preferredVideoSize);
        emit preferredVideoSizeChanged();
    }
}

QList<AppSettings::AccountData> AppSettings::accounts() const
{
    return m_accounts;
}

QStringList AppSettings::accountNames() const
{
    QStringList result;
    for (int i = 0; i < m_accounts.size(); ++i) {
        result.append(m_accounts.at(i).accountName);
    }
    return result;
}

void AppSettings::setAccounts(const QList<AppSettings::AccountData> accounts)
{
    m_accounts = accounts;

    m_settings->beginWriteArray("accounts");
    for (int i = 0; i < m_accounts.size(); ++i) {
        m_settings->setArrayIndex(i);
        m_settings->setValue("acctUsername", m_accounts.at(i).accountName);
        m_settings->setValue("acctRefreshToken", m_accounts.at(i).refreshToken);
        m_settings->setValue("acctLastSeenMessage", m_accounts.at(i).lastSeenMessage);
    }
    m_settings->endArray();
    emit accountsChanged();
}

void AppSettings::removeAccount(const QString& accountName)
{
    QList<AccountData> accountlist = accounts();
    for (int i = 0; i < accountlist.size(); ++i) {
        if (accountlist.at(i).accountName == accountName) {
            accountlist.removeAt(i);
            setAccounts(accountlist);
            break;
        }
    }
}

QStringList AppSettings::filteredSubreddits() const
{
    return m_filteredSubreddits;
}

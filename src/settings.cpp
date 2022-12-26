/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2015-2019  Sander van Grieken

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

#include "settings.h"

#include <QtCore/QSettings>
#include <QDebug>

Settings::Settings(QObject *parent) :
    QObject(parent), m_settings(new QSettings(this))
{
    m_commentsTapToHide = m_settings->value("commentsTapToHide", true).toBool();
    m_fontSize = static_cast<FontSize>(m_settings->value("fontSize", Settings::SmallFontSize).toInt());
    m_redditUsername = m_settings->value("redditUsername").toString();
    m_refreshToken = m_settings->value("refreshToken").toByteArray();
    m_orientationProfile = static_cast<OrientationProfile>(m_settings->value("orientationProfile", Settings::DynamicProfile).toInt());
    m_lastSeenMessage = m_settings->value("lastSeenMessage").toString();
    m_pollUnread = m_settings->value("pollUnread", true).toBool();
    m_thumbnailScale = static_cast<ThumbnailScale>(m_settings->value("thumbnailScale", Settings::ScaleAuto).toInt());
    m_showLinkType = m_settings->value("showLinkType", false).toBool();
    m_loopVideos = m_settings->value("loopVideos", false).toBool();
    m_subredditSection = m_settings->value("subredditSection", 0).toInt();
    m_messageSection = m_settings->value("messageSection", 0).toInt();
    m_commentSort = m_settings->value("commentSort", 0).toInt();
    m_useTor = m_settings->value("useTor", false).toBool();
    m_preferredVideoSize = static_cast<VideoSize>(m_settings->value("preferredVideoSize", Settings::VS360).toInt());
    m_filteredSubreddits = m_settings->value("filteredSubreddits").toStringList();

    int size;

    // read subreddit prefs
    m_subredditPrefs = QList<SubredditPrefs>();
    size = m_settings->beginReadArray("subredditPrefs");
    for (int i = 0; i < size; ++i) {
        m_settings->setArrayIndex(i);
        SubredditPrefs prefs;
        prefs.relPath = m_settings->value("relPath").toString();
        prefs.section = m_settings->value("section").toInt();
        prefs.sectionTimeRange = m_settings->value("sectionTimeRange").toInt();
        m_subredditPrefs.append(prefs);
    }
    m_settings->endArray();

    // read accounts
    m_accounts = QList<AccountData>();
    size = m_settings->beginReadArray("accounts");
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

bool Settings::commentsTapToHide() const
{
    return m_commentsTapToHide;
}

void Settings::setCommentsTapToHide(bool commentsTapToHide)
{
    if (m_commentsTapToHide != commentsTapToHide) {
        m_commentsTapToHide = commentsTapToHide;
        m_settings->setValue("commentsTapToHide", m_commentsTapToHide);
        emit commentsTapToHideChanged();
    }
}

Settings::FontSize Settings::fontSize() const
{
    return m_fontSize;
}

void Settings::setFontSize(Settings::FontSize fontSize)
{
    if (m_fontSize != fontSize) {
        m_fontSize = fontSize;
        m_settings->setValue("fontSize", static_cast<int>(m_fontSize));
        emit fontSizeChanged();
    }
}

QString Settings::redditUsername() const
{
    return m_redditUsername;
}

void Settings::setRedditUsername(const QString &username)
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

QByteArray Settings::refreshToken() const
{
    return m_refreshToken;
}

void Settings::setRefreshToken(const QByteArray &token)
{
    m_refreshToken = token;

    if (!m_refreshToken.isEmpty())
        m_settings->setValue("refreshToken", m_refreshToken);
    else
        m_settings->remove("refreshToken");
}

bool Settings::hasRefreshToken() const
{
    return !m_refreshToken.isEmpty();
}

Settings::OrientationProfile Settings::orientationProfile() const
{
    return m_orientationProfile;
}

void Settings::setOrientationProfile(const Settings::OrientationProfile profile)
{
    if (m_orientationProfile != profile) {
        m_orientationProfile = profile;
        m_settings->setValue("orientationProfile", m_orientationProfile);
        emit orientationProfileChanged();
    }
}

QString Settings::lastSeenMessage() const
{
    return m_lastSeenMessage;
}

void Settings::setLastSeenMessage(const QString &lastSeenMessage)
{
    if (m_lastSeenMessage != lastSeenMessage) {
        m_lastSeenMessage = lastSeenMessage;
        m_settings->setValue("lastSeenMessage", m_lastSeenMessage);
    }
}

bool Settings::pollUnread() const
{
    return m_pollUnread;
}

void Settings::setPollUnread(const bool pollUnread)
{
    if (m_pollUnread != pollUnread) {
        m_pollUnread = pollUnread;
        m_settings->setValue("pollUnread", m_pollUnread);
        emit pollUnreadChanged();
    }
}

Settings::ThumbnailScale Settings::thumbnailScale() const
{
    return m_thumbnailScale;
}

void Settings::setThumbnailScale(const Settings::ThumbnailScale scale)
{
    if (m_thumbnailScale != scale) {
        m_thumbnailScale = scale;
        m_settings->setValue("thumbnailScale", m_thumbnailScale);
        emit thumbnailScaleChanged();
    }
}

bool Settings::showLinkType() const
{
    return m_showLinkType;
}

void Settings::setShowLinkType(const bool showLinkType)
{
    if (m_showLinkType != showLinkType) {
        m_showLinkType = showLinkType;
        m_settings->setValue("showLinkType", m_showLinkType);
        emit showLinkTypeChanged();
    }
}

bool Settings::loopVideos() const
{
    return m_loopVideos;
}

void Settings::setLoopVideos(const bool loopVideos)
{
    if (m_loopVideos != loopVideos) {
        m_loopVideos = loopVideos;
        m_settings->setValue("loopVideos", m_loopVideos);
        emit loopVideosChanged();
    }
}

int Settings::subredditSection() const
{
    return m_subredditSection;
}

void Settings::setSubredditSection(const int subredditSection)
{
    if (m_subredditSection != subredditSection) {
        m_subredditSection = subredditSection;
        m_settings->setValue("subredditSection", m_subredditSection);
        emit subredditSectionChanged();
    }
}

int Settings::messageSection() const
{
    return m_messageSection;
}

void Settings::setMessageSection(const int messageSection)
{
    if (m_messageSection != messageSection) {
        m_messageSection = messageSection;
        m_settings->setValue("messageSection", m_messageSection);
        emit messageSectionChanged();
    }
}

int Settings::commentSort() const
{
    return m_commentSort;
}

void Settings::setCommentSort(const int commentSort)
{
    if (m_commentSort != commentSort) {
        m_commentSort = commentSort;
        m_settings->setValue("commentSort", m_commentSort);
        emit commentSortChanged();
    }
}

bool Settings::useTor() const
{
    return m_useTor;
}

void Settings::setUseTor(const bool useTor)
{
    if (m_useTor != useTor) {
        m_useTor = useTor;
        m_settings->setValue("useTor", m_useTor);
        emit useTorChanged();
    }
}

Settings::VideoSize Settings::preferredVideoSize() const
{
    return m_preferredVideoSize;
}

void Settings::setPreferredVideoSize(const Settings::VideoSize preferredVideoSize)
{
    if (m_preferredVideoSize != preferredVideoSize) {
        m_preferredVideoSize = preferredVideoSize;
        m_settings->setValue("preferredVideoSize", m_preferredVideoSize);
        emit preferredVideoSizeChanged();
    }
}

QList<Settings::SubredditPrefs> Settings::subredditPrefs() const
{
    return m_subredditPrefs;
}

void Settings::setSubredditPrefs(const QList<SubredditPrefs> subredditPrefs)
{
    m_subredditPrefs = subredditPrefs;

    m_settings->beginWriteArray("subredditPrefs", m_subredditPrefs.size());
    for (int i = 0; i < m_subredditPrefs.size(); ++i) {
        m_settings->setArrayIndex(i);
        m_settings->setValue("relPath", m_subredditPrefs.at(i).relPath);
        m_settings->setValue("section", m_subredditPrefs.at(i).section);
        m_settings->setValue("sectionTimeRange", m_subredditPrefs.at(i).sectionTimeRange);
    }
    m_settings->endArray();
    emit subredditPrefsChanged();
}

QList<Settings::AccountData> Settings::accounts() const
{
    return m_accounts;
}

QStringList Settings::accountNames() const
{
    QStringList result;
    for (int i = 0; i < m_accounts.size(); ++i) {
        result.append(m_accounts.at(i).accountName);
    }
    return result;
}

void Settings::setAccounts(const QList<Settings::AccountData> accounts)
{
    m_accounts = accounts;

    m_settings->beginWriteArray("accounts", m_accounts.size());
    for (int i = 0; i < m_accounts.size(); ++i) {
        m_settings->setArrayIndex(i);
        m_settings->setValue("acctUsername", m_accounts.at(i).accountName);
        m_settings->setValue("acctRefreshToken", m_accounts.at(i).refreshToken);
        m_settings->setValue("acctLastSeenMessage", m_accounts.at(i).lastSeenMessage);
    }
    m_settings->endArray();
    emit accountsChanged();
}

void Settings::removeAccount(const QString& accountName)
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

QStringList Settings::filteredSubreddits() const
{
    return m_filteredSubreddits;
}

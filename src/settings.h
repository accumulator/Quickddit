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

#ifndef APPSETTINGS_H
#define APPSETTINGS_H

#include <QtCore/QObject>
#include <QtCore/QStringList>

class QSettings;

class Settings : public QObject
{
    Q_OBJECT
    Q_ENUMS(FontSize)
    Q_ENUMS(OrientationProfile)
    Q_ENUMS(ThumbnailScale)
    Q_ENUMS(VideoSize)
    Q_PROPERTY(bool commentsTapToHide READ commentsTapToHide WRITE setCommentsTapToHide NOTIFY commentsTapToHideChanged)
    Q_PROPERTY(FontSize fontSize READ fontSize WRITE setFontSize NOTIFY fontSizeChanged)
    Q_PROPERTY(QString redditUsername READ redditUsername NOTIFY usernameChanged)
    Q_PROPERTY(OrientationProfile orientationProfile READ orientationProfile WRITE setOrientationProfile NOTIFY orientationProfileChanged)
    Q_PROPERTY(bool pollUnread READ pollUnread WRITE setPollUnread NOTIFY pollUnreadChanged)
    Q_PROPERTY(ThumbnailScale thumbnailScale READ thumbnailScale WRITE setThumbnailScale NOTIFY thumbnailScaleChanged)
    Q_PROPERTY(bool showLinkType READ showLinkType WRITE setShowLinkType NOTIFY showLinkTypeChanged)
    Q_PROPERTY(bool loopVideos READ loopVideos WRITE setLoopVideos NOTIFY loopVideosChanged)
    Q_PROPERTY(int subredditSection READ subredditSection WRITE setSubredditSection NOTIFY subredditSectionChanged)
    Q_PROPERTY(int messageSection READ messageSection WRITE setMessageSection NOTIFY messageSectionChanged)
    Q_PROPERTY(int commentSort READ commentSort WRITE setCommentSort NOTIFY commentSortChanged)
    Q_PROPERTY(bool useTor READ useTor WRITE setUseTor NOTIFY useTorChanged)
    Q_PROPERTY(VideoSize preferredVideoSize READ preferredVideoSize WRITE setPreferredVideoSize NOTIFY preferredVideoSizeChanged)
    Q_PROPERTY(QStringList accountNames READ accountNames NOTIFY accountsChanged)

public:
    enum FontSize {
        TinyFontSize = -1,
        SmallFontSize,
        MediumFontSize,
        LargeFontSize
    };

    enum OrientationProfile {
        DynamicProfile = 0,
        PortraitOnlyProfile,
        LandscapeOnlyProfile
    };

    enum ThumbnailScale {
        ScaleAuto,
        Scale100,
        Scale125,
        Scale150,
        Scale175,
        Scale200,
        Scale250
    };

    enum VideoSize {
        VS360,
        VS720
    };

    struct AccountData {
        QString accountName;
        QByteArray refreshToken;
        QString lastSeenMessage;
    };

    struct SubredditPrefs {
        QString relPath;
        int section;
        int sectionTimeRange;
    };

    explicit Settings(QObject *parent = 0);

    bool commentsTapToHide() const;
    void setCommentsTapToHide(bool commentsTapToHide);

    FontSize fontSize() const;
    void setFontSize(FontSize fontSize);

    QString redditUsername() const;
    void setRedditUsername(const QString &username);

    QByteArray refreshToken() const;
    void setRefreshToken(const QByteArray &token);
    bool hasRefreshToken() const;

    OrientationProfile orientationProfile() const;
    void setOrientationProfile(const OrientationProfile profile);

    QString lastSeenMessage() const;
    void setLastSeenMessage(const QString &lastSeenMessage);

    bool pollUnread() const;
    void setPollUnread(const bool pollUnread);

    ThumbnailScale thumbnailScale() const;
    void setThumbnailScale(const ThumbnailScale scale);

    bool showLinkType() const;
    void setShowLinkType(const bool showLinkType);

    bool loopVideos() const;
    void setLoopVideos(const bool loopVideos);

    int subredditSection() const;
    void setSubredditSection(const int subredditSection);

    int messageSection() const;
    void setMessageSection(const int messageSection);

    int commentSort() const;
    void setCommentSort(const int commentSort);

    bool useTor() const;
    void setUseTor(const bool useTor);

    VideoSize preferredVideoSize() const;
    void setPreferredVideoSize(const VideoSize preferredVideoSize);

    QList<SubredditPrefs> subredditPrefs() const;
    void setSubredditPrefs(const QList<SubredditPrefs> subredditPrefs);

    QList<AccountData> accounts() const;
    QStringList accountNames() const;
    void setAccounts(const QList<AccountData> accounts);
    Q_INVOKABLE void removeAccount(const QString& accountName);

    QStringList filteredSubreddits() const;

signals:
    void commentsTapToHideChanged();
    void fontSizeChanged();
    void usernameChanged();
    void orientationProfileChanged();
    void pollUnreadChanged();
    void thumbnailScaleChanged();
    void showLinkTypeChanged();
    void loopVideosChanged();
    void subredditSectionChanged();
    void messageSectionChanged();
    void commentSortChanged();
    void useTorChanged();
    void preferredVideoSizeChanged();
    void subredditPrefsChanged();
    void accountsChanged();

private:
    QSettings *m_settings;

    bool m_commentsTapToHide;
    FontSize m_fontSize;
    QString m_redditUsername;
    QByteArray m_refreshToken;
    OrientationProfile m_orientationProfile;
    QString m_lastSeenMessage;
    bool m_pollUnread;
    ThumbnailScale m_thumbnailScale;
    bool m_showLinkType;
    bool m_loopVideos;
    QStringList m_filteredSubreddits;
    int m_subredditSection;
    int m_messageSection;
    int m_commentSort;
    bool m_useTor;
    VideoSize m_preferredVideoSize;
    QList<SubredditPrefs> m_subredditPrefs;
    QList<AccountData> m_accounts;
};

#endif // APPSETTINGS_H

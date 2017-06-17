/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2015  Sander van Grieken

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

class QSettings;

class AppSettings : public QObject
{
    Q_OBJECT
    Q_ENUMS(FontSize)
    Q_ENUMS(OrientationProfile)
    Q_ENUMS(ThumbnailScale)
    Q_PROPERTY(bool whiteTheme READ whiteTheme WRITE setWhiteTheme NOTIFY whiteThemeChanged)
    Q_PROPERTY(FontSize fontSize READ fontSize WRITE setFontSize NOTIFY fontSizeChanged)
    Q_PROPERTY(QString redditUsername READ redditUsername CONSTANT)
    Q_PROPERTY(OrientationProfile orientationProfile READ orientationProfile WRITE setOrientationProfile NOTIFY orientationProfileChanged)
    Q_PROPERTY(bool pollUnread READ pollUnread WRITE setPollUnread NOTIFY pollUnreadChanged)
    Q_PROPERTY(ThumbnailScale thumbnailScale READ thumbnailScale WRITE setThumbnailScale NOTIFY thumbnailScaleChanged)
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
        Scale200
    };

    explicit AppSettings(QObject *parent = 0);

    bool whiteTheme() const;
    void setWhiteTheme(bool whiteTheme);

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

    QStringList filteredSubreddits() const;

signals:
    void whiteThemeChanged();
    void fontSizeChanged();
    void orientationProfileChanged();
    void pollUnreadChanged();
    void thumbnailScaleChanged();

private:
    QSettings *m_settings;

    bool m_whiteTheme;
    FontSize m_fontSize;
    QString m_redditUsername;
    QByteArray m_refreshToken;
    OrientationProfile m_orientationProfile;
    QString m_lastSeenMessage;
    bool m_pollUnread;
    ThumbnailScale m_thumbnailScale;
    QStringList m_filteredSubreddits;
};

#endif // APPSETTINGS_H

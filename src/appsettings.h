#ifndef APPSETTINGS_H
#define APPSETTINGS_H

#include <QtCore/QObject>

class QSettings;

class AppSettings : public QObject
{
    Q_OBJECT
    Q_ENUMS(FontSize)
    Q_PROPERTY(bool whiteTheme READ whiteTheme WRITE setWhiteTheme NOTIFY whiteThemeChanged)
    Q_PROPERTY(FontSize fontSize READ fontSize WRITE setFontSize NOTIFY fontSizeChanged)
    Q_PROPERTY(QString redditUsername READ redditUsername CONSTANT)
public:
    enum FontSize {
        SmallFontSize = 0,
        MediumFontSize,
        LargeFontSize
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

signals:
    void whiteThemeChanged();
    void fontSizeChanged();

private:
    QSettings *m_settings;

    bool m_whiteTheme;
    FontSize m_fontSize;
    QString m_redditUsername;
    QByteArray m_refreshToken;
};

#endif // APPSETTINGS_H

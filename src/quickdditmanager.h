#ifndef QUICKDDITMANAGER_H
#define QUICKDDITMANAGER_H

#include <QtCore/QObject>
#include <QtCore/QUrl>
#include <QtCore/QDateTime>

class QNetworkReply;
class AppSettings;
class NetworkManager;

class QuickdditManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(AppSettings* settings READ settings WRITE setSettings)
    Q_PROPERTY(bool signedIn READ signedIn NOTIFY signedInChanged)
public:
    explicit QuickdditManager(QObject *parent = 0);
    
    AppSettings *settings() const;
    void setSettings(AppSettings *settings);

    bool signedIn() const;

    /**
     * Create a GET request to Reddit API
     * the signal networkReplyReceived() will be emitted with the QNetworkReply in the parameter
     * if this process failed, the QNetworkReply in the signal networkReplyReceived() will be 0
     * @param relativeUrl the relative url of Reddit without the ".json", eg. "/r/nokia/hot"
     * @param parameters parameters for the request (will be added as query items in the url)
     * @param oauth use oauth for this request. Some endpoint does not support oauth and need to
                    set this to false
     */
    void createRedditGetRequest(const QString &relativeUrl,
                                const QHash<QString, QString> &parameters = QHash<QString,QString>(),
                                bool oauth = true);

    /**
     * Generate an authorization url for signing in by the user (through the broswer)
     */
    Q_INVOKABLE QUrl generateAuthorizationUrl();

    /**
     * Get access token after user have signed in
     * @param signedInUrl the redirected url after user have signed in
     */
    Q_INVOKABLE void getAccessToken(const QUrl &signedInUrl);

    /**
     * Use the refresh token to get a new access token
     */
    Q_INVOKABLE void refreshAccessToken();

    /**
     * Remove the access token and refresh token
     */
    Q_INVOKABLE void signOut();

signals:
    void signedInChanged();
    void accessTokenSuccess();
    void accessTokenFailure(const QString &errorString);
    void networkReplyReceived(QNetworkReply *reply);

private slots:
    void onAccessTokenRequestFinished();
    void onRefreshTokenFinished();

private:
    NetworkManager *m_netManager;
    AppSettings *m_settings;

    QString m_state;
    QNetworkReply *m_accessTokenReply;
    QString m_accessToken;
    QTime m_accessTokenExpiry;

    QString m_relativeUrl;
    QHash<QString, QString> m_parameters;
};

#endif // QUICKDDITMANAGER_H

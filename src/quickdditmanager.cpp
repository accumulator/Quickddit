#include "quickdditmanager.h"

#include <QtCore/QEventLoop>
#include <QtNetwork/QNetworkReply>
#include <qt-json/json.h>

#include "networkmanager.h"
#include "appsettings.h"

// NOT FOR PUBLIC
#define CLIENT_ID ""
#define CLIENT_SECRET ""
#define REDIRECT_URL ""
#define OAUTH_SCOPE "read,mysubreddits"

QuickdditManager::QuickdditManager(QObject *parent) :
    QObject(parent), m_netManager(new NetworkManager(this)), m_settings(0),
    m_accessTokenReply(0)
{
}

AppSettings *QuickdditManager::settings() const
{
    return m_settings;
}

void QuickdditManager::setSettings(AppSettings *settings)
{
    m_settings = settings;
}

bool QuickdditManager::signedIn() const
{
    return (!m_accessToken.isEmpty() && m_settings->hasRefreshToken());
}

void QuickdditManager::createRedditGetRequest(const QString &relativeUrl,
                                              const QHash<QString, QString> &parameters, bool oauth)
{
    QString urlString;
    QByteArray authHeader;

    if (oauth && m_settings->hasRefreshToken()) {
        if (!m_accessToken.isEmpty() && m_accessTokenExpiry.elapsed() < 3600000) {
            urlString = "https://oauth.reddit.com";
            authHeader.append("Bearer " + m_accessToken);
        } else {
            m_relativeUrl = relativeUrl;
            m_parameters = parameters;
            connect(this, SIGNAL(accessTokenSuccess()), SLOT(onRefreshTokenFinished()));
            connect(this, SIGNAL(accessTokenFailure(QString)), SLOT(onRefreshTokenFinished()));
            refreshAccessToken();
            return;
        }
    } else {
        urlString = "http://www.reddit.com";
    }

    urlString += relativeUrl + ".json";

    QUrl url(urlString);

    QHashIterator<QString,QString> i(parameters);
    while (i.hasNext()) {
        i.next();
        url.addQueryItem(i.key(), i.value());
    }

    emit networkReplyReceived(m_netManager->createGetRequest(url, authHeader));
}

QUrl QuickdditManager::generateAuthorizationUrl()
{
    QUrl url("https://ssl.reddit.com/api/v1/authorize");
    url.addQueryItem("response_type", "code");
    url.addQueryItem("client_id", CLIENT_ID);
    url.addQueryItem("redirect_uri", REDIRECT_URL);
    url.addQueryItem("scope", OAUTH_SCOPE);
    url.addQueryItem("duration", "permanent");
    m_state = QString::number(qrand());
    url.addQueryItem("state", m_state);
    return url;
}

void QuickdditManager::getAccessToken(const QUrl &signedInUrl)
{
    // if m_state is empty means generateAuthorizationUrl() is not called first
    Q_ASSERT(!m_state.isEmpty());

    if (m_accessTokenReply != 0) {
        qWarning("QuickdditManager::getAccessToken(): m_accessTokenReply is not 0");
        m_accessTokenReply->disconnect();
        m_accessTokenReply->deleteLater();
        m_accessTokenReply = 0;
    }

    // check state
    if (m_state != signedInUrl.queryItemValue("state")) {
        qCritical("QuickdditManager::getAccessToken(): (OAuth2) state is not matched");
        emit accessTokenFailure("Error: state not match");
        return;
    }

    m_state.clear();

    QUrl accessTokenUrl("https://ssl.reddit.com/api/v1/access_token");

    // generate body
    QUrl accessTokenBody("http://dummy.com");
    accessTokenBody.addQueryItem("code", signedInUrl.queryItemValue("code"));
    accessTokenBody.addQueryItem("grant_type", "authorization_code");
    accessTokenBody.addQueryItem("redirect_uri", REDIRECT_URL);

    // generate basic auth header
    QByteArray authHeader = "Basic ";
    authHeader += (QByteArray(CLIENT_ID) + ":" + QByteArray(CLIENT_SECRET)).toBase64();

    m_accessTokenReply = m_netManager->createPostRequest(accessTokenUrl, accessTokenBody.encodedQuery(),
                                                         authHeader);
    connect(m_accessTokenReply, SIGNAL(finished()), SLOT(onAccessTokenRequestFinished()));
}

void QuickdditManager::refreshAccessToken()
{
    if (m_accessTokenReply != 0) {
        qWarning("QuickdditManager::refreshAccessToken(): m_accessTokenReply is not 0");
        m_accessTokenReply->disconnect();
        m_accessTokenReply->deleteLater();
        m_accessTokenReply = 0;
    }

    QByteArray refreshToken = m_settings->refreshToken();
    Q_ASSERT(!refreshToken.isEmpty());

    QUrl accessTokenUrl("https://ssl.reddit.com/api/v1/access_token");

    // generate body
    QUrl accessTokenBody("http://dummy.com");
    accessTokenBody.addQueryItem("refresh_token", refreshToken);
    accessTokenBody.addQueryItem("grant_type", "refresh_token");
    accessTokenBody.addQueryItem("redirect_uri", REDIRECT_URL);

    // generate basic auth header
    QByteArray authHeader = "Basic ";
    authHeader += (QByteArray(CLIENT_ID) + ":" + QByteArray(CLIENT_SECRET)).toBase64();

    m_accessTokenReply = m_netManager->createPostRequest(accessTokenUrl, accessTokenBody.encodedQuery(),
                                                         authHeader);
    connect(m_accessTokenReply, SIGNAL(finished()), SLOT(onAccessTokenRequestFinished()));
}

void QuickdditManager::signOut()
{
    m_accessToken.clear();
    m_settings->setRefreshToken(QByteArray());
    emit signedInChanged();
}

void QuickdditManager::onAccessTokenRequestFinished()
{
    if (m_accessTokenReply->error() == QNetworkReply::NoError) {
        const QString replyString = QString::fromUtf8(m_accessTokenReply->readAll());

        bool ok;
        const QVariantMap replyJson = QtJson::parse(replyString, ok).toMap();

        Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

        const QString accessToken = replyJson.value("access_token").toString();
        const QString refreshToken = replyJson.value("refresh_token").toString();

        if (!accessToken.isEmpty() && !refreshToken.isEmpty()) {
            m_accessToken = accessToken;
            m_accessTokenExpiry.start();
            m_settings->setRefreshToken(refreshToken.toAscii());
            emit accessTokenSuccess();
            emit signedInChanged();
        } else {
            emit accessTokenFailure("Error: access token or refresh token not found. Please sign in again.");
            qDebug("QuickdditManager::onAccessTokenRequestFinished(): "
                   "Unable to get access token from the following data:\n%s", qPrintable(replyString));
        }
    } else {
        emit accessTokenFailure(m_accessTokenReply->errorString());
    }

    m_accessTokenReply->deleteLater();
    m_accessTokenReply = 0;
}

void QuickdditManager::onRefreshTokenFinished()
{
    disconnect(this, 0, this, SLOT(onRefreshTokenFinished()));

    if (!m_accessToken.isEmpty() && m_accessTokenExpiry.elapsed() < 3600000)
        createRedditGetRequest(m_relativeUrl, m_parameters);
    else
        emit networkReplyReceived(0);

    m_relativeUrl.clear();
    m_parameters.clear();
}

#include "quickdditmanager.h"

#include <QtNetwork/QNetworkReply>
#include <qt-json/json.h>

#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
#include <QtCore/QUrlQuery>
#endif

#include "networkmanager.h"
#include "appsettings.h"

#if !defined(REDDIT_CLIENT_ID) || !defined(REDDIT_CLIENT_SECRET) || !defined(REDDIT_REDIRECT_URL)
// fill these up with your own Reddit client id, secret and redirect url
#define REDDIT_CLIENT_ID ""
#define REDDIT_CLIENT_SECRET ""
#define REDDIT_REDIRECT_URL ""
#endif

#define REDDIT_OAUTH_SCOPE "read,mysubreddits,subscribe,vote,submit,edit,identity"

QuickdditManager::QuickdditManager(QObject *parent) :
    QObject(parent), m_netManager(new NetworkManager(this)), m_settings(0),
    m_accessTokenReply(0), m_userInfoReply(0)
{
}

bool QuickdditManager::isSignedIn() const
{
    return m_settings->hasRefreshToken();
}

AppSettings *QuickdditManager::settings() const
{
    return m_settings;
}

void QuickdditManager::setSettings(AppSettings *settings)
{
    m_settings = settings;
}

QNetworkReply *QuickdditManager::createGetRequest(const QUrl &url, const QByteArray &authHeader)
{
    return m_netManager->createGetRequest(url, authHeader);
}

void QuickdditManager::createRedditRequest(RequestType type, const QString &relativeUrl,
                                           const QHash<QString, QString> &parameters, bool oauth)
{
    QString baseUrl;
    QByteArray authHeader;

    if (oauth && m_settings->hasRefreshToken()) {
        if (!m_accessToken.isEmpty() && m_accessTokenExpiry.elapsed() < 3600000) {
            baseUrl = "https://oauth.reddit.com";
            authHeader.append("Bearer " + m_accessToken);
        } else {
            m_requestType = type;
            m_relativeUrl = relativeUrl;
            m_parameters = parameters;
            connect(this, SIGNAL(accessTokenSuccess()), SLOT(onRefreshTokenFinished()));
            connect(this, SIGNAL(accessTokenFailure(QString)), SLOT(onRefreshTokenFinished()));
            refreshAccessToken();
            return;
        }
    } else {
        baseUrl = "http://www.reddit.com";
    }

    QUrl requestUrl;
    if (type == GET)
        requestUrl = baseUrl + relativeUrl + ".json";
    else if (type == POST)
        requestUrl = baseUrl + relativeUrl;

    QHashIterator<QString,QString> i(parameters);
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
    QUrlQuery query;
    while (i.hasNext()) {
        i.next();
        query.addQueryItem(i.key(), i.value());
    }
#else
    while (i.hasNext()) {
        i.next();
        requestUrl.addQueryItem(i.key(), i.value());
    }
#endif

    if (type == GET) {
        // obey user settings for NSFW filtering
        // this is not documented but found in source:
        // <https://github.com/reddit/reddit/commit/6f9f91e7534db713d2bdd199ededd00598adccc1>
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
        query.addQueryItem("obey_over18", "true");
        requestUrl.setQuery(query);
#else
        requestUrl.addQueryItem("obey_over18", "true");
#endif
        emit networkReplyReceived(m_netManager->createGetRequest(requestUrl, authHeader));
    } else if (type == POST) {
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
        QByteArray data = query.toString(QUrl::FullyEncoded).toLatin1();
#else
        QByteArray data = requestUrl.encodedQuery();
        requestUrl.setEncodedQuery(QByteArray());
#endif
        emit networkReplyReceived(m_netManager->createPostRequest(requestUrl, data, authHeader));
    }
}

QUrl QuickdditManager::generateAuthorizationUrl()
{
    QUrl url("https://ssl.reddit.com/api/v1/authorize.compact");
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
    QUrlQuery query;
    query.addQueryItem("response_type", "code");
    query.addQueryItem("client_id", REDDIT_CLIENT_ID);
    query.addQueryItem("redirect_uri", REDDIT_REDIRECT_URL);
    query.addQueryItem("scope", REDDIT_OAUTH_SCOPE);
    query.addQueryItem("duration", "permanent");
    m_state = QString::number(qrand());
    query.addQueryItem("state", m_state);
    url.setQuery(query);
#else
    url.addQueryItem("response_type", "code");
    url.addQueryItem("client_id", REDDIT_CLIENT_ID);
    url.addQueryItem("redirect_uri", REDDIT_REDIRECT_URL);
    url.addQueryItem("scope", REDDIT_OAUTH_SCOPE);
    url.addQueryItem("duration", "permanent");
    m_state = QString::number(qrand());
    url.addQueryItem("state", m_state);
#endif
    return url;
}

void QuickdditManager::getAccessToken(const QUrl &signedInUrl)
{
    // if m_state is empty means generateAuthorizationUrl() is not called first
    Q_ASSERT(!m_state.isEmpty());

    if (m_accessTokenReply != 0) {
        qWarning("QuickdditManager::getAccessToken(): Aborting active network request (Try to avoid!)");
        m_accessTokenReply->disconnect();
        m_accessTokenReply->deleteLater();
        m_accessTokenReply = 0;
    }

    // check state
    QString state;
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
    QUrlQuery signedInUrlQuery(signedInUrl.query());
    state = signedInUrlQuery.queryItemValue("state");
#else
    state = signedInUrl.queryItemValue("state");
#endif
    if (m_state != state) {
        qCritical("QuickdditManager::getAccessToken(): (OAuth2) state is not matched");
        emit accessTokenFailure("Error: state not match");
        return;
    }

    m_state.clear();

    QUrl accessTokenUrl("https://ssl.reddit.com/api/v1/access_token");

    // generate body
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
    QUrlQuery bodyQuery;
    bodyQuery.addQueryItem("code", signedInUrlQuery.queryItemValue("code"));
#else
    QUrl bodyQuery("http://dummy.com");
    bodyQuery.addQueryItem("code", signedInUrl.queryItemValue("code"));
#endif
    bodyQuery.addQueryItem("grant_type", "authorization_code");
    bodyQuery.addQueryItem("redirect_uri", REDDIT_REDIRECT_URL);
    const QByteArray body =
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
            bodyQuery.toString(QUrl::FullyEncoded).toLatin1();
#else
            bodyQuery.encodedQuery();
#endif

    // generate basic auth header
    QByteArray authHeader = "Basic ";
    authHeader += (QByteArray(REDDIT_CLIENT_ID) + ":" + QByteArray(REDDIT_CLIENT_SECRET)).toBase64();

    m_accessTokenReply = m_netManager->createPostRequest(accessTokenUrl, body, authHeader);
    connect(m_accessTokenReply, SIGNAL(finished()), SLOT(onAccessTokenRequestFinished()));
}

void QuickdditManager::refreshAccessToken()
{
    if (m_accessTokenReply != 0) {
        qWarning("QuickdditManager::refreshAccessToken(): Aborting active network request (Try to avoid!)");
        m_accessTokenReply->disconnect();
        m_accessTokenReply->deleteLater();
        m_accessTokenReply = 0;
    }

    QByteArray refreshToken = m_settings->refreshToken();
    Q_ASSERT(!refreshToken.isEmpty());

    QUrl accessTokenUrl("https://ssl.reddit.com/api/v1/access_token");

    // generate body
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
    QUrlQuery bodyQuery;
#else
    QUrl bodyQuery("http://dummy.com");
#endif
    bodyQuery.addQueryItem("refresh_token", refreshToken);
    bodyQuery.addQueryItem("grant_type", "refresh_token");
    bodyQuery.addQueryItem("redirect_uri", REDDIT_REDIRECT_URL);
    const QByteArray body =
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
            bodyQuery.toString(QUrl::FullyEncoded).toLatin1();
#else
            bodyQuery.encodedQuery();
#endif

    // generate basic auth header
    QByteArray authHeader = "Basic ";
    authHeader += (QByteArray(REDDIT_CLIENT_ID) + ":" + QByteArray(REDDIT_CLIENT_SECRET)).toBase64();

    m_accessTokenReply = m_netManager->createPostRequest(accessTokenUrl, body, authHeader);
    connect(m_accessTokenReply, SIGNAL(finished()), SLOT(onAccessTokenRequestFinished()));
}

void QuickdditManager::signOut()
{
    m_accessToken.clear();
    m_settings->setRefreshToken(QByteArray());
    m_settings->setRedditUsername(QString());
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
            m_settings->setRefreshToken(refreshToken.toLatin1());
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

    if (!m_accessToken.isEmpty() && m_settings->redditUsername().isEmpty())
        updateRedditUsername();
}

void QuickdditManager::onRefreshTokenFinished()
{
    disconnect(this, 0, this, SLOT(onRefreshTokenFinished()));

    if (!m_accessToken.isEmpty() && m_accessTokenExpiry.elapsed() < 3600000)
        createRedditRequest(m_requestType, m_relativeUrl, m_parameters);
    else
        emit networkReplyReceived(0);

    m_relativeUrl.clear();
    m_parameters.clear();
}

void QuickdditManager::updateRedditUsername()
{
    if (m_userInfoReply != 0) {
        qWarning("QuickdditManager::updateRedditUsername(): Aborting active network request (Try to avoid!)");
        m_userInfoReply->disconnect();
        m_userInfoReply->deleteLater();
        m_userInfoReply = 0;
    }

    QByteArray authHeader = "Bearer " + m_accessToken.toLatin1();

    m_userInfoReply = m_netManager->createGetRequest(QUrl("https://oauth.reddit.com/api/v1/me.json"), authHeader);
    connect(m_userInfoReply, SIGNAL(finished()), SLOT(onUserInfoFinished()));
}

void QuickdditManager::onUserInfoFinished()
{
    if (m_userInfoReply->error() == QNetworkReply::NoError) {
        bool ok;
        QVariantMap userJson = QtJson::parse(m_userInfoReply->readAll(), ok).toMap();
        Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");
        m_settings->setRedditUsername(userJson.value("name").toString());
    } else {
        qDebug("QuickdditManager::onUserInfoFinished(): Network error: %s", qPrintable(m_userInfoReply->errorString()));
    }

    m_userInfoReply->deleteLater();
    m_userInfoReply = 0;
}

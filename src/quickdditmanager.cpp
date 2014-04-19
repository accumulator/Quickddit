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

#define REDDIT_OAUTH_SCOPE "read,mysubreddits,subscribe,vote,submit,edit,identity,privatemessages,history,save"

static QByteArray toEncodedQuery(const QHash<QString, QString> &parameters)
{
    QByteArray encodedQuery;
    QHashIterator<QString, QString> i(parameters);
    while (i.hasNext()) {
        i.next();
        encodedQuery += QUrl::toPercentEncoding(i.key()) + '=' + QUrl::toPercentEncoding(i.value()) + '&';
    }
    encodedQuery.chop(1); // chop the last '&'
    return encodedQuery;
}

static void setUrlQuery(QUrl *url, const QHash<QString, QString> &parameters)
{
#if (QT_VERSION >= QT_VERSION_CHECK(5,0,0))
    url->setQuery(QString::fromUtf8(toEncodedQuery(parameters)), QUrl::StrictMode);
#else
    url->setEncodedQuery(toEncodedQuery(parameters));
#endif
}

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
                                           const QHash<QString, QString> &parameters)
{
    QString baseUrl;
    QByteArray authHeader;

    if (m_settings->hasRefreshToken()) {
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

    if (type == GET) {
        // obey user settings for NSFW filtering
        // this is not documented but found in source:
        // <https://github.com/reddit/reddit/commit/6f9f91e7534db713d2bdd199ededd00598adccc1>
        QHash<QString, QString> parametersWithObey18(parameters);
        parametersWithObey18.insert("obey_over18", "true");
        setUrlQuery(&requestUrl, parametersWithObey18);
        emit networkReplyReceived(m_netManager->createGetRequest(requestUrl, authHeader));
    } else if (type == POST) {
        emit networkReplyReceived(m_netManager->createPostRequest(requestUrl, toEncodedQuery(parameters), authHeader));
    }
}

QUrl QuickdditManager::generateAuthorizationUrl()
{
    QUrl url("https://ssl.reddit.com/api/v1/authorize.compact");

    QHash<QString, QString> parameters;
    parameters.insert("response_type", "code");
    parameters.insert("client_id", REDDIT_CLIENT_ID);
    parameters.insert("redirect_uri", REDDIT_REDIRECT_URL);
    parameters.insert("scope", REDDIT_OAUTH_SCOPE);
    parameters.insert("duration", "permanent");
    m_state = QString::number(qrand());
    parameters.insert("state", m_state);

    setUrlQuery(&url, parameters);
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

    QHash<QString, QString> parameters;
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
    parameters.insert("code", signedInUrlQuery.queryItemValue("code"));
#else
    parameters.insert("code", signedInUrl.queryItemValue("code"));
#endif
    parameters.insert("grant_type", "authorization_code");
    parameters.insert("redirect_uri", REDDIT_REDIRECT_URL);

    // generate basic auth header
    QByteArray authHeader = "Basic ";
    authHeader += (QByteArray(REDDIT_CLIENT_ID) + ":" + QByteArray(REDDIT_CLIENT_SECRET)).toBase64();

    m_accessTokenReply = m_netManager->createPostRequest(accessTokenUrl, toEncodedQuery(parameters), authHeader);
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

    QHash<QString, QString> parameters;
    parameters.insert("refresh_token", refreshToken);
    parameters.insert("grant_type", "refresh_token");
    parameters.insert("redirect_uri", REDDIT_REDIRECT_URL);

    // generate basic auth header
    QByteArray authHeader = "Basic ";
    authHeader += (QByteArray(REDDIT_CLIENT_ID) + ":" + QByteArray(REDDIT_CLIENT_SECRET)).toBase64();

    m_accessTokenReply = m_netManager->createPostRequest(accessTokenUrl, toEncodedQuery(parameters), authHeader);
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

        if (!accessToken.isEmpty()) {
            m_accessToken = accessToken;
            m_accessTokenExpiry.start();
            if (!refreshToken.isEmpty())
                m_settings->setRefreshToken(refreshToken.toLatin1());
            emit accessTokenSuccess();
            emit signedInChanged();
        } else {
            emit accessTokenFailure("Error: access token not found. Please sign in again.");
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

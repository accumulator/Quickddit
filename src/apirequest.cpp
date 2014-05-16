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

#include "apirequest.h"

#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>

#include "utils.h"

#if defined(Q_OS_HARMATTAN)
static const QByteArray USER_AGENT = QByteArray("Quickddit/") + APP_VERSION + " (MeeGo Harmattan)";
#elif defined(Q_OS_SAILFISH)
static const QByteArray USER_AGENT = QByteArray("Quickddit/") + APP_VERSION + " (SailfishOS)";
#elif defined(Q_WS_SIMULATOR)
static const QByteArray USER_AGENT = QByteArray("Quickddit/") + APP_VERSION + " (Qt Simulator)";
#else
static const QByteArray USER_AGENT = QByteArray("Quickddit/") + APP_VERSION + " (Unknown)";
#endif

#define REDDIT_NORMAL_DOMAIN "http://www.reddit.com"
#define REDDIT_OAUTH_DOMAIN "https://oauth.reddit.com"
#define REDDIT_ACCESS_TOKEN_URL "https://ssl.reddit.com/api/v1/access_token"

APIRequest::APIRequest(Type type, QNetworkAccessManager *netManager, QObject *parent) :
    QObject(parent), m_type(type), m_netManager(netManager), m_reply(0)
{
}

void APIRequest::setRequestMethod(HttpMethod method)
{
    m_method = method;
}

void APIRequest::setBaseUrl(const QUrl &url)
{
    m_baseUrl = url;
}

void APIRequest::setRelativeUrl(const QString &url)
{
    m_relativeUrl = url;
}

void APIRequest::setAccessToken(const QString &accessToken)
{
    m_accessToken = accessToken;
}

void APIRequest::setParameters(const QHash<QString, QString> &parameters)
{
    m_parameters = parameters;
}

void APIRequest::setAuthHeader(const QByteArray &authHeader)
{
    m_authHeader = authHeader;
}

void APIRequest::setClientId(const QString &id)
{
    m_clientId = id;
}

void APIRequest::setClientSecret(const QString &secret)
{
    m_clientSecret = secret;
}

void APIRequest::setRedirectUrl(const QString &url)
{
    m_redirectUrl = url;
}

void APIRequest::setCode(const QString &code)
{
    m_code = code;
}

void APIRequest::setRefreshToken(const QString &refreshToken)
{
    m_refreshToken = refreshToken;
}

void APIRequest::send()
{
    Q_ASSERT(m_reply == 0);

    if (m_type == AccessTokenRequest || m_type == RefreshAccessTokenRequest) {
        Q_ASSERT(!m_clientId.isEmpty() && !m_clientSecret.isEmpty() && !m_redirectUrl.isEmpty());

        m_method = POST;
        m_baseUrl = QUrl(REDDIT_ACCESS_TOKEN_URL);
        m_parameters.clear();
        m_parameters.insert("redirect_uri", m_redirectUrl);
        m_authHeader = "Basic " + (m_clientId.toLatin1() + ":" + m_clientSecret.toLatin1()).toBase64();

        if (m_type == AccessTokenRequest) {
            Q_ASSERT(!m_code.isEmpty());
            m_parameters.insert("code", m_code);
            m_parameters.insert("grant_type", "authorization_code");
        } else { // RefreshAccessTokenRequest
            Q_ASSERT(!m_refreshToken.isEmpty());
            m_parameters.insert("refresh_token", m_refreshToken);
            m_parameters.insert("grant_type", "refresh_token");
        }
    } else if (m_type == OAuthRequest) {
        Q_ASSERT(!m_relativeUrl.isEmpty() && !m_accessToken.isEmpty());
        m_baseUrl = REDDIT_OAUTH_DOMAIN + m_relativeUrl + (m_method == GET ? ".json" : "");
        m_authHeader = "Bearer " + m_accessToken.toLatin1();
    } else if (m_type == NormalRequest) {
        Q_ASSERT(!m_baseUrl.isEmpty() || !m_relativeUrl.isEmpty());
        if (m_baseUrl.isEmpty())
            m_baseUrl = REDDIT_NORMAL_DOMAIN + m_relativeUrl + (m_method == GET ? ".json" : "");
    }

    QNetworkRequest request;
    request.setRawHeader("User-Agent", USER_AGENT);
    if (!m_authHeader.isEmpty())
        request.setRawHeader("Authorization", m_authHeader);

    if (m_method == GET) {
        // obey user settings for NSFW filtering, this is not documented but found in source:
        // <https://github.com/reddit/reddit/commit/6f9f91e7534db713d2bdd199ededd00598adccc1>
        if (m_type == OAuthRequest)
            m_parameters.insert("obey_over18", "true");

        if (!m_parameters.isEmpty())
            Utils::setUrlQuery(&m_baseUrl, m_parameters);
        request.setUrl(m_baseUrl);
        m_reply = m_netManager->get(request);
    } else if (m_method == POST) {
        request.setUrl(m_baseUrl);
        request.setRawHeader("Content-Type", "application/x-www-form-urlencoded");
        m_reply = m_netManager->post(request, Utils::toEncodedQuery(m_parameters));
    } else if (m_method == PUT) {
        request.setUrl(m_baseUrl);
        request.setRawHeader("Content-Type", "application/x-www-form-urlencoded");
        m_reply = m_netManager->put(request, Utils::toEncodedQuery(m_parameters));
    } else if (m_method == DELETE) {
        request.setUrl(m_baseUrl);
        m_reply = m_netManager->deleteResource(request);
    } else {
        qFatal("APIRequest::send(): Invalid method");
    }

    m_reply->setParent(this);
    connect(m_reply, SIGNAL(finished()), SLOT(onFinished()));
}

void APIRequest::forceFailure()
{
    Q_ASSERT(m_reply == 0);
    emit finished(0);
}

void APIRequest::onFinished()
{
    // print Reddit rate limit
    if (m_type == OAuthRequest && m_reply->error() == QNetworkReply::NoError) {
        int remaining = m_reply->rawHeader("X-Ratelimit-Remaining").toInt();
        int reset = m_reply->rawHeader("X-Ratelimit-Reset").toInt();
        qDebug("Reddit Rate Limit: Remaining: %d, Reset: %ds", remaining, reset);
    }

    emit finished(m_reply);
}

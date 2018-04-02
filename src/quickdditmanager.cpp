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

#include "quickdditmanager.h"

#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkReply>
#include <QtNetwork/QNetworkProxy>
#include <QDebug>

#include <qt-json/json.h>

#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
#include <QtCore/QUrlQuery>
#endif

#include "appsettings.h"
#include "utils.h"

#if !defined(REDDIT_CLIENT_ID) || !defined(REDDIT_CLIENT_SECRET) || !defined(REDDIT_REDIRECT_URL)
// fill these up with your own Reddit client id, secret and redirect url
#define REDDIT_CLIENT_ID ""
#define REDDIT_CLIENT_SECRET ""
#define REDDIT_REDIRECT_URL ""
#endif

#define REDDIT_OAUTH_SCOPE "read,mysubreddits,subscribe,vote,submit,edit,identity,privatemessages,history,save,flair,report,wikiread"

QuickdditManager::QuickdditManager(QObject *parent) :
    QObject(parent), m_netManager(new QNetworkAccessManager(this)), m_settings(0),
    m_accessTokenRequest(0), m_pendingRequest(0), m_userInfoReply(0)
{
}

bool QuickdditManager::isBusy() const
{
    return m_busy;
}

void QuickdditManager::setBusy(const bool busy)
{
    if (m_busy == busy)
        return;

    m_busy = busy;
    emit busyChanged();
}

bool QuickdditManager::isSignedIn() const
{
    return m_settings->hasRefreshToken() && !m_accessToken.isEmpty();
}

AppSettings *QuickdditManager::settings() const
{
    return m_settings;
}

void QuickdditManager::setSettings(AppSettings *settings)
{
    m_settings = settings;
    connect(m_settings, SIGNAL(useTorChanged()), SLOT(onUseTorChanged()));
}

APIRequest *QuickdditManager::createGetRequest(QObject *parent, const QUrl &url, const QByteArray &authHeader)
{
    APIRequest *request = new APIRequest(APIRequest::NormalRequest, m_netManager, parent);
    request->setRequestMethod(APIRequest::GET);
    request->setBaseUrl(url);
    request->setAuthHeader(authHeader);
    request->send();
    return request;
}

APIRequest *QuickdditManager::createRedditRequest(QObject *parent, APIRequest::HttpMethod method,
                                                  const QString &relativeUrl, const QHash<QString, QString> &parameters)
{
    APIRequest *request;

    if (m_netManager->networkAccessible() == QNetworkAccessManager::NotAccessible) {
        delete m_netManager;
        m_netManager = new QNetworkAccessManager(this);
    }

    if (m_settings->hasRefreshToken()) {
        request = new APIRequest(APIRequest::OAuthRequest, m_netManager, parent);
        request->setRequestMethod(method);
        request->setRelativeUrl(relativeUrl);
        request->setParameters(parameters);
        if (!m_accessToken.isEmpty() && m_accessTokenExpiry.elapsed() < 3600000) {
            request->setAccessToken(m_accessToken);
        } else {
            if (m_pendingRequest != 0) {
                m_pendingRequest->forceFailure();
                m_pendingRequest = 0;
            }
            m_pendingRequest = request;
            connect(this, SIGNAL(accessTokenSuccess()), SLOT(onRefreshTokenFinished()));
            connect(this, SIGNAL(accessTokenFailure(int, QString)), SLOT(onRefreshTokenFinished()));
            refreshAccessToken();
            return request;
        }
    } else {
        request = new APIRequest(APIRequest::NormalRequest, m_netManager, parent);
        request->setRequestMethod(method);
        request->setRelativeUrl(relativeUrl);
        request->setParameters(parameters);
    }

    request->send();
    return request;
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

    Utils::setUrlQuery(&url, parameters);
    return url;
}

void QuickdditManager::getAccessToken(const QUrl &signedInUrl)
{
    // if m_state is empty means generateAuthorizationUrl() is not called first
    Q_ASSERT(!m_state.isEmpty());

    qDebug() << "getting access token from url:" << signedInUrl;

    if (m_accessTokenRequest != 0) {
        qWarning("QuickdditManager::getAccessToken(): Aborting active network request (Try to avoid!)");
        m_accessTokenRequest->disconnect();
        m_accessTokenRequest->deleteLater();
        m_accessTokenRequest = 0;
    }

    // check state
    QString state;
    QString code;
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
    QUrlQuery signedInUrlQuery(signedInUrl.query());
    state = signedInUrlQuery.queryItemValue("state");
    code = signedInUrlQuery.queryItemValue("code");
#else
    state = signedInUrl.queryItemValue("state");
    code = signedInUrl.queryItemValue("code");
#endif

    if (m_state != state) {
        qCritical("QuickdditManager::getAccessToken(): (OAuth2) state is not matched");
        emit accessTokenFailure(0, "Error: state not match");
        return;
    }

    m_state.clear();

    m_accessTokenRequest = new APIRequest(APIRequest::AccessTokenRequest, m_netManager, this);
    m_accessTokenRequest->setClientId(REDDIT_CLIENT_ID);
    m_accessTokenRequest->setClientSecret(REDDIT_CLIENT_SECRET);
    m_accessTokenRequest->setRedirectUrl(REDDIT_REDIRECT_URL);
    m_accessTokenRequest->setCode(code);
    m_accessTokenRequest->send();

    connect(m_accessTokenRequest, SIGNAL(finished(QNetworkReply*)), SLOT(onAccessTokenRequestFinished(QNetworkReply*)));
}

void QuickdditManager::refreshAccessToken()
{
    if (m_accessTokenRequest != 0) {
        qWarning("QuickdditManager::refreshAccessToken(): Aborting active network request (Try to avoid!)");
        m_accessTokenRequest->disconnect();
        m_accessTokenRequest->deleteLater();
        m_accessTokenRequest = 0;
    }

    setBusy(true);

    QByteArray refreshToken = m_settings->refreshToken();
    Q_ASSERT(!refreshToken.isEmpty());

    m_accessTokenRequest = new APIRequest(APIRequest::RefreshAccessTokenRequest, m_netManager, this);
    m_accessTokenRequest->setClientId(REDDIT_CLIENT_ID);
    m_accessTokenRequest->setClientSecret(REDDIT_CLIENT_SECRET);
    m_accessTokenRequest->setRedirectUrl(REDDIT_REDIRECT_URL);
    m_accessTokenRequest->setRefreshToken(refreshToken);
    m_accessTokenRequest->send();

    connect(m_accessTokenRequest, SIGNAL(finished(QNetworkReply*)), SLOT(onAccessTokenRequestFinished(QNetworkReply*)));
}

void QuickdditManager::signOut()
{
    m_accessToken.clear();
    m_settings->setRefreshToken(QByteArray());
    m_settings->setRedditUsername(QString());
    emit signedInChanged();
}

void QuickdditManager::onAccessTokenRequestFinished(QNetworkReply *reply)
{
    if (reply->error() == QNetworkReply::NoError) {
        const QString replyString = QString::fromUtf8(reply->readAll());

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
            emit accessTokenFailure(0, "Error: access token not found. Please sign in again.");
            qDebug("QuickdditManager::onAccessTokenRequestFinished(): "
                   "Unable to get access token from the following data:\n%s", qPrintable(replyString));
        }
    } else {
        if (reply->error() == QNetworkReply::UnknownContentError || reply->error() == QNetworkReply::ProtocolInvalidOperationError) {
            // something's wrong with the refresh token
            qDebug() << "Bad Request using our refresh token, resetting";
            m_settings->setRefreshToken(QByteArray());
            m_settings->setRedditUsername(QString());
            emit signedInChanged();
            emit accessTokenFailure(0, "OAuth token invalid, please log in again");
        } else if (reply->error() == QNetworkReply::AuthenticationRequiredError) {
            // missing OAuth app credentials
            qWarning() << "Server requires app registration. Make sure you compiled Quickddit with REDDIT_CLIENT_ID defined.";
            emit accessTokenFailure(0, "Application Error. Check the logs");
        } else {
            qDebug() << "onAccessTokenRequestFinished error" << reply->error() << ":" << reply->errorString();
            emit accessTokenFailure(reply->error(), reply->errorString());
        }
    }

    m_accessTokenRequest->deleteLater();
    m_accessTokenRequest = 0;

    if (!m_accessToken.isEmpty()) {
        if (m_settings->redditUsername().isEmpty())
            updateRedditUsername();
        else
            saveOrAddAccountInfo();
    }

    setBusy(false);
}

void QuickdditManager::onRefreshTokenFinished()
{
    disconnect(this, 0, this, SLOT(onRefreshTokenFinished()));

    if (!m_accessToken.isEmpty() && m_accessTokenExpiry.elapsed() < 3600000) {
        m_pendingRequest->setAccessToken(m_accessToken);
        m_pendingRequest->send();
    } else {
        m_pendingRequest->forceFailure();
    }

    m_pendingRequest = 0;
}

void QuickdditManager::updateRedditUsername()
{
    if (m_userInfoReply != 0) {
        qWarning("QuickdditManager::updateRedditUsername(): Aborting active network request (Try to avoid!)");
        m_userInfoReply->disconnect();
        m_userInfoReply->deleteLater();
        m_userInfoReply = 0;
    }

    m_userInfoReply = new APIRequest(APIRequest::OAuthRequest, m_netManager, this);
    m_userInfoReply->setRequestMethod(APIRequest::GET);
    m_userInfoReply->setRelativeUrl("/api/v1/me");
    m_userInfoReply->setAccessToken(m_accessToken);
    m_userInfoReply->send();

    connect(m_userInfoReply, SIGNAL(finished(QNetworkReply*)), SLOT(onUserInfoFinished(QNetworkReply*)));
}

void QuickdditManager::onUserInfoFinished(QNetworkReply *reply)
{
    if (reply->error() == QNetworkReply::NoError) {
        bool ok;
        QVariantMap userJson = QtJson::parse(reply->readAll(), ok).toMap();
        Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");
        m_settings->setRedditUsername(userJson.value("name").toString());
    } else {
        qDebug("QuickdditManager::onUserInfoFinished(): Network error: %s", qPrintable(reply->errorString()));
    }

    saveOrAddAccountInfo();

    m_userInfoReply->deleteLater();
    m_userInfoReply = 0;
}

void QuickdditManager::onUseTorChanged()
{
    QNetworkProxy proxy;
    if (m_settings->useTor()) {
        proxy.setType(QNetworkProxy::Socks5Proxy);
        proxy.setHostName("localhost");
        proxy.setPort(9050);
    } else {
        proxy.setType(QNetworkProxy::NoProxy);
    }
    QNetworkProxy::setApplicationProxy(proxy);
}

// update the account info
void QuickdditManager::saveOrAddAccountInfo()
{
    qDebug() << "saveRefreshToken" << m_settings->refreshToken() << m_settings->redditUsername();

    bool found = false;
    QList<QPair<QString, QByteArray>> accountlist = m_settings->accounts();
    for (int i=0; i < accountlist.size(); ++i) {
        if (accountlist.at(i).first == m_settings->redditUsername()) {
            found = true;
            accountlist.replace(i, QPair<QString, QByteArray>(m_settings->redditUsername(), m_settings->refreshToken()));
            break;
        }
    }

    if (!found)
        accountlist.append(QPair<QString, QByteArray>(m_settings->redditUsername(), m_settings->refreshToken()));

    m_settings->setAccounts(accountlist);
}

void QuickdditManager::selectAccount(QString accountName)
{
    QList<QPair<QString, QByteArray>> accountlist = m_settings->accounts();
    for (int i=0; i < accountlist.size(); ++i) {
        if (accountlist.at(i).first == accountName) {
            signOut();
            m_settings->setRefreshToken(accountlist.at(i).second);
            m_settings->setRedditUsername(accountlist.at(i).first);
            m_accessToken.clear();
            refreshAccessToken();
            break;
        }
    }
}


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

#ifndef APIREQUEST_H
#define APIREQUEST_H

#include <QtCore/QObject>
#include <QtCore/QUrl>
#include <QtCore/QHash>

class QNetworkAccessManager;
class QNetworkReply;

class APIRequest : public QObject
{
    Q_OBJECT
public:
    enum Type {
        NormalRequest,
        OAuthRequest,
        AccessTokenRequest,
        RefreshAccessTokenRequest
    };

    enum HttpMethod {
        GET,
        POST,
        PUT,
        DELETE
    };

    explicit APIRequest(Type type, QNetworkAccessManager *netManager, QObject *parent = 0);

    /**
     * Set the request method (GET or POST)
     * Required for NormalRequest and OAuthRequest, no effect on other type
     */
    void setRequestMethod(HttpMethod method);

    /**
     * Set the base or (Reddit) relative url for the request
     * Either one is required for NormalRequest (baseUrl override relativeUrl)
     * relativeUrl is required for OAuthRequest
     * No effect on other type
     */
    void setBaseUrl(const QUrl &url);
    void setRelativeUrl(const QString &url);

    /**
     * Set the valid access token for the request
     * Required for OAuthRequest, no effect on other type
     */
    void setAccessToken(const QString &accessToken);

    /**
     * Set the parameters for the request
     * Optional for NormalRequest and OAuthRequest, no effect on other type
     */
    void setParameters(const QHash<QString, QString> &parameters);

    /**
     * Set custom authorization header for the request
     * Optional for NormalRequest, no effect on other type
     */
    void setAuthHeader(const QByteArray &authHeader);

    /**
     * Required for AccessTokenRequest and RefreshAccessTokenRequest, no effect on other type
     */
    void setClientId(const QString &id);
    void setClientSecret(const QString &secret);
    void setRedirectUrl(const QString &url);

    /**
     * Required for AccessTokenRequest, no effect on other type
     */
    void setCode(const QString &code);

    /**
     * Required for RefreshAccessTokenRequest, no effect on other type
     */
    void setRefreshToken(const QString &refreshToken);

    /**
     * Send the request
     * All required attribute must be set first before send (checked with Q_ASSERT)
     */
    void send();

    /**
     * private, don't touch this
     * force emit finished with reply = 0
     */
    void forceFailure();

signals:
    /**
     * emit when the request is finished
     * reply can be 0, so must handle carefully
     */
    void finished(QNetworkReply *reply);

private slots:
    void onFinished();

private:
    const Type m_type;
    QNetworkAccessManager *m_netManager;

    HttpMethod m_method;
    QUrl m_baseUrl;
    QString m_relativeUrl;
    QString m_accessToken;
    QHash<QString, QString> m_parameters;
    QByteArray m_authHeader;

    QString m_clientId;
    QString m_clientSecret;
    QString m_redirectUrl;

    QString m_code;
    QString m_refreshToken;

    QNetworkReply *m_reply;
};

#endif // APIREQUEST_H

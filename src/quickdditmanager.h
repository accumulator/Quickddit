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

#ifndef QUICKDDITMANAGER_H
#define QUICKDDITMANAGER_H

#include <QtCore/QObject>
#include <QtCore/QUrl>
#include <QtCore/QDateTime>

// TODO: rewrite this whole class

class QNetworkReply;
class AppSettings;
class NetworkManager;

class QuickdditManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isSignedIn READ isSignedIn NOTIFY signedInChanged)
    Q_PROPERTY(AppSettings* settings READ settings WRITE setSettings)
public:
    enum RequestType {
        GET,
        POST
    };

    explicit QuickdditManager(QObject *parent = 0);

    bool isSignedIn() const;

    AppSettings *settings() const;
    void setSettings(AppSettings *settings);

    /**
     * Create a GET request to non-Reddit API
     */
    QNetworkReply *createGetRequest(const QUrl &url, const QByteArray &authHeader);

    /**
     * Create a GET/POST request to Reddit API
     * the signal networkReplyReceived() will be emitted with the QNetworkReply in the parameter
     * if this process failed, the QNetworkReply in the signal networkReplyReceived() will be 0
     * @param type specify GET or POST request
     * @param relativeUrl the relative url of Reddit without the ".json", eg. "/r/nokia/hot"
     * @param parameters parameters for the request (will be added as query items in the url)
     */
    void createRedditRequest(RequestType type, const QString &relativeUrl,
                             const QHash<QString, QString> &parameters = QHash<QString,QString>());

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
    void onUserInfoFinished();

private:
    NetworkManager *m_netManager;
    AppSettings *m_settings;

    QString m_state;
    QNetworkReply *m_accessTokenReply;
    QString m_accessToken;
    QTime m_accessTokenExpiry;

    RequestType m_requestType;
    QString m_relativeUrl;
    QHash<QString, QString> m_parameters;

    void refreshAccessToken();
    void updateRedditUsername();
    QNetworkReply *m_userInfoReply;
};

#endif // QUICKDDITMANAGER_H

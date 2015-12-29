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

#ifndef QMLUTILS_H
#define QMLUTILS_H

#include <QtCore/QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QFile>

class QMLUtils : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString SOURCE_REPO_URL READ sourceRepoUrl CONSTANT)
    Q_PROPERTY(QString GPL3_LICENSE_URL READ gpl3LicenseUrl CONSTANT)
public:
    static const QString SOURCE_REPO_URL;
    static QString sourceRepoUrl() { return SOURCE_REPO_URL; }

    static const QString GPL3_LICENSE_URL;
    static QString gpl3LicenseUrl() { return GPL3_LICENSE_URL; }

    explicit QMLUtils(QObject *parent = 0);

    // Copy text to system clipboard
    Q_INVOKABLE void copyToClipboard(const QString &text);

    // Share URL using integrated sharing in Harmattan
    Q_INVOKABLE void shareUrl(const QString &url, const QString &title = QString());

    /**
     * Get the shorten Reddit url (http://redd.it/xxxxxx)
     * @param fullname the fullname of the link (eg. "t3_abcdef")
     */
    Q_INVOKABLE QString getRedditShortUrl(const QString &fullname);

    /**
     * Get a absolute Reddit url from a relative url
     * Return the same string if the url is already an absolute url
     * Return empty string if not able to absolute the url
     * @param url the Reddit relative url
     */
    Q_INVOKABLE QString toAbsoluteUrl(const QString &url);

    Q_INVOKABLE void saveImage(const QString &url);

    Q_INVOKABLE void publishNotification(const QString &summary, const QString &body, const int count);
    Q_INVOKABLE void clearNotification();

private slots:
    void onSaveImageFinished();

signals:
    void saveImageSucceeded(const QString &name);
    void saveImageFailed(const QString &name);

private:
    QNetworkAccessManager m_manager;
    QNetworkReply* m_reply;
    QFile *m_imageFile;
};

#endif // QMLUTILS_H

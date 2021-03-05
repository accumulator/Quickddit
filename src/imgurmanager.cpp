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

#include "imgurmanager.h"

#include <QtNetwork/QNetworkReply>

#include "parser.h"

#ifndef IMGUR_CLIENT_ID
#define IMGUR_CLIENT_ID "cf8f8118cf90389"
#endif

static const QRegExp NONE_WORD_REGEXP("\\W");

ImgurManager::ImgurManager(QObject *parent) :
    AbstractManager(parent), m_selectedIndex(0), m_request(0)
{
}

void ImgurManager::classBegin()
{
}

void ImgurManager::componentComplete()
{
    if (!m_imgurUrl.isEmpty())
        refresh();
}

QUrl ImgurManager::imageUrl() const
{
    return m_imageUrl;
}

QStringList ImgurManager::thumbnailUrls() const
{
    return m_thumbnailUrls;
}

int ImgurManager::selectedIndex() const
{
    return m_selectedIndex;
}

void ImgurManager::setSelectedIndex(int index)
{
    if (m_selectedIndex != index) {
        m_selectedIndex = index;
        emit selectedIndexChanged();

        m_imageUrl.clear();
        emit imageUrlChanged();
        m_imageUrl = m_imageAndThumbUrlList.at(m_selectedIndex).first;
        emit imageUrlChanged();
    }
}

QString ImgurManager::imgurUrl() const
{
    return m_imgurUrl;
}

void ImgurManager::setImgurUrl(const QString &imgurUrl)
{
    if (m_imgurUrl != imgurUrl) {
        m_imgurUrl = imgurUrl;
        emit imgurUrlChanged();
    }
}

QStringList ImgurManager::imageUrls() const
{
    return m_imageUrls;
}

void ImgurManager::refresh()
{
    Q_ASSERT(!m_imgurUrl.isEmpty());

    if (m_request != 0) {
        qWarning("ImgurManager::refresh(): Aborting active network request (Try to avoid!)");
        m_request->disconnect();
        m_request->deleteLater();
        m_request = 0;
    }

    const QUrl imgurUrl(m_imgurUrl);

    // direct image url
    if (imgurUrl.host() == QLatin1String("i.imgur.com")
            && imgurUrl.path().contains(QRegExp("\\.(png|gif|jpe?g)"))) {
        m_imageUrl = m_imgurUrl;
        emit imageUrlChanged();
        return;
    }

    QString requestUrl = "https://api.imgur.com/3";

    QString path = imgurUrl.path();
    if (path.endsWith('/'))
        path = path.left(path.length()-1);

    if (path.startsWith("/a/")) {
        QString id = QString(path).remove(0, 3);
        if (id.contains(NONE_WORD_REGEXP))
            id.truncate(id.indexOf(NONE_WORD_REGEXP));
        requestUrl += "/album/" + id + "/images";
    } else if (path.startsWith("/gallery/")) {
        QString id = QString(path).remove(0, 9);
        if (id.contains(NONE_WORD_REGEXP))
            id.truncate(id.indexOf(NONE_WORD_REGEXP));
        requestUrl += "/gallery/" + id;
    } else if (path.startsWith("/r/")) {
        QString id = QString(path).remove(QRegExp("^/r/[^/]+/"));
        if (id.contains(NONE_WORD_REGEXP))
            id.truncate(id.indexOf(NONE_WORD_REGEXP));
        requestUrl += "/image/" + id;
    } else if (path.startsWith("/topic/")) {
        QRegExp topic("^/topic/([^/]+)/");
        QString id = QString(path).remove(topic);
        if (id.contains(NONE_WORD_REGEXP))
            id.truncate(id.indexOf(NONE_WORD_REGEXP));
        topic.indexIn(path);
        requestUrl += "/topics/" + topic.cap(1) + "/" + id;
    } else if (path.lastIndexOf('/') == 0) {
        QString id = QString(path).remove(0, 1);
        if (id.contains(NONE_WORD_REGEXP))
            id.truncate(id.indexOf(NONE_WORD_REGEXP));
        requestUrl += "/image/" + id;
    } else {
        emit error(tr("Unable to get Imgur ID from the url: %1").arg(m_imgurUrl));
        return;
    }

    QByteArray authHeader = QByteArray("Client-ID ") + IMGUR_CLIENT_ID;
    m_request = manager()->createGetRequest(this, QUrl(requestUrl), authHeader);
    connect(m_request, SIGNAL(finished(QNetworkReply*)), SLOT(onFinished(QNetworkReply*)));

    setBusy(true);
}

void ImgurManager::onFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            // print rate limit
            QByteArray userLimit = reply->rawHeader("X-RateLimit-UserRemaining");
            QByteArray clientLimit = reply->rawHeader("X-RateLimit-ClientRemaining");
            qDebug("Imgur Rate Limit: User: %s, Client: %s", userLimit.constData(), clientLimit.constData());

            m_imageAndThumbUrlList = Parser::parseImgurImages(reply->readAll());

            if (m_imageAndThumbUrlList.count() > 1) {
                QListIterator< QPair<QString,QString> > i(m_imageAndThumbUrlList);
                while (i.hasNext()) {
                    qDebug()<<i.peekNext();
                    m_thumbnailUrls.append(i.peekNext().second);
                    m_imageUrls.append(i.next().first);
                }
                if (m_selectedIndex >= m_imageAndThumbUrlList.count())
                    m_selectedIndex = 0;
                m_imageUrl = m_imageAndThumbUrlList.at(m_selectedIndex).first;
            } else if (m_imageAndThumbUrlList.count() == 1) {
                m_imageUrl = m_imageAndThumbUrlList.first().first;
                m_imageUrls.append(m_imageAndThumbUrlList.first().first);
            } else {
                emit error(tr("Imgur API returns no image"));
            }

            emit imageUrlChanged();
            emit thumbnailUrlsChanged();
            emit imageUrlsChanged();
        } else {
            emit error(reply->errorString());
        }
    }

    m_request->deleteLater();
    m_request = 0;
    setBusy(false);
}

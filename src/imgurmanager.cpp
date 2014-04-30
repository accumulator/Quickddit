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

ImgurManager::ImgurManager(QObject *parent) :
    AbstractManager(parent), m_selectedIndex(0), m_reply(0)
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

void ImgurManager::refresh()
{
    Q_ASSERT(!m_imgurUrl.isEmpty());

    if (m_reply != 0) {
        qWarning("ImgurManager::refresh(): Aborting active network request (Try to avoid!)");
        m_reply->disconnect();
        m_reply->deleteLater();
        m_reply = 0;
    }

    QString requestUrl = "https://api.imgur.com/3";

    QString id = m_imgurUrl.mid(m_imgurUrl.indexOf("imgur.com/") + 10);
    if (id.startsWith("a/")) {
        id.remove(0, 2);
        if (id.contains('#')) {
            int hashIndex = id.indexOf('#');
            m_selectedIndex = id.mid(hashIndex + 1).toInt();
            id.remove(hashIndex, id.length() - hashIndex);
        }
        requestUrl += "/album/" + id + "/images";
    } else if (id.startsWith("gallery/")) {
        id.remove(0, 8);
        if (id.contains('#')) {
            int hashIndex = id.indexOf('#');
            m_selectedIndex = id.mid(hashIndex + 1).toInt();
            id.remove(hashIndex, id.length() - hashIndex);
        }
        requestUrl += "/gallery/" + id;
    } else if (!id.contains('/')) {
        if (id.contains('#'))
            id.remove(id.indexOf('#'), id.length() - id.indexOf('#'));
        requestUrl += "/image/" + id;
    } else {
        emit error("Unable to get Imgur ID from the url: " + m_imgurUrl);
        return;
    }

    QByteArray authHeader = QByteArray("Client-ID ") + IMGUR_CLIENT_ID;

    m_reply = manager()->createGetRequest(QUrl(requestUrl), authHeader);
    m_reply->setParent(this);
    connect(m_reply, SIGNAL(finished()), SLOT(onFinished()));

    setBusy(true);
}

void ImgurManager::onFinished()
{
    if (m_reply->error() == QNetworkReply::NoError) {
        // print rate limit
        int userLimit = m_reply->rawHeader("X-RateLimit-UserRemaining").toInt();
        int clientLimit = m_reply->rawHeader("X-RateLimit-ClientRemaining").toInt();
        qDebug("Imgur Rate Limit: User: %d, Client: %d", userLimit, clientLimit);

        m_imageAndThumbUrlList = Parser::parseImgurImages(m_reply->readAll());

        if (m_imageAndThumbUrlList.count() > 1) {
            QListIterator< QPair<QString,QString> > i(m_imageAndThumbUrlList);
            while (i.hasNext()) {
                m_thumbnailUrls.append(i.next().second);
            }
            if (m_selectedIndex >= m_imageAndThumbUrlList.count())
                m_selectedIndex = 0;
            m_imageUrl = m_imageAndThumbUrlList.at(m_selectedIndex).first;
        } else if (m_imageAndThumbUrlList.count() == 1) {
            m_imageUrl = m_imageAndThumbUrlList.first().first;
        } else {
            emit error("Imgur API return no image");
        }

        emit imageUrlChanged();
        emit thumbnailUrlsChanged();
    } else {
        emit error(m_reply->errorString());
    }

    m_reply->deleteLater();
    m_reply = 0;
    setBusy(false);
}

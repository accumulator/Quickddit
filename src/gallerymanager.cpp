/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2020  Sander van Grieken

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

#include <QtNetwork/QNetworkReply>

#include "gallerymanager.h"
#include "parser.h"
#include "commentobject.h"
#include "linkobject.h"

QString GalleryManager::unescapeUrl(QString url)
{
    url.replace("&amp;", "&");
    return url;
}

GalleryManager::GalleryManager(QObject *parent) :
    AbstractManager(parent), m_selectedIndex(-1)
{
}

void GalleryManager::classBegin()
{
}

void GalleryManager::componentComplete()
{
    if (!m_galleryUrl.isEmpty())
        refresh();
}

QUrl GalleryManager::galleryUrl() const
{
    return m_galleryUrl;
}

void GalleryManager::setGalleryUrl(const QUrl &galleryUrl)
{
    if (m_galleryUrl != galleryUrl) {
        m_galleryUrl = galleryUrl;
        emit galleryUrlChanged();
    }
}

QUrl GalleryManager::imageUrl() const
{
    return m_imageUrl;
}

QStringList GalleryManager::thumbnailUrls() const
{
    return m_thumbnailUrls;
}

int GalleryManager::selectedIndex() const
{
    return m_selectedIndex;
}

void GalleryManager::setSelectedIndex(int index)
{
    if (m_selectedIndex != index) {
        if (index >= m_galleryItemList.count())
            return;

        m_selectedIndex = index;
        emit selectedIndexChanged();

        if (index < 0)
            m_imageUrl = QUrl();
        else {
            QVariantMap smediaMap = m_galleryItemList.at(index).second.value("s").toMap();
            QString imageUrl = smediaMap.value("u").toString();
            if (imageUrl.isEmpty())
                imageUrl = smediaMap.value("gif").toString();
            m_imageUrl = QUrl(GalleryManager::unescapeUrl(imageUrl));
        }
        emit imageUrlChanged();
    }
}

void GalleryManager::refresh()
{
    Q_ASSERT(m_galleryUrl.isValid());

    m_galleryItemList.clear();
    m_thumbnailUrls.clear();
    setSelectedIndex(-1);

    QStringList pathElements = m_galleryUrl.path().split("/");
    QString linkUrl = "/comments/" + pathElements.at(2);

    QHash<QString, QString> parameters;
    parameters["limit"] = "1";

    doRequest(APIRequest::GET, linkUrl, SLOT(onFinished(QNetworkReply*)), parameters);
}

void GalleryManager::onFinished(QNetworkReply *reply)
{
    if (reply != nullptr) {
        if (reply->error() == QNetworkReply::NoError) {
            QPair<LinkObject,QList<CommentObject>> result = Parser::parseCommentList(reply->readAll());
            QVariantList items = result.first.galleryData().first.toMap().value("items").toList();
            QVariantMap meta = result.first.galleryData().second.toMap();
            foreach (const QVariant &itemv, items) {
                QVariantMap item = itemv.toMap();
                QVariantMap item_meta = meta.value(item.value("media_id").toString()).toMap();
                m_galleryItemList.append(QPair<QVariantMap,QVariantMap>(item,item_meta));

                // (p)review images could be empty, if (s)ource image is small
                QString thumbnailUrl = "";
                QVariantList pList = item_meta.value("p").toList();
                if (pList.count() != 0)
                    thumbnailUrl = pList.at(0).toMap().value("u").toString();
                else
                    thumbnailUrl = item_meta.value("s").toMap().value("u").toString();

                m_thumbnailUrls.append(GalleryManager::unescapeUrl(thumbnailUrl));
            }
            if (m_galleryItemList.count() > 0) {
                emit thumbnailUrlsChanged();
                setSelectedIndex(0);
            }
        } else {
            emit error(reply->errorString());
        }
    }
}



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

#ifndef GALLERYMANAGER_H
#define GALLERYMANAGER_H

#include <QObject>
#include <QUrl>
#include <QPair>
#include <QList>
#include <QStringList>
#include <QVariantMap>
#include <QQmlParserStatus>

#include "abstractmanager.h"
#include "apirequest.h"

class GalleryManager : public AbstractManager, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    Q_PROPERTY(QUrl galleryUrl READ galleryUrl WRITE setGalleryUrl NOTIFY galleryUrlChanged)
    Q_PROPERTY(QStringList thumbnailUrls READ thumbnailUrls NOTIFY thumbnailUrlsChanged)
    Q_PROPERTY(QUrl imageUrl READ imageUrl NOTIFY imageUrlChanged)
    Q_PROPERTY(QStringList imageUrls READ imageUrls NOTIFY imageUrlsChanged)
    Q_PROPERTY(QStringList previewUrls READ previewUrls NOTIFY previewUrlsChanged)
    Q_PROPERTY(int selectedIndex READ selectedIndex WRITE setSelectedIndex NOTIFY selectedIndexChanged)

public:
    explicit GalleryManager(QObject *parent = 0);

    void classBegin();
    void componentComplete();

    QUrl imageUrl() const;
    QStringList thumbnailUrls() const;
    QStringList imageUrls() const;
    QStringList previewUrls() const;

    int selectedIndex() const;
    void setSelectedIndex(int index);

    QUrl galleryUrl() const;
    void setGalleryUrl(const QUrl &galleryUrl);

    Q_INVOKABLE void refresh();

signals:
    void imageUrlChanged();
    void thumbnailUrlsChanged();
    void imageUrlsChanged();
    void previewUrlsChanged();
    void selectedIndexChanged();
    void galleryUrlChanged();
    void error(const QString &errorString);

private slots:
    void onFinished(QNetworkReply *reply);

private:
    QUrl m_imageUrl;
    QStringList m_thumbnailUrls;
    QStringList m_imageUrls;
    QStringList m_previewUrls;
    int m_selectedIndex;
    QUrl m_galleryUrl;

    QList< QPair<QVariantMap,QVariantMap> > m_galleryItemList;

    QString unescapeUrl(QString url);
};

#endif // GALLERYMANAGER_H

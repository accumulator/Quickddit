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

        m_imageUrl.clear();
        emit imageUrlChanged();

        m_imageUrl = m_imageAndThumbUrlList.at(m_selectedIndex).first;
        emit selectedIndexChanged();
        emit imageUrlChanged();
    }
}

void ImgurManager::getImageUrl(const QString &imgurUrl)
{
    if (m_reply != 0) {
        m_reply->disconnect();
        m_reply->deleteLater();
        m_reply = 0;
    }

    QString requestUrl = "https://api.imgur.com/3";

    QString id = imgurUrl.mid(imgurUrl.indexOf("imgur.com/") + 10);
    if (id.startsWith("a/")) {
        id.remove(0, 2);
        requestUrl += "/album/" + id + "/images";
    } else if (!id.contains('/')) {
        requestUrl += "/image/" + id;
    } else {
        emit error("Unable to get Imgur ID from the url: " + imgurUrl);
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
        m_imageUrl = m_imageAndThumbUrlList.first().first;
        if (m_imageAndThumbUrlList.count() > 1) {
            QListIterator< QPair<QString,QString> > i(m_imageAndThumbUrlList);
            while (i.hasNext()) {
                m_thumbnailUrls.append(i.next().second);
            }
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

#ifndef IMGURMANAGER_H
#define IMGURMANAGER_H

#include <QtCore/QStringList>

#include "abstractmanager.h"

class ImgurManager : public AbstractManager
{
    Q_OBJECT
    /**
     * (Read only)
     * The direct image url for the image
     * If the link is an album this will be the image url of selectedIndex
     */
    Q_PROPERTY(QUrl imageUrl READ imageUrl NOTIFY imageUrlChanged)
    /**
     * (Read only)
     * List of thumbnail urls for an album
     * This value is empty if the link is not an album
     */
    Q_PROPERTY(QStringList thumbnailUrls READ thumbnailUrls NOTIFY thumbnailUrlsChanged)
    /**
     * Specific which imageUrl to be set from the album
     * Have no effect if the link is not an album
     */
    Q_PROPERTY(int selectedIndex READ selectedIndex WRITE setSelectedIndex NOTIFY selectedIndexChanged)
public:
    explicit ImgurManager(QObject *parent = 0);

    QUrl imageUrl() const;
    QStringList thumbnailUrls() const;

    int selectedIndex() const;
    void setSelectedIndex(int index);

    /**
     * Get the image url and thumbnail url for the imgurUrl
     * Supported Imgur url formats:
     * - http://imgur.com/xxxxx (image)
     * - http://imgur.com/a/xxxxx (album)
     * - http://imgur.com/a/xxxxx#n (album, n = image index in the album)
     *
     * Unsupported Imgur url formats:
     * - http://imgur.com/gallery/xxxxx (because I don't know it is an album or image)
     * - any other url format
     */
    Q_INVOKABLE void getImageUrl(const QString &imgurUrl);

signals:
    void imageUrlChanged();
    void thumbnailUrlsChanged();
    void selectedIndexChanged();
    void error(const QString &errorString);

private slots:
    void onFinished();

private:
    QUrl m_imageUrl;
    QStringList m_thumbnailUrls;
    int m_selectedIndex;

    QNetworkReply *m_reply;
    QList< QPair<QString,QString> > m_imageAndThumbUrlList;
};

#endif // IMGURMANAGER_H

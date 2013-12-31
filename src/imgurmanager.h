#ifndef IMGURMANAGER_H
#define IMGURMANAGER_H

#include <QtCore/QStringList>
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
  #include <QtQml/QQmlParserStatus>
  #define DECL_QMLPARSERSTATUS_INTERFACE Q_INTERFACES(QQmlParserStatus)
#else
  #include <QtDeclarative/QDeclarativeParserStatus>
  #define QQmlParserStatus QDeclarativeParserStatus
  #define DECL_QMLPARSERSTATUS_INTERFACE Q_INTERFACES(QDeclarativeParserStatus)
#endif

#include "abstractmanager.h"

class ImgurManager : public AbstractManager, public QQmlParserStatus
{
    Q_OBJECT
    DECL_QMLPARSERSTATUS_INTERFACE
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
    /**
     * The Imgur url you want to get the images from
     * Must be set before calling refresh()
     *
     * Supported Imgur url formats:
     * - http://imgur.com/xxxxx (image)
     * - http://imgur.com/a/xxxxx (album)
     * - http://imgur.com/a/xxxxx#n (album, n = image index in the album)
     *
     * Unsupported Imgur url formats:
     * - http://imgur.com/gallery/xxxxx (because I don't know it is an album or image)
     * - any other url format
     */
    Q_PROPERTY(QString imgurUrl READ imgurUrl WRITE setImgurUrl NOTIFY imgurUrlChanged)
public:
    explicit ImgurManager(QObject *parent = 0);

    void classBegin();
    void componentComplete();

    QUrl imageUrl() const;
    QStringList thumbnailUrls() const;

    int selectedIndex() const;
    void setSelectedIndex(int index);

    QString imgurUrl() const;
    void setImgurUrl(const QString &imgurUrl);

    Q_INVOKABLE void refresh();

signals:
    void imageUrlChanged();
    void thumbnailUrlsChanged();
    void selectedIndexChanged();
    void imgurUrlChanged();
    void error(const QString &errorString);

private slots:
    void onFinished();

private:
    QUrl m_imageUrl;
    QStringList m_thumbnailUrls;
    int m_selectedIndex;
    QString m_imgurUrl;

    QNetworkReply *m_reply;
    QList< QPair<QString,QString> > m_imageAndThumbUrlList;
};

#endif // IMGURMANAGER_H

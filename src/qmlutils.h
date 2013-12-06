#ifndef QMLUTILS_H
#define QMLUTILS_H

#include <QtCore/QObject>

class QMLUtils : public QObject
{
    Q_OBJECT
public:
    explicit QMLUtils(QObject *parent = 0);

    // Copy text to system clipboard
    Q_INVOKABLE void copyToClipboard(const QString &text);

    // Share URL using integrated sharing in Harmattan
    Q_INVOKABLE void shareUrl(const QString &url, const QString &title = QString());

    /**
     * Get the short Reddit url (http://redd.it/xxxxxx)
     * @param fullname the fullname of the link (eg. "t3_abcdef")
     */
    Q_INVOKABLE QString getRedditShortUrl(const QString &fullname);

    /**
     * Get a full Reddit url from a relative url
     * @param relativeUrl the Reddit relative url
     */
    Q_INVOKABLE QString getRedditFullUrl(const QString &relativeUrl);
};

#endif // QMLUTILS_H

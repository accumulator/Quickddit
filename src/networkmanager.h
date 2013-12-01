#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QtCore/QObject>

class QNetworkAccessManager;
class QNetworkReply;
class QUrl;

class NetworkManager : public QObject
{
    Q_OBJECT
public:
    explicit NetworkManager(QObject *parent = 0);

    QNetworkReply *createGetRequest(const QUrl &url, const QByteArray &authHeader);
    QNetworkReply *createPostRequest(const QUrl &url, const QByteArray &data,
                                     const QByteArray &authHeader);

    QString downloadCounter() const;

signals:
    void downloadCounterChanged();

private slots:
    void increaseDownloadCounter(QNetworkReply *reply);

private:
    Q_DISABLE_COPY(NetworkManager)

    QNetworkAccessManager *m_networkAccessManager;
    qint64 m_downloadCounter; // in bytes
    QString m_downloadCounterStr; // in MB
};

#endif // NETWORKMANAGER_H

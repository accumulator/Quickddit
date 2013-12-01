#include "networkmanager.h"

#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>

static const QByteArray USER_AGENT = QByteArray("Quickddit/") + APP_VERSION;

NetworkManager::NetworkManager(QObject *parent) :
    QObject(parent), m_networkAccessManager(new QNetworkAccessManager(this)),
    m_downloadCounter(0), m_downloadCounterStr("0.00")
{
    connect(m_networkAccessManager, SIGNAL(finished(QNetworkReply*)),
            SLOT(increaseDownloadCounter(QNetworkReply*)));
}

QNetworkReply *NetworkManager::createGetRequest(const QUrl &url, const QByteArray &authHeader)
{
    QNetworkRequest request;
    request.setUrl(url);
    request.setRawHeader("User-Agent", USER_AGENT);
    if (!authHeader.isEmpty())
        request.setRawHeader("Authorization", authHeader);
    return m_networkAccessManager->get(request);
}

QNetworkReply *NetworkManager::createPostRequest(const QUrl &url, const QByteArray &data,
                                                 const QByteArray &authHeader)
{
    QNetworkRequest request;
    request.setUrl(url);
    request.setRawHeader("User-Agent", USER_AGENT);
    request.setRawHeader("Content-Type", "application/x-www-form-urlencoded");
    if (!authHeader.isEmpty())
        request.setRawHeader("Authorization", authHeader);
    return m_networkAccessManager->post(request, data);
}

QString NetworkManager::downloadCounter() const
{
    return m_downloadCounterStr;
}

void NetworkManager::increaseDownloadCounter(QNetworkReply *reply)
{
    m_downloadCounter += reply->size();
    const QString downloadCounterStr = QString::number(qreal(m_downloadCounter) / 1024 / 1024, 'f', 2);
    if (m_downloadCounterStr != downloadCounterStr) {
        m_downloadCounterStr = downloadCounterStr;
        emit downloadCounterChanged();
    }
}

#ifndef CAPTCHAMANAGER_H
#define CAPTCHAMANAGER_H

#include "abstractmanager.h"

class CaptchaManager : public AbstractManager
{
    Q_OBJECT
    Q_PROPERTY(QUrl imageUrl READ imageUrl NOTIFY imageUrlChanged)
    Q_PROPERTY(bool ready READ ready NOTIFY readyChanged)
    Q_PROPERTY(QString iden READ iden)
public:
    explicit CaptchaManager(QObject *parent = 0);
    QUrl imageUrl();
    bool ready();
    QString iden();

    Q_INVOKABLE void request();

signals:
    void error(const QString &errorString);
    void imageUrlChanged();
    void readyChanged();

private slots:
    void onRequestFinished(QNetworkReply *reply);

private:
    APIRequest *m_request;
    bool m_ready;
    QString m_iden;

    void abortActiveReply();
};

#endif // CAPTCHAMANAGER_H

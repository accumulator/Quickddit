#ifndef SEARCHMANAGER_H
#define SEARCHMANAGER_H

#include "abstractmanager.h"

class QNetworkReply;
class LinkModel;

class SearchManager : public AbstractManager
{
    Q_OBJECT
    // Read-only model for QML ListView
    Q_PROPERTY(LinkModel* model READ model NOTIFY modelChanged)
    Q_PROPERTY(QString query READ query WRITE setQuery NOTIFY queryChanged)
public:
    explicit SearchManager(QObject *parent = 0);

    LinkModel *model() const;

    QString query() const;
    void setQuery(const QString &query);

    Q_INVOKABLE void refresh(bool refreshOlder);

signals:
    void modelChanged();
    void queryChanged();
    void error(const QString &errorString);

private slots:
    void onNetworkReplyReceived(QNetworkReply *reply);
    void onFinished();

private:
    LinkModel *m_model;
    QString m_query;

    QNetworkReply *m_reply;
};

#endif // SEARCHMANAGER_H

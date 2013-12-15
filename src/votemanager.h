#ifndef VOTEMANAGER_H
#define VOTEMANAGER_H

#include "abstractmanager.h"

class VoteManager : public AbstractManager
{
    Q_OBJECT
    Q_ENUMS(Type)
    Q_ENUMS(VoteType)
    Q_PROPERTY(Type type READ type WRITE setType)
    Q_PROPERTY(QObject* model READ model WRITE setModel)
public:
    enum Type {
        Link,
        Comment
    };

    enum VoteType {
        Upvote,
        Downvote,
        Unvote
    };

    explicit VoteManager(QObject *parent = 0);

    Type type() const;
    void setType(Type type);

    QObject *model() const;
    void setModel(QObject *model);

    Q_INVOKABLE void vote(const QString &fullname, VoteType voteType);

signals:
    void error(const QString &errorString);

private slots:
    void onNetworkReplyReceived(QNetworkReply *reply);
    void onFinished();

private:
    Type m_type;
    QObject *m_model;

    QString m_fullname;
    VoteType m_voteType;
    QNetworkReply *m_reply;
};

#endif // VOTEMANAGER_H

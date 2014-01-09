#ifndef COMMENTMANAGER_H
#define COMMENTMANAGER_H

#include "abstractmanager.h"

class CommentModel;

class CommentManager : public AbstractManager
{
    Q_OBJECT
    Q_PROPERTY(CommentModel* model READ model WRITE setModel)
public:
    explicit CommentManager(QObject *parent = 0);

    CommentModel *model() const;
    void setModel(CommentModel *model);

    Q_INVOKABLE void addComment(const QString &replyTofullname, const QString &rawText);

signals:
    void error(const QString &errorString);

private slots:
    void onNetworkReplyReceived(QNetworkReply *reply);
    void onFinished();

private:
    CommentModel *m_model;
    QString m_replyToFullname;
    QNetworkReply *m_reply;

    void abortActiveReply();
};

#endif // COMMENTMANAGER_H

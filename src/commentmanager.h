#ifndef COMMENTMANAGER_H
#define COMMENTMANAGER_H

#include "abstractmanager.h"

class QNetworkReply;
class CommentModel;

class CommentManager : public AbstractManager
{
    Q_OBJECT
    Q_ENUMS(SortType)
    Q_PROPERTY(CommentModel* model READ model NOTIFY modelChanged)
    Q_PROPERTY(QString permalink READ permalink WRITE setPermalink NOTIFY permalinkChanged)
    Q_PROPERTY(SortType sort READ sort WRITE setSort NOTIFY sortChanged)
public:
    enum SortType {
        ConfidenceSort, // a.k.a. "best"
        TopSort,
        NewSort,
        HotSort,
        ControversialSort,
        OldSort
    };

    CommentManager(QObject *parent = 0);

    CommentModel *model() const;

    QString permalink() const;
    void setPermalink(const QString &permalink);

    SortType sort() const;
    void setSort(SortType sort);

    /**
     * Refresh for comments depends on the "permalink" and "sort" properties
     */
    Q_INVOKABLE void refresh();

signals:
    void modelChanged();
    void permalinkChanged();
    void sortChanged();
    void error(const QString &errorString);

private slots:
    void onNetworkReplyReceived(QNetworkReply *reply);
    void onFinished();

private:
    CommentModel *m_model;
    QString m_permalink;
    SortType m_sort;

    QNetworkReply *m_reply;

    static QString getSortString(SortType sort);
};

#endif // COMMENTMANAGER_H

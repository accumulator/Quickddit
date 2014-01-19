/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see [http://www.gnu.org/licenses/].
*/

#ifndef COMMENTMODEL_H
#define COMMENTMODEL_H

#include "abstractlistmodelmanager.h"
#include "commentobject.h"

class CommentModel : public AbstractListModelManager
{
    Q_OBJECT
    Q_ENUMS(SortType)
    Q_PROPERTY(QString permalink READ permalink WRITE setPermalink NOTIFY permalinkChanged)
    Q_PROPERTY(SortType sort READ sort WRITE setSort NOTIFY sortChanged)
public:
    enum Roles {
        FullnameRole = Qt::UserRole,
        AuthorRole,
        BodyRole,
        RawBodyRole,
        ScoreRole,
        LikesRole,
        CreatedRole,
        DepthRole,
        IsScoreHiddenRole,
        IsValidRole,
        IsAuthorRole
    };

    enum SortType {
        ConfidenceSort, // a.k.a. "best"
        TopSort,
        NewSort,
        HotSort,
        ControversialSort,
        OldSort
    };

    explicit CommentModel(QObject *parent = 0);

    void classBegin();
    void componentComplete();

    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;

    QString permalink() const;
    void setPermalink(const QString &permalink);

    SortType sort() const;
    void setSort(SortType sort);

    // C++ functions
    void insertComment(CommentObject comment, const QString &replyToFullname);
    void editComment(CommentObject comment);
    void deleteComment(const QString &fullname);

    // QML functions
    void refresh(bool refreshOlder);
    Q_INVOKABLE int getParentIndex(int index) const;
    Q_INVOKABLE void changeLikes(const QString &fullname, int likes);

protected:
    QHash<int, QByteArray> customRoleNames() const;

signals:
    void permalinkChanged();
    void sortChanged();
    void commentLoaded();

private slots:
    void onNetworkReplyReceived(QNetworkReply *reply);
    void onFinished();

private:
    QString m_permalink;
    SortType m_sort;

    QList<CommentObject> m_commentList;
    QNetworkReply *m_reply;

    static QString getSortString(SortType sort);
};

#endif // COMMENTMODEL_H

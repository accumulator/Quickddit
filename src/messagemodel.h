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

#ifndef MESSAGEMODEL_H
#define MESSAGEMODEL_H

#include "abstractlistmodelmanager.h"
#include "messageobject.h"

class MessageModel : public AbstractListModelManager
{
    Q_OBJECT
    Q_ENUMS(Section)
    Q_PROPERTY(Section section READ section WRITE setSection NOTIFY sectionChanged)
public:
    enum Roles {
        FullnameRole = Qt::UserRole,
        AuthorRole,
        DestinationRole,
        BodyRole,
        RawBodyRole,
        CreatedRole,
        SubjectRole,
        LinkTitleRole,
        SubredditRole,
        ContextRole,
        IsCommentRole,
        IsUnreadRole
    };

    enum Section {
        AllSection,
        UnreadSection,
        MessageSection,
        CommentRepliesSection,
        PostRepliesSection,
        SentSection,
        UndefinedSection = 100 // internal only
    };

    static QVariantMap toMessageVariantMap(const MessageObject &m);

    explicit MessageModel(QObject *parent = 0);

    void classBegin();
    void componentComplete();

    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;

    Section section() const;
    void setSection(Section section);

    void refresh(bool refreshOlder);
    Q_INVOKABLE void changeIsUnread(const QString &fullname, bool isUnread);

signals:
    void sectionChanged();

protected:
    QHash<int, QByteArray> customRoleNames() const;

private slots:
    void onFinished(QNetworkReply *reply);

private:
    Section m_section;
    QList<MessageObject> m_messageList;
};

#endif // MESSAGEMODEL_H

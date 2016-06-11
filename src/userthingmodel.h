/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2016  Sander van Grieken

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

#ifndef USERTHINGMODEL_H
#define USERTHINGMODEL_H

#include "abstractlistmodelmanager.h"
#include "parser.h"
#include "commentobject.h"
#include "linkobject.h"

class UserThingModelData;

class UserThingModel : public AbstractListModelManager
{
    Q_OBJECT
    Q_ENUMS(Section)
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY(Section section READ section WRITE setSection NOTIFY sectionChanged)
public:
    enum Roles {
        KindRole = Qt::UserRole,
        CommentRole,
        LinkRole
    };

    enum Section {
        OverviewSection,
        CommentsSection,
        SubmittedSection,
        UpvotedSection,
        DownvotedSection,
        SavedSection
    };

    explicit UserThingModel(QObject *parent = 0);
    ~UserThingModel();

    void classBegin();
    void componentComplete();
    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;

    void refresh(bool refreshOlder);

    QString username() const;
    void setUsername(const QString &username);

    Section section() const;
    void setSection(Section section);

signals:
    void usernameChanged();
    void sectionChanged();

public slots:

private slots:
    void onFinished(QNetworkReply *reply);

protected:
    QHash<int, QByteArray> customRoleNames() const;

private:
    QString m_username;
    Section m_section;
    Listing<Thing*> m_thingList;

    QVariantMap commentData(const CommentObject* o) const;
    QVariantMap linkData(const LinkObject* o) const;

    void clearThingList();
};

#endif // USERTHINGMODEL_H

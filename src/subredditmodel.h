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

#ifndef SUBREDDITMODEL_H
#define SUBREDDITMODEL_H

#include "abstractlistmodelmanager.h"
#include "subredditobject.h"

class SubredditModel : public AbstractListModelManager
{
    Q_OBJECT
    Q_ENUMS(Section)
    Q_PROPERTY(Section section READ section WRITE setSection NOTIFY sectionChanged)
    Q_PROPERTY(QString query READ query WRITE setQuery NOTIFY queryChanged)
public:
    enum Roles {
        FullnameRole = Qt::UserRole,
        DisplayNameRole,
        UrlRole,
        HeaderImageUrlRole,
        ShortDescriptionRole,
        LongDescriptionRole,
        SubscribersRole,
        ActiveUsersRole,
        IsNSFWRole
    };

    enum Section {
        PopularSection,
        NewSection,
        UserAsSubscriberSection,
        UserAsContributorSection,
        UserAsModeratorSection,
        SearchSection
    };

    explicit SubredditModel(QObject *parent = 0);

    void classBegin();
    void componentComplete();

    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;

    Section section() const;
    void setSection(Section section);

    QString query() const;
    void setQuery(const QString &query);

    void refresh(bool refreshOlder);

    void deleteSubreddit(const QString &subreddit);

protected:
    QHash<int, QByteArray> customRoleNames() const;

signals:
    void sectionChanged();
    void queryChanged();

private slots:
    void onFinished(QNetworkReply *reply);

private:
    Section m_section;
    QString m_query;

    QList<SubredditObject> m_subredditList;
    APIRequest *m_request;
};

#endif // SUBREDDITMODEL_H

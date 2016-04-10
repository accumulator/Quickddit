/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2015  Sander van Grieken

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

#ifndef LINKMODEL_H
#define LINKMODEL_H

#include "abstractlistmodelmanager.h"
#include "linkobject.h"

class LinkModel : public AbstractListModelManager
{
    Q_OBJECT
    Q_ENUMS(Location)
    Q_ENUMS(Section)
    Q_ENUMS(SearchSortType)
    Q_ENUMS(SearchTimeRange)

    Q_PROPERTY(QString title READ title NOTIFY titleChanged)
    Q_PROPERTY(Location location READ location WRITE setLocation NOTIFY locationChanged)
    Q_PROPERTY(Section section READ section WRITE setSection NOTIFY sectionChanged)
    Q_PROPERTY(QString subreddit READ subreddit WRITE setSubreddit NOTIFY subredditChanged)
    Q_PROPERTY(QString multireddit READ multireddit WRITE setMultireddit NOTIFY multiredditChanged)

    // Only for Search
    Q_PROPERTY(QString searchQuery READ searchQuery WRITE setSearchQuery NOTIFY searchQueryChanged)
    Q_PROPERTY(SearchSortType searchSort READ searchSort WRITE setSearchSort NOTIFY searchSortChanged)
    Q_PROPERTY(SearchTimeRange searchTimeRange READ searchTimeRange WRITE setSearchTimeRange
               NOTIFY searchTimeRangeChanged)
public:
    enum Roles {
        FullnameRole = Qt::UserRole,
        AuthorRole,
        CreatedRole,
        SubredditRole,
        ScoreRole,
        LikesRole,
        CommentsCountRole,
        TitleRole,
        DomainRole,
        ThumbnailUrlRole,
        TextRole,
        RawTextRole,
        PermalinkRole,
        UrlRole,
        IsStickyRole,
        IsNSFWRole,
        IsPromotedRole,
        FlairTextRole,
        IsSelfPostRole,
        IsSavedRole
    };

    enum Location {
        FrontPage,
        All,
        Subreddit,
        Multireddit,
        Search
    };

    enum Section {
        HotSection,
        NewSection,
        RisingSection,
        ControversialSection,
        TopSection,
        PromotedSection
    };

    enum SearchSortType {
        RelevanceSort,
        NewSort,
        HotSort,
        TopSort,
        CommentsSort
    };

    enum SearchTimeRange {
        AllTime,
        Hour,
        Day,
        Week,
        Month,
        Year
    };

    static QVariantMap toLinkVariantMap(const LinkObject &link);

    explicit LinkModel(QObject *parent = 0);

    void classBegin();
    void componentComplete();

    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;

    QString title() const;

    Location location() const;
    void setLocation(Location location);

    Section section() const;
    void setSection(Section section);

    QString subreddit() const;
    void setSubreddit(const QString &subreddit);

    QString multireddit() const;
    void setMultireddit(const QString &multireddit);

    QString searchQuery() const;
    void setSearchQuery(const QString &query);

    SearchSortType searchSort() const;
    void setSearchSort(SearchSortType sort);

    SearchTimeRange searchTimeRange() const;
    void setSearchTimeRange(SearchTimeRange timeRange);

    void refresh(bool refreshOlder);
    Q_INVOKABLE void changeLikes(const QString &fullname, int likes);

    void editLink(const LinkObject &link);

protected:
    QHash<int, QByteArray> customRoleNames() const;

signals:
    void titleChanged();
    void locationChanged();
    void sectionChanged();
    void subredditChanged();
    void multiredditChanged();
    void searchQueryChanged();
    void searchSortChanged();
    void searchTimeRangeChanged();

private slots:
    void onFinished(QNetworkReply *reply);

private:
    QString m_title;
    Location m_location;
    Section m_section;
    QString m_subreddit;
    QString m_multireddit;
    QString m_searchQuery;
    SearchSortType m_searchSort;
    SearchTimeRange m_searchTimeRange;

    QList<LinkObject> m_linkList;
    APIRequest *m_request;

    static QString getSectionString(Section section);
    static QString getSearchSortString(SearchSortType sort);
    static QString getSearchTimeRangeString(SearchTimeRange timeRange);
};

#endif // LINKMODEL_H

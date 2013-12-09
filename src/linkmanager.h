#ifndef LINKMANAGER_H
#define LINKMANAGER_H

#include "abstractmanager.h"

class QNetworkReply;
class LinkModel;

class LinkManager : public AbstractManager
{
    Q_OBJECT
    Q_ENUMS(Section)
    Q_ENUMS(SearchSortType)
    Q_ENUMS(SearchTimeRange)

    // Read-only model for QML ListView
    Q_PROPERTY(LinkModel* model READ model NOTIFY modelChanged)
    // Read-only title for display in page header
    Q_PROPERTY(QString title READ title NOTIFY titleChanged)

    Q_PROPERTY(Section section READ section WRITE setSection NOTIFY sectionChanged)
    Q_PROPERTY(QString subreddit READ subreddit WRITE setSubreddit NOTIFY subredditChanged)

    // Only for SearchSection
    Q_PROPERTY(QString searchQuery READ searchQuery WRITE setSearchQuery NOTIFY searchQueryChanged)
    Q_PROPERTY(SearchSortType searchSort READ searchSort WRITE setSearchSort NOTIFY searchSortChanged)
    Q_PROPERTY(SearchTimeRange searchTimeRange READ searchTimeRange WRITE setSearchTimeRange
               NOTIFY searchTimeRangeChanged)
public:
    enum Section {
        HotSection,
        NewSection,
        RisingSection,
        ControversialSection,
        TopSection,
        SearchSection
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

    explicit LinkManager(QObject *parent = 0);

    LinkModel *model() const;
    QString title() const;

    Section section() const;
    void setSection(Section section);

    QString subreddit() const;
    void setSubreddit(const QString &subreddit);

    QString searchQuery() const;
    void setSearchQuery(const QString &query);

    SearchSortType searchSort() const;
    void setSearchSort(SearchSortType sort);

    SearchTimeRange searchTimeRange() const;
    void setSearchTimeRange(SearchTimeRange timeRange);

    /**
     * Refresh for links
     * refreshOlder: true if refresh for older listings, false for refresh all
     */
    Q_INVOKABLE void refresh(bool refreshOlder);

signals:
    void modelChanged();
    void titleChanged();
    void sectionChanged();
    void subredditChanged();
    void searchQueryChanged();
    void searchSortChanged();
    void searchTimeRangeChanged();
    void error(const QString &errorString);

private slots:
    void onNetworkReplyReceived(QNetworkReply *reply);
    void onFinished();

private:
    LinkModel *m_model;
    QString m_title;
    Section m_section;
    QString m_subreddit;
    QString m_searchQuery;
    SearchSortType m_searchSort;
    SearchTimeRange m_searchTimeRange;

    QNetworkReply *m_reply;

    static QString getSectionString(Section section);
    static QString getSearchSortString(SearchSortType sort);
    static QString getSearchTimeRangeString(SearchTimeRange timeRange);
};

#endif // LINKMANAGER_H

#include "linkmanager.h"

#include <QtNetwork/QNetworkReply>

#include "linkmodel.h"
#include "parser.h"

LinkManager::LinkManager(QObject *parent) :
    AbstractManager(parent), m_model(new LinkModel(this)), m_section(HotSection),
    m_searchSort(RelevanceSort), m_searchTimeRange(AllTime), m_reply(0)
{
}

LinkModel *LinkManager::model() const
{
    return m_model;
}

QString LinkManager::title() const
{
    return m_title;
}

LinkManager::Section LinkManager::section() const
{
    return m_section;
}

void LinkManager::setSection(LinkManager::Section section)
{
    if (m_section != section) {
        m_section = section;
        emit sectionChanged();
    }
}

QString LinkManager::subreddit() const
{
    return m_subreddit;
}

void LinkManager::setSubreddit(const QString &subreddit)
{
    if (m_subreddit != subreddit) {
        m_subreddit = subreddit;
        emit subredditChanged();
    }
}

QString LinkManager::searchQuery() const
{
    return m_searchQuery;
}

void LinkManager::setSearchQuery(const QString &query)
{
    if (m_searchQuery != query) {
        m_searchQuery = query;
        emit searchQueryChanged();
    }
}

LinkManager::SearchSortType LinkManager::searchSort() const
{
    return m_searchSort;
}

void LinkManager::setSearchSort(SearchSortType sort)
{
    if (m_searchSort != sort) {
        m_searchSort = sort;
        emit searchSortChanged();
    }
}

LinkManager::SearchTimeRange LinkManager::searchTimeRange() const
{
    return m_searchTimeRange;
}

void LinkManager::setSearchTimeRange(SearchTimeRange timeRange)
{
    if (m_searchTimeRange != timeRange) {
        m_searchTimeRange = timeRange;
        emit searchTimeRangeChanged();
    }
}

void LinkManager::refresh(bool refreshOlder)
{
    if (m_reply != 0) {
        m_reply->disconnect();
        m_reply->deleteLater();
        m_reply = 0;
    }

    if (refreshOlder && m_model->count() == 0)
        refreshOlder = false;
    else if (!refreshOlder && m_model->count() > 0)
        m_model->clear();

    QString relativeUrl = "/";
    QHash<QString,QString> parameters;
    parameters["limit"] = "50";

    if (m_section == SearchSection) {
        parameters["q"] = m_searchQuery;
        parameters["sort"] = getSearchSortString(m_searchSort);
        parameters["t"] = getSearchTimeRangeString(m_searchTimeRange);
        relativeUrl += "search";
    } else {
        if (!m_subreddit.isEmpty())
            relativeUrl += "r/" + m_subreddit + "/";
        relativeUrl += getSectionString(m_section);
    }

    if (refreshOlder) {
        parameters["count"] = QString::number(m_model->count());
        parameters["after"] = m_model->lastFullname();
    }

    connect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)),
            SLOT(onNetworkReplyReceived(QNetworkReply*)));
    manager()->createRedditGetRequest(relativeUrl, parameters);

    m_title = relativeUrl;
    emit titleChanged();
    setBusy(true);
}

void LinkManager::onNetworkReplyReceived(QNetworkReply *reply)
{
    disconnect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)),
               this, SLOT(onNetworkReplyReceived(QNetworkReply*)));
    if (reply != 0) {
        m_reply = reply;
        m_reply->setParent(this);
        connect(m_reply, SIGNAL(finished()), SLOT(onFinished()));
    } else {
        setBusy(false);
    }
}

void LinkManager::onFinished()
{
    if (m_reply->error() == QNetworkReply::NoError)
        m_model->append(Parser::parseLinkList(m_reply->readAll()));
    else
        emit error(m_reply->errorString());

    m_reply->deleteLater();
    m_reply = 0;
    setBusy(false);
}

QString LinkManager::getSectionString(LinkManager::Section section)
{
    switch (section) {
    case HotSection: return "hot";
    case NewSection: return "new";
    case RisingSection: return "rising";
    case ControversialSection: return "controversial";
    case TopSection: return "top";
    default:
        qWarning("LinkManager::getSectionString(): Invalid section");
        return "";
    }
}

QString LinkManager::getSearchSortString(SearchSortType sort)
{
    switch (sort) {
    case RelevanceSort: return "relevance";
    case NewSort: return "new";
    case HotSort: return "hot";
    case TopSort: return "top";
    case CommentsSort: return "comments";
    default:
        qWarning("LinkManager::getSearchSortString(): Invalid sort");
        return "";
    }
}

QString LinkManager::getSearchTimeRangeString(SearchTimeRange timeRange)
{
    switch (timeRange) {
    case AllTime: return "all";
    case Hour: return "hour";
    case Day: return "day";
    case Week: return "week";
    case Month: return "month";
    case Year: return "year";
    default:
        qWarning("LinkManager::getSearchTimeRangeString(): Invalid time range");
        return "";
    }
}

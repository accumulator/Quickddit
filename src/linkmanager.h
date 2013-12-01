#ifndef LINKMANAGER_H
#define LINKMANAGER_H

#include "abstractmanager.h"

class QNetworkReply;
class LinkModel;

class LinkManager : public AbstractManager
{
    Q_OBJECT
    Q_ENUMS(Section)

    // Read-only model for QML ListView
    Q_PROPERTY(LinkModel* model READ model NOTIFY modelChanged)
    // Read-only title for display in page header
    Q_PROPERTY(QString title READ title NOTIFY titleChanged)

    Q_PROPERTY(QString subreddit READ subreddit WRITE setSubreddit NOTIFY subredditChanged)
    Q_PROPERTY(Section section READ section WRITE setSection NOTIFY sectionChanged)
public:
    enum Section {
        HotSection,
        NewSection,
        RisingSection,
        ControversialSection,
        TopSection
    };

    explicit LinkManager(QObject *parent = 0);

    LinkModel *model() const;
    QString title() const;

    QString subreddit() const;
    void setSubreddit(const QString &subreddit);

    Section section() const;
    void setSection(Section section);

    /**
     * Refresh for links
     * refreshOlder: true if refresh for older listings, false for refresh all
     */
    Q_INVOKABLE void refresh(bool refreshOlder);

signals:
    void modelChanged();
    void titleChanged();
    void subredditChanged();
    void sectionChanged();
    void error(const QString &errorString);

private slots:
    void onNetworkReplyReceived(QNetworkReply *reply);
    void onFinished();

private:
    LinkModel *m_model;
    QString m_title;
    QString m_subreddit;
    Section m_section;
    QNetworkReply *m_reply;

    static QString getSectionString(Section section);
};

#endif // LINKMANAGER_H

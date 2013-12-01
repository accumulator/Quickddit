#ifndef COMMENTOBJECT_H
#define COMMENTOBJECT_H

#include <QtCore/QExplicitlySharedDataPointer>
#include <QtCore/QList>

class QDateTime;
class CommentObjectData;

class CommentObject
{
public:
    enum DistinguishedType {
        NotDistinguished,
        DistinguishedByModerator,
        DistinguishedByAdmin,
        DistinguishedBySpecial
    };

    CommentObject();
    CommentObject(const CommentObject &other);
    CommentObject &operator= (const CommentObject &other);
    ~CommentObject();

    QString fullname() const;
    void setFullname(const QString &fullname);

    QString author() const;
    void setAuthor(const QString &author);

    QString body() const;
    void setBody(const QString &body);

    int score() const;
    void setScore(int score);

    QDateTime created() const;
    void setCreated(const QDateTime &created);

    QDateTime edited() const;
    void setEdited(const QDateTime &edited);

    DistinguishedType distinguished() const;
    void setDistinguished(DistinguishedType distinguished);
    void setDistinguished(const QString &distinguishedString);

    int depth() const;
    void setDepth(int depth);

    bool isSubmitter() const;
    void setSubmitter(bool submitter);

    bool isScoreHidden() const;
    void setScoreHidden(bool scoreHidden);

private:
    QExplicitlySharedDataPointer<CommentObjectData> d;
};

#endif // COMMENTOBJECT_H

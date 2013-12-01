#include "commentobject.h"

#include <QtCore/QSharedData>
#include <QtCore/QDateTime>

class CommentObjectData : public QSharedData
{
public:
    CommentObjectData() : score(0), distinguished(CommentObject::NotDistinguished), depth(0),
        isSubmitter(false), isScoreHidden(false) {}

    QString fullname;
    QString author;
    QString body;
    int score;
    QDateTime created;
    QDateTime edited;
    CommentObject::DistinguishedType distinguished;
    int depth;
    bool isSubmitter;
    bool isScoreHidden;

private:
    Q_DISABLE_COPY(CommentObjectData)
};

CommentObject::CommentObject()
    : d(new CommentObjectData)
{
}

CommentObject::CommentObject(const CommentObject &other)
    : d(other.d)
{
}

CommentObject &CommentObject::operator =(const CommentObject &other)
{
    d = other.d;
    return *this;
}

CommentObject::~CommentObject()
{
}

QString CommentObject::fullname() const
{
    return d->fullname;
}

void CommentObject::setFullname(const QString &fullname)
{
    d->fullname = fullname;
}

QString CommentObject::author() const
{
    return d->author;
}

void CommentObject::setAuthor(const QString &author)
{
    d->author = author;
}

QString CommentObject::body() const
{
    return d->body;
}

void CommentObject::setBody(const QString &body)
{
    d->body = body;
}

int CommentObject::score() const
{
    return d->score;
}

void CommentObject::setScore(int score)
{
    d->score = score;
}

QDateTime CommentObject::created() const
{
    return d->created;
}

void CommentObject::setCreated(const QDateTime &created)
{
    d->created = created;
}

QDateTime CommentObject::edited() const
{
    return d->edited;
}

void CommentObject::setEdited(const QDateTime &edited)
{
    d->edited = edited;
}

CommentObject::DistinguishedType CommentObject::distinguished() const
{
    return d->distinguished;
}

void CommentObject::setDistinguished(CommentObject::DistinguishedType distinguished)
{
    d->distinguished = distinguished;
}

void CommentObject::setDistinguished(const QString &distinguishedString)
{
    if (distinguishedString.isEmpty())
        d->distinguished = NotDistinguished;
    else if (distinguishedString == "moderator")
        d->distinguished = DistinguishedByModerator;
    else if (distinguishedString == "admin")
        d->distinguished = DistinguishedByAdmin;
    else if (distinguishedString == "special")
        d->distinguished = DistinguishedBySpecial;
}

int CommentObject::depth() const
{
    return d->depth;
}

void CommentObject::setDepth(int depth)
{
    d->depth = depth;
}

bool CommentObject::isSubmitter() const
{
    return d->isSubmitter;
}

void CommentObject::setSubmitter(bool submitter)
{
    d->isSubmitter = submitter;
}

bool CommentObject::isScoreHidden() const
{
    return d->isScoreHidden;
}

void CommentObject::setScoreHidden(bool scoreHidden)
{
    d->isScoreHidden = scoreHidden;
}

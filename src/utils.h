#ifndef UTILS_H
#define UTILS_H

class QString;
class QDateTime;

namespace Utils
{
QString getTimeDiff(const QDateTime &created);
}

#endif // UTILS_H

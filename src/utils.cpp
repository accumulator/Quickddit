#include "utils.h"

#include <QtCore/QString>
#include <QtCore/QDateTime>

QString Utils::getTimeDiff(const QDateTime &created)
{
    const QDateTime localTime = created.toLocalTime();

    int diff = QDateTime::currentDateTime().toTime_t() - localTime.toTime_t(); // seconds

    if (diff <= 0)
        return "Now";
    else if (diff < 60)
        return "Just now";

    diff /= 60; // minutes

    if (diff < 60)
        return QString::number(diff) + " mins ago";

    diff /= 60; // hours

    if (diff < 24)
        return QString::number(diff) + " hours ago";

    diff /= 24; // days

    if (diff < 30)
        return QString::number(diff) + " days ago";

    diff /= 30; // months

    if (diff < 12)
        return QString::number(diff) + " months ago";

    diff /= 12; // years
    return QString::number(diff) + " years ago";
}

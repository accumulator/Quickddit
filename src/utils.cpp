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

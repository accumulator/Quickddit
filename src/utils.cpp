/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2018  Sander van Grieken

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
#include <QtCore/QStringList>
#include <QtCore/QDateTime>
#include <QtCore/QByteArray>
#include <QtCore/QHash>
#include <QtCore/QUrl>

QString Utils::getTimeDiff(const QDateTime &created)
{
    const QDateTime localTime = created.toLocalTime();

    int diff = QDateTime::currentDateTime().toTime_t() - localTime.toTime_t(); // seconds

    if (diff <= 0)
        return tr("Now");
    else if (diff < 60)
        return tr("Just now");

    diff /= 60; // minutes

    if (diff < 60)
        return tr("%n mins ago", "", diff);

    diff /= 60; // hours

    if (diff < 24)
        return tr("%n hours ago", "", diff);

    diff /= 24; // days

    if (diff < 30)
        return tr("%n days ago", "", diff);

    diff /= 30; // months

    if (diff < 12)
        return tr("%n months ago", "", diff);

    diff /= 12; // years
    return tr("%n years ago", "", diff);
}

bool caseInsensitiveLessThan(const QString &s1, const QString &s2)
{
    return s1.toLower() < s2.toLower();
}

void Utils::sortCaseInsensitively(QStringList *stringList)
{
    qSort(stringList->begin(), stringList->end(), caseInsensitiveLessThan);
}

QByteArray Utils::toEncodedQuery(const QHash<QString, QString> &parameters)
{
    QByteArray encodedQuery;
    QHashIterator<QString, QString> i(parameters);
    while (i.hasNext()) {
        i.next();
        encodedQuery += QUrl::toPercentEncoding(i.key()) + '=' + QUrl::toPercentEncoding(i.value()) + '&';
    }
    encodedQuery.chop(1); // chop the last '&'
    return encodedQuery;
}

void Utils::setUrlQuery(QUrl *url, const QHash<QString, QString> &parameters)
{
#if (QT_VERSION >= QT_VERSION_CHECK(5,0,0))
    url->setQuery(QString::fromUtf8(toEncodedQuery(parameters)), QUrl::StrictMode);
#else
    url->setEncodedQuery(toEncodedQuery(parameters));
#endif
}

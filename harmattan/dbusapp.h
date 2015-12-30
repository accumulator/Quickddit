/*
    Quickddit - Reddit client for mobile phones
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

#ifndef DBUSAPP_H
#define DBUSAPP_H

#include <QObject>

class DbusApp : public QObject
{
    Q_OBJECT
public:
    explicit DbusApp(QObject *parent = 0);

signals:
    void requestMessageView(const QString &fullname = "");

public slots:
    void showInbox();
    void showInboxFor(const QString& target);
};

#endif // DBUSAPP_H

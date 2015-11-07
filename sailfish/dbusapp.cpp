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

#include <QDBusConnection>
#include <QDebug>

#include "dbusapp.h"
#include "app_adaptor.h"
#include "app_interface.h"

DbusApp::DbusApp(QObject *parent) :
    QObject(parent)
{
    new ViewAdaptor(this);

    QDBusConnection c = QDBusConnection::sessionBus();
    bool ret = c.registerService("org.quickddit");
    Q_ASSERT(ret);
    ret = c.registerObject("/", this);
    Q_ASSERT(ret);
}

void DbusApp::showInbox()
{
    qDebug() << "showInbox";
    emit requestMessageView();
}

void DbusApp::showInboxFor(const QString& target)
{
    qDebug() << "showInboxFor" << target;
    emit requestMessageView(target);
}

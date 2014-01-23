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

#ifndef ABSTRACTLISTMODELMANAGER_H
#define ABSTRACTLISTMODELMANAGER_H

#include <QtCore/QAbstractListModel>
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
  #include <QtQml/QQmlParserStatus>
  #define DECL_QMLPARSERSTATUS_INTERFACE Q_INTERFACES(QQmlParserStatus)
#else
  #include <QtDeclarative/QDeclarativeParserStatus>
  #define QQmlParserStatus QDeclarativeParserStatus
  #define DECL_QMLPARSERSTATUS_INTERFACE Q_INTERFACES(QDeclarativeParserStatus)
#endif

#include "quickdditmanager.h"

class AbstractListModelManager : public QAbstractListModel, public QQmlParserStatus
{
    Q_OBJECT
    DECL_QMLPARSERSTATUS_INTERFACE
    Q_PROPERTY(bool busy READ isBusy NOTIFY busyChanged)
    Q_PROPERTY(bool canLoadMore READ canLoadMore NOTIFY canLoadMoreChanged)
    Q_PROPERTY(QuickdditManager* manager READ manager WRITE setManager)
public:
    explicit AbstractListModelManager(QObject *parent = 0);

#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
    QHash<int, QByteArray> roleNames() const;
#endif

    bool isBusy() const;
    bool canLoadMore() const;

    QuickdditManager *manager() const;
    void setManager(QuickdditManager *manager);

    Q_INVOKABLE virtual void refresh(bool refreshOlder) = 0;

protected:
    void setBusy(bool busy);
    void setCanLoadMore(bool canLoadMore);
    virtual QHash<int, QByteArray> customRoleNames() const = 0;

signals:
    void busyChanged();
    void canLoadMoreChanged();
    void error(const QString &errorString);

private:
    bool m_busy;
    bool m_canLoadMore;
    QuickdditManager *m_manager;
};

#endif // ABSTRACTLISTMODELMANAGER_H

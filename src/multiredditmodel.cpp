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

#include "multiredditmodel.h"

#include <QtNetwork/QNetworkReply>

#include "parser.h"
#include "utils.h"

MultiredditModel::MultiredditModel(QObject *parent) :
    AbstractListModelManager(parent)
{
#if (QT_VERSION < QT_VERSION_CHECK(5, 0, 0))
    setRoleNames(customRoleNames());
#endif
    setCanLoadMore(false);
}

void MultiredditModel::classBegin()
{
}

void MultiredditModel::componentComplete()
{
//    refresh(false);
}

int MultiredditModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_multiredditList.count();
}

QVariant MultiredditModel::data(const QModelIndex &index, int role) const
{
    const MultiredditObject multireddit = m_multiredditList.at(index.row());

    switch (role) {
    case NameRole: return multireddit.name();
    default:
        qCritical("MultiredditModel::data(): Invalid role");
        return QVariant();
    }
}

void MultiredditModel::refresh(bool refreshOlder)
{
    Q_UNUSED(refreshOlder)

    if (!m_multiredditList.isEmpty()) {
        beginRemoveRows(QModelIndex(), 0, m_multiredditList.count() - 1);
        m_multiredditList.clear();
        endRemoveRows();
    }

    doRequest(APIRequest::GET, "/api/multi/mine", SLOT(onFinished(QNetworkReply*)));
}

MultiredditObject MultiredditModel::getMultireddit(const QString &name)
{
    foreach (const MultiredditObject &m, m_multiredditList) {
        if (m.name() == name)
            return m;
    }

    qCritical("MultiredditModel::getMultireddit(): Unable to find the multireddit");
    return MultiredditObject();
}

QHash<int, QByteArray> MultiredditModel::customRoleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    return roles;
}

void MultiredditModel::onFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            const QList<MultiredditObject> multiredditList = Parser::parseMultiredditList(reply->readAll());
            if (!multiredditList.isEmpty()) {
                beginInsertRows(QModelIndex(), m_multiredditList.count(),
                                m_multiredditList.count() + multiredditList.count() - 1);
                m_multiredditList.append(multiredditList);
                endInsertRows();
            }
        } else {
            emit error(reply->errorString());
        }
    }
}

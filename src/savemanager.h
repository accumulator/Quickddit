/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2016  Sander van Grieken

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

#ifndef SAVEMANAGER_H
#define SAVEMANAGER_H

#include "abstractmanager.h"

class SaveManager : public AbstractManager
{
    Q_OBJECT

public:
    SaveManager(QObject *parent = 0);
    Q_INVOKABLE void save(const QString &fullname, bool save = true);
    Q_INVOKABLE void unsave(const QString &fullname);

signals:
    void success(const QString &fullname, bool saved);
    void error(const QString &errorString);

private slots:
    void onFinished(QNetworkReply *reply);

private:
    QString m_fullname;
    bool m_save;
};

#endif // SAVEMANAGER_H

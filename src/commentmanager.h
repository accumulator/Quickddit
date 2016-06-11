/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
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

#ifndef COMMENTMANAGER_H
#define COMMENTMANAGER_H

#include "abstractmanager.h"

class CommentModel;

class CommentManager : public AbstractManager
{
    Q_OBJECT
    Q_PROPERTY(CommentModel* model READ model WRITE setModel)
    Q_PROPERTY(QString linkAuthor READ linkAuthor WRITE setLinkAuthor)
public:
    explicit CommentManager(QObject *parent = 0);

    CommentModel *model() const;
    void setModel(CommentModel *model);

    QString linkAuthor() const;
    void setLinkAuthor(const QString &linkAuthor);

    Q_INVOKABLE void addComment(const QString &replyTofullname, const QString &rawText);
    Q_INVOKABLE void editComment(const QString &fullname, const QString &rawText);
    Q_INVOKABLE void deleteComment(const QString &fullname);

signals:
    void success(const QString &message);
    void error(const QString &errorString);

private slots:
    void onFinished(QNetworkReply *reply);

private:
    CommentModel *m_model;
    QString m_linkAuthor;

    enum Action { Insert, Edit, Delete };
    Action m_action;
    QString m_fullname;
};

#endif // COMMENTMANAGER_H

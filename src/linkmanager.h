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

#include "abstractmanager.h"

#ifndef LINKMANAGER_H
#define LINKMANAGER_H

class LinkManager : public AbstractManager
{
    Q_OBJECT
public:
    explicit LinkManager(QObject *parent = 0);
    Q_INVOKABLE void submit(const QString &subreddit, const QString &captcha, const QString &iden, const QString &title, const QString& url, const QString& text);

signals:
    void success(const QString &message);
    void error(const QString &errorString);
    void recaptcha();

public slots:

private slots:
    void onFinished(QNetworkReply *reply);

private:
    APIRequest *m_request;

    void abortActiveReply();
};

#endif // LINKMANAGER_H

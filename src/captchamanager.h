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

#ifndef CAPTCHAMANAGER_H
#define CAPTCHAMANAGER_H

#include "abstractmanager.h"

class CaptchaManager : public AbstractManager
{
    Q_OBJECT
    Q_PROPERTY(bool captchaNeeded READ captchaNeeded NOTIFY captchaNeededChanged)
    Q_PROPERTY(QUrl imageUrl READ imageUrl NOTIFY imageUrlChanged)
    Q_PROPERTY(bool ready READ ready NOTIFY readyChanged)
    Q_PROPERTY(QString iden READ iden)
public:
    explicit CaptchaManager(QObject *parent = 0);
    QUrl imageUrl();
    bool ready();
    QString iden();
    bool captchaNeeded();

    Q_INVOKABLE void request();

signals:
    void error(const QString &errorString);
    void captchaNeededChanged();
    void imageUrlChanged();
    void readyChanged();

private slots:
    void onRequestFinished(QNetworkReply *reply);
    void onCaptchaNeededFinished(QNetworkReply *reply);

private:
    APIRequest *m_request;
    bool m_ready;
    QString m_iden;

    /* When Unknown or False, captchaNeeded returns false
     * when Error or True, captchaNeeded returns true
     */
    enum CaptchaNeededState { Unknown, True, False, Error };
    CaptchaNeededState m_captchaNeededState;

    void requestCaptchaNeeded();
    void abortActiveReply();
};

#endif // CAPTCHAMANAGER_H

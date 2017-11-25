/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
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

#include "qmlutils.h"

#include <QtCore/QUrl>
#include <QtGui/QClipboard>
#include <QNetworkRequest>
#include <QScreen>
#include <QDebug>

#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
  #include <QStandardPaths>
#else
  #include <QDesktopServices>
#endif

#ifdef Q_OS_HARMATTAN
#include <MDataUri>
#include <MNotification>
#include <MRemoteAction>
#include <maemo-meegotouch-interfaces/shareuiinterface.h>
#else
#include <nemonotifications-qt5/notification.h>
#endif

const QString QMLUtils::SOURCE_REPO_URL = "https://github.com/accumulator/Quickddit";
const QString QMLUtils::GPL3_LICENSE_URL = "http://www.gnu.org/licenses/gpl-3.0.html";

QMLUtils::QMLUtils(QObject *parent) :
    QObject(parent)
{
    setPScale();

#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
    m_clipIgnore = true;
    m_clipboard = QGuiApplication::clipboard();
#else
    m_clipboard = QApplication::clipboard();
#endif
    connect(m_clipboard, SIGNAL(dataChanged()), this, SLOT(onClipboardChanged()));
}

void QMLUtils::copyToClipboard(const QString &text)
{
    m_myclip = text;
    m_clipboard->setText(text);
    qDebug("Text copied to clipboard: %s", qPrintable(text));
}

QString QMLUtils::clipboardText() const
{
    return m_clipboard->text();
}

void QMLUtils::onClipboardChanged()
{
    qDebug() << "clipboard changed event";
    // ignore event?
    if (m_clipIgnore) {
        m_clipIgnore = false;
        return;
    }

    if (clipboardText() == m_myclip)
        return;
    if (clipboardText().isEmpty())
        return;

    emit clipboardChanged();
}

void QMLUtils::shareUrl(const QString &url, const QString &title)
{
#ifdef Q_OS_HARMATTAN
    MDataUri uri;
    uri.setMimeType("text/x-url");
    uri.setTextData(url);

    if (!title.isEmpty())
        uri.setAttribute("title", title);

    if (!uri.isValid()) {
        qCritical("QMLUtils::shareUrl(): Invalid URL");
        return;
    }

    ShareUiInterface shareIf("com.nokia.ShareUi");

    if (!shareIf.isValid()) {
        qCritical("QMLUtils::shareUrl(): Invalid Share UI interface");
        return;
    }

    shareIf.share(QStringList() << uri.toString());
#elif defined(Q_WS_SIMULATOR)
    qDebug("QMLUtils:shareUrl() called with url=\"%s\" and title=\"%s\"",
           qPrintable(url), qPrintable(title));
#else
    qWarning("QMLUtils::shareUrl(): This function only available on Harmattan");
    Q_UNUSED(url)
    Q_UNUSED(title)
#endif
}

QString QMLUtils::getRedditShortUrl(const QString &fullname)
{
    return "http://redd.it/" + fullname.mid(3);
}

QString QMLUtils::toAbsoluteUrl(const QString &url)
{
    if (!QUrl(url).isRelative())
        return url;

    if (url.startsWith('/'))
        return "https://www.reddit.com" + url;
    else
        return "";
}

void QMLUtils::saveImage(const QString &url)
{
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
    QString picturesLocation = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
#else
    QString picturesLocation = QDesktopServices::storageLocation(QDesktopServices::PicturesLocation);
#endif
    QString name = url.split("/").last().split("@").first();
    QString targetFileName = picturesLocation + "/" + name;
    if (QFile::exists(targetFileName)) {
        emit saveImageFailed(name);
        return;
    } else {
        m_imageFile = new QFile;
        m_imageFile->setFileName(targetFileName);

        QNetworkRequest request;
        request.setUrl(QUrl(url));
        m_reply = m_manager.get(request);
        connect(m_reply, SIGNAL(finished()), this, SLOT(onSaveImageFinished()));
    }

}

void QMLUtils::onSaveImageFinished()
{
    if (!m_reply->error()) {
        m_imageFile->open(QIODevice::WriteOnly);
        m_imageFile->write(m_reply->readAll());
        m_imageFile->close();
        QString filename = m_imageFile->fileName().split("/").last().split("@").first();
        emit saveImageSucceeded(filename);
        delete m_imageFile;
        m_imageFile = 0;
    }
    m_reply->deleteLater();
    m_reply = 0;
}

void QMLUtils::publishNotification(const QString &summary, const QString &body,
                                         const int count)
{
#ifdef Q_OS_HARMATTAN
    MNotification notification("quickddit.inbox", summary, body);
    notification.setCount(count);
    notification.setIdentifier("0");
    MRemoteAction action("org.quickddit", "/", "org.quickddit.view", "showInbox");
    notification.setAction(action);
    notification.publish();
#else
    Notification notification;
    notification.setCategory("harbour-quickddit.inbox");

    notification.setSummary(summary);
    notification.setBody(body);
    notification.setItemCount(count);
    notification.setReplacesId(0);

    notification.setRemoteAction(
                Notification::remoteAction(
                    "default", "show Inbox", "org.quickddit", "/", "org.quickddit.view", "showInbox"));

    notification.publish();
#endif
}

void QMLUtils::clearNotification()
{
#ifdef Q_OS_HARMATTAN
    QList<MNotification*> activeNotifications = MNotification::notifications();
    QMutableListIterator<MNotification*> i(activeNotifications);
    while (i.hasNext()) {
        MNotification *notification = i.next();
        notification->remove();
    }
#else
    QList<QObject*> activeNotifications = Notification::notifications();
    QMutableListIterator<QObject*> i(activeNotifications);
    while (i.hasNext()) {
        Notification *notification = (Notification*)i.next();
        notification->close();
    }
#endif
}

void QMLUtils::setPScale()
{
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
    // determine PPI relative to Jolla 1
    QGuiApplication* app = static_cast<QGuiApplication*>(parent());
    float ppi = app->primaryScreen()->physicalDotsPerInch();
    float rjolla = ppi / 242;

    // available physical size weighs too, relative Jolla 1, but capped to 150%
    float rpw = ((app->primaryScreen()->availableSize().width() / ppi) / (540.0/242.0));
    if (rpw > 1.5)
        rpw = 1.5;

    // quantize in 1/4 steps
    float q = 0.25; // 25% quantizer (100%, 125%, 150%, ...)
    int intermediate = (int)(rjolla * rpw/ q);
    cpScale = ((float)(intermediate)) * q;
    if (cpScale < 1.0)
        cpScale = 1.0;
    qDebug() << "Device PPI =" << ppi << "scale = " << cpScale << "rpw = " << rpw;
#else
    cpScale = 1.0;
#endif
}

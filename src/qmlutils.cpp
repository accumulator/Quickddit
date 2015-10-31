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
#include <QDebug>

#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
  #include <QtGui/QGuiApplication>
  #include <QStandardPaths>
#else
  #include <QtGui/QApplication>
  #include <QDesktopServices>
#endif

#ifdef Q_OS_HARMATTAN
#include <MDataUri>
#include <maemo-meegotouch-interfaces/shareuiinterface.h>
#endif

const QString QMLUtils::SOURCE_REPO_URL = "https://github.com/accumulator/Quickddit";
const QString QMLUtils::GPL3_LICENSE_URL = "http://www.gnu.org/licenses/gpl-3.0.html";

QMLUtils::QMLUtils(QObject *parent) :
    QObject(parent)
{
}

void QMLUtils::copyToClipboard(const QString &text)
{
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
    QClipboard *clipboard = QGuiApplication::clipboard();
#else
    QClipboard *clipboard = QApplication::clipboard();
#endif
    clipboard->setText(text);
#ifdef Q_WS_SIMULATOR
    qDebug("Text copied to clipboard: %s", qPrintable(text));
#endif
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
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
        connect(m_reply, SIGNAL(finished(QNetworkReply*)), this, SLOT(onSaveImageFinished));
#else
        connect(m_reply, SIGNAL(finished()), this, SLOT(onSaveImageFinished()));
#endif
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

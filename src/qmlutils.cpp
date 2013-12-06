#include "qmlutils.h"

#include <QtGui/QApplication>
#include <QtGui/QClipboard>

#ifdef Q_OS_HARMATTAN
#include <MDataUri>
#include <maemo-meegotouch-interfaces/shareuiinterface.h>
#endif

QMLUtils::QMLUtils(QObject *parent) :
    QObject(parent)
{
}

void QMLUtils::copyToClipboard(const QString &text)
{
    QClipboard *clipboard = QApplication::clipboard();
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

QString QMLUtils::getRedditFullUrl(const QString &relativeUrl)
{
    return "http://www.reddit.com" + relativeUrl;
}

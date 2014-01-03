#include "qmlutils.h"

#include <QtCore/QUrl>
#include <QtGui/QClipboard>

#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
  #include <QtGui/QGuiApplication>
#else
  #include <QtGui/QApplication>
#endif

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
        return "http://www.reddit.com" + url;
    else
        return "";
}

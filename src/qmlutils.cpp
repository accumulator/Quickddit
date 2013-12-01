#include "qmlutils.h"

#include <QtGui/QApplication>
#include <QtGui/QClipboard>

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

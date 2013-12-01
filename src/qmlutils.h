#ifndef QMLUTILS_H
#define QMLUTILS_H

#include <QtCore/QObject>

class QMLUtils : public QObject
{
    Q_OBJECT
public:
    explicit QMLUtils(QObject *parent = 0);

    // Copy text to system clipboard
    Q_INVOKABLE void copyToClipboard(const QString &text);
};

#endif // QMLUTILS_H

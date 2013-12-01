#ifndef ABSTRACTMANAGER_H
#define ABSTRACTMANAGER_H

#include <QtCore/QObject>

#include "quickdditmanager.h"

class AbstractManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool busy READ isBusy NOTIFY busyChanged)
    Q_PROPERTY(QuickdditManager* manager READ manager WRITE setManager)
public:
    explicit AbstractManager(QObject *parent = 0);

    bool isBusy() const;

    QuickdditManager *manager();
    void setManager(QuickdditManager *manager);

protected:
    void setBusy(bool busy);

signals:
    void busyChanged();

private:
    bool m_busy;
    QuickdditManager *m_manager;
};

#endif // ABSTRACTMANAGER_H

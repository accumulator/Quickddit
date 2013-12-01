#include "abstractmanager.h"

AbstractManager::AbstractManager(QObject *parent) :
    QObject(parent), m_busy(false), m_manager(0)
{
}

bool AbstractManager::isBusy() const
{
    return m_busy;
}

QuickdditManager *AbstractManager::manager()
{
    return m_manager;
}

void AbstractManager::setManager(QuickdditManager *manager)
{
    m_manager = manager;
}

void AbstractManager::setBusy(bool busy)
{
    if (m_busy != busy) {
        m_busy = busy;
        emit busyChanged();
    }
}

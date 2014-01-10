#include "abstractlistmodelmanager.h"

AbstractListModelManager::AbstractListModelManager(QObject *parent) :
    QAbstractListModel(parent), m_busy(false), m_manager(0)
{
}

#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
QHash<int, QByteArray> AbstractListModelManager::roleNames() const
{
    return customRoleNames();
}
#endif

bool AbstractListModelManager::isBusy() const
{
    return m_busy;
}

QuickdditManager *AbstractListModelManager::manager() const
{
    return m_manager;
}

void AbstractListModelManager::setManager(QuickdditManager *manager)
{
    m_manager = manager;
}

void AbstractListModelManager::setBusy(bool busy)
{
    if (m_busy != busy) {
        m_busy = busy;
        emit busyChanged();
    }
}

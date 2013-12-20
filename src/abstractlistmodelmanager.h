#ifndef ABSTRACTLISTMODELMANAGER_H
#define ABSTRACTLISTMODELMANAGER_H

#include <QtCore/QAbstractListModel>
#include <QtDeclarative/QDeclarativeParserStatus>

#include "quickdditmanager.h"

class AbstractListModelManager : public QAbstractListModel, public QDeclarativeParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QDeclarativeParserStatus)
    Q_PROPERTY(bool busy READ isBusy NOTIFY busyChanged)
    Q_PROPERTY(QuickdditManager* manager READ manager WRITE setManager)
public:
    explicit AbstractListModelManager(QObject *parent = 0);

    bool isBusy() const;

    QuickdditManager *manager();
    void setManager(QuickdditManager *manager);

    Q_INVOKABLE virtual void refresh(bool refreshOlder) = 0;

protected:
    void setBusy(bool busy);
    virtual QHash<int, QByteArray> customRoleNames() const = 0;

signals:
    void busyChanged();
    void error(const QString &errorString);

private:
    bool m_busy;
    QuickdditManager *m_manager;
};

#endif // ABSTRACTLISTMODELMANAGER_H

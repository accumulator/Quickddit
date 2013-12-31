#ifndef ABSTRACTLISTMODELMANAGER_H
#define ABSTRACTLISTMODELMANAGER_H

#include <QtCore/QAbstractListModel>
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
  #include <QtQml/QQmlParserStatus>
  #define DECL_QMLPARSERSTATUS_INTERFACE Q_INTERFACES(QQmlParserStatus)
#else
  #include <QtDeclarative/QDeclarativeParserStatus>
  #define QQmlParserStatus QDeclarativeParserStatus
  #define DECL_QMLPARSERSTATUS_INTERFACE Q_INTERFACES(QDeclarativeParserStatus)
#endif

#include "quickdditmanager.h"

class AbstractListModelManager : public QAbstractListModel, public QQmlParserStatus
{
    Q_OBJECT
    DECL_QMLPARSERSTATUS_INTERFACE
    Q_PROPERTY(bool busy READ isBusy NOTIFY busyChanged)
    Q_PROPERTY(QuickdditManager* manager READ manager WRITE setManager)
public:
    explicit AbstractListModelManager(QObject *parent = 0);

#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
    QHash<int, QByteArray> roleNames() const;
#endif

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

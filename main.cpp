#include <QtGui/QApplication>
#include <QtDeclarative/qdeclarative.h>
#include <QtDeclarative/QDeclarativeContext>
#include "qmlapplicationviewer.h"

#include "src/appsettings.h"
#include "src/quickdditmanager.h"
#include "src/linkmodel.h"
#include "src/linkmanager.h"
#include "src/searchmanager.h"
#include "src/commentmodel.h"
#include "src/commentmanager.h"
#include "src/subredditmodel.h"
#include "src/subredditmanager.h"
#include "src/aboutsubredditmanager.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));

    app->setApplicationName("Quickddit");
    app->setOrganizationName("Quickddit");
    app->setApplicationVersion(APP_VERSION);

    qmlRegisterType<AppSettings>("Quickddit", 1, 0, "AppSettings");
    qmlRegisterType<QuickdditManager>("Quickddit", 1, 0, "QuickdditManager");
    qmlRegisterType<LinkModel>();
    qmlRegisterType<LinkManager>("Quickddit", 1, 0, "LinkManager");
    qmlRegisterType<SearchManager>("Quickddit", 1, 0, "SearchManager");
    qmlRegisterType<CommentModel>();
    qmlRegisterType<CommentManager>("Quickddit", 1, 0, "CommentManager");
    qmlRegisterType<SubredditModel>();
    qmlRegisterType<SubredditManager>("Quickddit", 1, 0, "SubredditManager");
    qmlRegisterType<AboutSubredditManager>("Quickddit", 1, 0, "AboutSubredditManager");

    QmlApplicationViewer viewer;
    viewer.rootContext()->setContextProperty("APP_VERSION", APP_VERSION);
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
    viewer.setMainQmlFile(QLatin1String("qml/quickddit/main.qml"));
    viewer.showExpanded();

    return app->exec();
}

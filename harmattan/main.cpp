#include <QtGui/QApplication>
#include <QtDeclarative/qdeclarative.h>
#include <QtDeclarative/QDeclarativeContext>
#include "qmlapplicationviewer.h"

#include "src/appsettings.h"
#include "src/qmlutils.h"
#include "src/quickdditmanager.h"
#include "src/linkmodel.h"
#include "src/commentmodel.h"
#include "src/subredditmodel.h"
#include "src/aboutsubredditmanager.h"
#include "src/imgurmanager.h"
#include "src/votemanager.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));

    app->setApplicationName("Quickddit");
    app->setOrganizationName("Quickddit");
    app->setApplicationVersion(APP_VERSION);

    qmlRegisterType<AppSettings>("Quickddit", 1, 0, "AppSettings");
    qmlRegisterType<QuickdditManager>("Quickddit", 1, 0, "QuickdditManager");
    qmlRegisterType<LinkModel>("Quickddit", 1, 0, "LinkModel");
    qmlRegisterType<CommentModel>("Quickddit", 1, 0, "CommentModel");
    qmlRegisterType<SubredditModel>("Quickddit", 1, 0, "SubredditModel");
    qmlRegisterType<AboutSubredditManager>("Quickddit", 1, 0, "AboutSubredditManager");
    qmlRegisterType<ImgurManager>("Quickddit", 1, 0, "ImgurManager");
    qmlRegisterType<VoteManager>("Quickddit", 1, 0, "VoteManager");

    QmlApplicationViewer viewer;
    viewer.rootContext()->setContextProperty("APP_VERSION", APP_VERSION);

    QMLUtils qmlUtils;
    viewer.rootContext()->setContextProperty("QMLUtils", &qmlUtils);

    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
    viewer.setMainQmlFile(QLatin1String("qml/quickddit/main.qml"));
    viewer.showExpanded();

    return app->exec();
}

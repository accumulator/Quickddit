#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <QtGui/QGuiApplication>
#include <QtQml/qqml.h> // for qmlRegisterType
#include <QtQml/QQmlContext>
#include <QtQuick/QQuickView>
#include <sailfishapp.h>

#include "src/appsettings.h"
#include "src/qmlutils.h"
#include "src/quickdditmanager.h"
#include "src/linkmodel.h"
#include "src/commentmodel.h"
#include "src/subredditmodel.h"
#include "src/aboutsubredditmanager.h"
#include "src/imgurmanager.h"
#include "src/votemanager.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));

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

    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->rootContext()->setContextProperty("APP_VERSION", APP_VERSION);

    QMLUtils qmlUtils;
    view->rootContext()->setContextProperty("QMLUtils", &qmlUtils);

    view->setSource(SailfishApp::pathTo("qml/main.qml"));
    view->show();

    return app->exec();
}


#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QQmlContext>
#include <QSettings>

#include "src/appsettings.h"
#include "src/qmlutils.h"
#include "src/quickdditmanager.h"
#include "src/linkmodel.h"
#include "src/commentmodel.h"
#include "src/subredditmodel.h"
#include "src/aboutsubredditmanager.h"
#include "src/multiredditmodel.h"
#include "src/aboutmultiredditmanager.h"
#include "src/messagemodel.h"
#include "src/messagemanager.h"
#include "src/imgurmanager.h"
#include "src/gallerymanager.h"
#include "src/votemanager.h"
#include "src/commentmanager.h"
#include "src/linkmanager.h"
#include "src/inboxmanager.h"
#include "src/usermanager.h"
#include "src/userthingmodel.h"
#include "src/savemanager.h"
#include "src/subredditmanager.h"
#include "src/flairmanager.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    qmlRegisterType<AppSettings>("quickddit.Core", 1, 0, "AppSettings");
    qmlRegisterType<QuickdditManager>("quickddit.Core", 1, 0, "QuickdditManager");
    qmlRegisterType<LinkModel>("quickddit.Core", 1, 0, "LinkModel");
    qmlRegisterType<CommentModel>("quickddit.Core", 1, 0, "CommentModel");
    qmlRegisterType<SubredditModel>("quickddit.Core", 1, 0, "SubredditModel");
    qmlRegisterType<AboutSubredditManager>("quickddit.Core", 1, 0, "AboutSubredditManager");
    qmlRegisterType<MultiredditModel>("quickddit.Core", 1, 0, "MultiredditModel");
    qmlRegisterType<AboutMultiredditManager>("quickddit.Core", 1, 0, "AboutMultiredditManager");
    qmlRegisterType<MessageModel>("quickddit.Core", 1, 0, "MessageModel");
    qmlRegisterType<MessageManager>("quickddit.Core", 1, 0, "MessageManager");
    qmlRegisterType<ImgurManager>("quickddit.Core", 1, 0, "ImgurManager");
    qmlRegisterType<GalleryManager>("quickddit.Core", 1, 0, "GalleryManager");
    qmlRegisterType<VoteManager>("quickddit.Core", 1, 0, "VoteManager");
    qmlRegisterType<CommentManager>("quickddit.Core", 1, 0, "CommentManager");
    qmlRegisterType<LinkManager>("quickddit.Core", 1, 0, "LinkManager");
    qmlRegisterType<InboxManager>("quickddit.Core", 1, 0, "InboxManager");
    qmlRegisterType<UserManager>("quickddit.Core", 1, 0, "UserManager");
    qmlRegisterType<UserThingModel>("quickddit.Core", 1, 0, "UserThingModel");
    qmlRegisterType<SaveManager>("quickddit.Core", 1, 0, "SaveManager");
    qmlRegisterType<SubredditManager>("quickddit.Core", 1, 0, "SubredditManager");
    qmlRegisterType<FlairManager>("quickddit.Core", 1, 0, "FlairManager");

    QQmlApplicationEngine engine;

    app.setOrganizationName("quickddit");
    app.setOrganizationDomain("dkland");
    QSettings settings;
    QString style = QQuickStyle::name();
    if (settings.contains("style")) {
        QQuickStyle::setStyle(settings.value("style").toString());
    }

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    QMLUtils qmlUtils;
    qDebug().nospace() <<QString(qVersion());
    engine.rootContext()->setContextProperty("QMLUtils", &qmlUtils);
    engine.rootContext()->setContextProperty("APP_VERSION", APP_VERSION);
    engine.load(url);
    return app.exec();
}

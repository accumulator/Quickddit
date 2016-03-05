/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2015  Sander van Grieken

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see [http://www.gnu.org/licenses/].
*/

#include <QtGui/QApplication>
#include <QtDeclarative/qdeclarative.h>
#include <QtDeclarative/QDeclarativeContext>

#include "qmlapplicationviewer.h"
#include "dbusapp.h"

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
#include "src/votemanager.h"
#include "src/commentmanager.h"
#include "src/captchamanager.h"
#include "src/linkmanager.h"
#include "src/inboxmanager.h"
#include "src/usermanager.h"
#include "src/userthingmodel.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));

    app->setApplicationName("Quickddit");
    app->setOrganizationName("Quickddit");
    app->setApplicationVersion(APP_VERSION);

    qmlRegisterType<AppSettings>("Quickddit.Core", 1, 0, "AppSettings");
    qmlRegisterType<QuickdditManager>("Quickddit.Core", 1, 0, "QuickdditManager");
    qmlRegisterType<LinkModel>("Quickddit.Core", 1, 0, "LinkModel");
    qmlRegisterType<CommentModel>("Quickddit.Core", 1, 0, "CommentModel");
    qmlRegisterType<SubredditModel>("Quickddit.Core", 1, 0, "SubredditModel");
    qmlRegisterType<AboutSubredditManager>("Quickddit.Core", 1, 0, "AboutSubredditManager");
    qmlRegisterType<MultiredditModel>("Quickddit.Core", 1, 0, "MultiredditModel");
    qmlRegisterType<AboutMultiredditManager>("Quickddit.Core", 1, 0, "AboutMultiredditManager");
    qmlRegisterType<MessageModel>("Quickddit.Core", 1, 0, "MessageModel");
    qmlRegisterType<MessageManager>("Quickddit.Core", 1, 0, "MessageManager");
    qmlRegisterType<ImgurManager>("Quickddit.Core", 1, 0, "ImgurManager");
    qmlRegisterType<VoteManager>("Quickddit.Core", 1, 0, "VoteManager");
    qmlRegisterType<CommentManager>("Quickddit.Core", 1, 0, "CommentManager");
    qmlRegisterType<CaptchaManager>("Quickddit.Core", 1, 0, "CaptchaManager");
    qmlRegisterType<LinkManager>("Quickddit.Core", 1, 0, "LinkManager");
    qmlRegisterType<InboxManager>("Quickddit.Core", 1, 0, "InboxManager");
    qmlRegisterType<UserManager>("Quickddit.Core", 1, 0, "UserManager");
    qmlRegisterType<UserThingModel>("Quickddit.Core", 1, 0, "UserThingModel");

    QmlApplicationViewer viewer;
    viewer.rootContext()->setContextProperty("APP_VERSION", APP_VERSION);

    QMLUtils qmlUtils;
    viewer.rootContext()->setContextProperty("QMLUtils", &qmlUtils);

    DbusApp dbusApp(&viewer);
    viewer.rootContext()->setContextProperty("DbusApp", &dbusApp);

    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
    viewer.setMainQmlFile(QLatin1String("qml/quickddit/main.qml"));
    viewer.showExpanded();

    return app->exec();
}

/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong

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

#include "src/appsettings.h"
#include "src/qmlutils.h"
#include "src/quickdditmanager.h"
#include "src/linkmodel.h"
#include "src/commentmodel.h"
#include "src/subredditmodel.h"
#include "src/aboutsubredditmanager.h"
#include "src/imgurmanager.h"
#include "src/votemanager.h"
#include "src/commentmanager.h"

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
    qmlRegisterType<ImgurManager>("Quickddit.Core", 1, 0, "ImgurManager");
    qmlRegisterType<VoteManager>("Quickddit.Core", 1, 0, "VoteManager");
    qmlRegisterType<CommentManager>("Quickddit.Core", 1, 0, "CommentManager");

    QmlApplicationViewer viewer;
    viewer.rootContext()->setContextProperty("APP_VERSION", APP_VERSION);

    QMLUtils qmlUtils;
    viewer.rootContext()->setContextProperty("QMLUtils", &qmlUtils);

    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
    viewer.setMainQmlFile(QLatin1String("qml/quickddit/main.qml"));
    viewer.showExpanded();

    return app->exec();
}

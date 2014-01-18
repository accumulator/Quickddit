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
#include "src/multiredditmodel.h"
#include "src/messagemodel.h"
#include "src/imgurmanager.h"
#include "src/votemanager.h"
#include "src/commentmanager.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));

    app->setApplicationName("Quickddit");
    app->setOrganizationName("Quickddit");
    app->setApplicationVersion(APP_VERSION);

    qmlRegisterType<AppSettings>("harbour.quickddit.Core", 1, 0, "AppSettings");
    qmlRegisterType<QuickdditManager>("harbour.quickddit.Core", 1, 0, "QuickdditManager");
    qmlRegisterType<LinkModel>("harbour.quickddit.Core", 1, 0, "LinkModel");
    qmlRegisterType<CommentModel>("harbour.quickddit.Core", 1, 0, "CommentModel");
    qmlRegisterType<SubredditModel>("harbour.quickddit.Core", 1, 0, "SubredditModel");
    qmlRegisterType<AboutSubredditManager>("harbour.quickddit.Core", 1, 0, "AboutSubredditManager");
    qmlRegisterType<MultiredditModel>("harbour.quickddit.Core", 1, 0, "MultiredditModel");
    qmlRegisterType<MessageModel>("harbour.quickddit.Core", 1, 0, "MessageModel");
    qmlRegisterType<ImgurManager>("harbour.quickddit.Core", 1, 0, "ImgurManager");
    qmlRegisterType<VoteManager>("harbour.quickddit.Core", 1, 0, "VoteManager");
    qmlRegisterType<CommentManager>("harbour.quickddit.Core", 1, 0, "CommentManager");

    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->rootContext()->setContextProperty("APP_VERSION", APP_VERSION);

    QMLUtils qmlUtils;
    view->rootContext()->setContextProperty("QMLUtils", &qmlUtils);

    view->setSource(SailfishApp::pathTo("qml/main.qml"));
    view->show();

    return app->exec();
}


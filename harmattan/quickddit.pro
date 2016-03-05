TEMPLATE = app
TARGET = quickddit

QT *= network

VERSION = 0.8.0
DEFINES += APP_VERSION=\\\"$$VERSION\\\"

INCLUDEPATH += ..

HEADERS += \
    app_adaptor.h \
    app_interface.h \
    dbusapp.h \
    ../src/linkobject.h \
    ../src/linkmodel.h \
    ../src/utils.h \
    ../src/quickdditmanager.h \
    ../src/abstractmanager.h \
    ../src/abstractlistmodelmanager.h \
    ../src/parser.h \
    ../src/aboutsubredditmanager.h \
    ../src/appsettings.h \
    ../src/commentobject.h \
    ../src/commentmodel.h \
    ../src/subredditobject.h \
    ../src/subredditmodel.h \
    ../src/qmlutils.h \
    ../src/imgurmanager.h \
    ../src/votemanager.h \
    ../src/commentmanager.h \
    ../src/multiredditobject.h \
    ../src/multiredditmodel.h \
    ../src/messageobject.h \
    ../src/messagemodel.h \
    ../src/messagemanager.h \
    ../src/apirequest.h \
    ../src/aboutmultiredditmanager.h \
    ../src/captchamanager.h \
    ../src/linkmanager.h \
    ../src/inboxmanager.h \
    ../src/usermanager.h \
    ../src/userobject.h \
    ../src/userthingmodel.h \
    ../src/thing.h

SOURCES += main.cpp \
    app_adaptor.cpp \
    app_interface.cpp \
    dbusapp.cpp \
    ../src/linkobject.cpp \
    ../src/linkmodel.cpp \
    ../src/utils.cpp \
    ../src/quickdditmanager.cpp \
    ../src/abstractmanager.cpp \
    ../src/abstractlistmodelmanager.cpp \
    ../src/parser.cpp \
    ../src/aboutsubredditmanager.cpp \
    ../src/appsettings.cpp \
    ../src/commentobject.cpp \
    ../src/commentmodel.cpp \
    ../src/subredditobject.cpp \
    ../src/subredditmodel.cpp \
    ../src/qmlutils.cpp \
    ../src/imgurmanager.cpp \
    ../src/votemanager.cpp \
    ../src/commentmanager.cpp \
    ../src/multiredditobject.cpp \
    ../src/multiredditmodel.cpp \
    ../src/messageobject.cpp \
    ../src/messagemodel.cpp \
    ../src/messagemanager.cpp \
    ../src/apirequest.cpp \
    ../src/aboutmultiredditmanager.cpp \
    ../src/captchamanager.cpp \
    ../src/linkmanager.cpp \
    ../src/inboxmanager.cpp \
    ../src/usermanager.cpp \
    ../src/userobject.cpp \
    ../src/userthingmodel.cpp \
    ../src/thing.cpp

# Qt-Json
HEADERS += ../qt-json/json.h
SOURCES += ../qt-json/json.cpp

# QML files
qml.source = qml/quickddit
qml.target = qml
DEPLOYMENTFOLDERS = qml

contains(MEEGO_EDITION, harmattan) {
    CONFIG += shareuiinterface-maemo-meegotouch mdatauri qdeclarative-boostable
    DEFINES += Q_OS_HARMATTAN

    # Splash
    splash.files = splash/quickddit-splash-portrait.jpg splash/quickddit-splash-landscape.jpg
    splash.path = /opt/$${TARGET}/splash
    INSTALLS += splash
}

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

OTHER_FILES += \
    qtc_packaging/debian_harmattan/* \
    quickddit_harmattan.desktop \
    notifications/quickddit.inbox.conf

notif-icons.files = notifications/icon-m-quickddit.png
notif-icons.path = /usr/share/themes/blanco/meegotouch/icons
notif-config.files = notifications/quickddit.inbox.conf
notif-config.path = /usr/share/meegotouch/notifications/eventtypes

INSTALLS += notif-icons notif-config

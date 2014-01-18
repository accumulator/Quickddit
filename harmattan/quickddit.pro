TEMPLATE = app
TARGET = quickddit

QT *= network

VERSION = 0.2.0
DEFINES += APP_VERSION=\\\"$$VERSION\\\"

INCLUDEPATH += ..

HEADERS += \
    ../src/linkobject.h \
    ../src/linkmodel.h \
    ../src/utils.h \
    ../src/quickdditmanager.h \
    ../src/networkmanager.h \
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
    ../src/messagemodel.h

SOURCES += main.cpp \
    ../src/linkobject.cpp \
    ../src/linkmodel.cpp \
    ../src/utils.cpp \
    ../src/quickdditmanager.cpp \
    ../src/networkmanager.cpp \
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
    ../src/messagemodel.cpp

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
    quickddit_harmattan.desktop

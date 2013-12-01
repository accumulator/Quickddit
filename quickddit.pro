TEMPLATE = app
TARGET = quickddit

QT *= network

VERSION = 0.0.1
DEFINES += APP_VERSION=\\\"$$VERSION\\\"

qml.source = qml/quickddit
qml.target = qml
DEPLOYMENTFOLDERS = qml

# Speed up launching on MeeGo/Harmattan when using applauncherd daemon
CONFIG += qdeclarative-boostable

HEADERS += \
    src/linkobject.h \
    src/linkmodel.h \
    src/utils.h \
    src/quickdditmanager.h \
    src/networkmanager.h \
    src/abstractmanager.h \
    src/parser.h \
    src/linkmanager.h \
    src/aboutsubredditmanager.h \
    src/appsettings.h \
    src/commentobject.h \
    src/commentmodel.h \
    src/commentmanager.h \
    src/searchmanager.h \
    src/subredditobject.h \
    src/subredditmodel.h \
    src/subredditmanager.h

SOURCES += main.cpp \
    src/linkobject.cpp \
    src/linkmodel.cpp \
    src/utils.cpp \
    src/quickdditmanager.cpp \
    src/networkmanager.cpp \
    src/abstractmanager.cpp \
    src/parser.cpp \
    src/linkmanager.cpp \
    src/aboutsubredditmanager.cpp \
    src/appsettings.cpp \
    src/commentobject.cpp \
    src/commentmodel.cpp \
    src/commentmanager.cpp \
    src/searchmanager.cpp \
    src/subredditobject.cpp \
    src/subredditmodel.cpp \
    src/subredditmanager.cpp

# Qt-Json
HEADERS += qt-json/json.h
SOURCES += qt-json/json.cpp

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

OTHER_FILES += \
    qtc_packaging/debian_harmattan/* \
    quickddit_harmattan.desktop \
    README \
    LICENSE

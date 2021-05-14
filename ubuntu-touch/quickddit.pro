QT += quick quickcontrols2 network core
TARGET = quickddit
CONFIG += c++17
TEMPLATE =app

AppID= quickddit
# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

equals(FLAVOR, "uuitk") {
    CONFIG += flavor_uuitk
} else {
    CONFIG += flavor_qtcontrols
}

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0
DEFINES += Q_OS_UBUNTU APP_VERSION=\\\"1.2\\\"
INCLUDEPATH += ../

SOURCES += \
        main.cpp \
        ../src/aboutmultiredditmanager.cpp \
        ../src/aboutsubredditmanager.cpp \
        ../src/abstractlistmodelmanager.cpp \
        ../src/abstractmanager.cpp \
        ../src/apirequest.cpp \
        ../src/appsettings.cpp \
        ../src/commentmanager.cpp \
        ../src/commentmodel.cpp \
        ../src/commentobject.cpp \
        ../src/flairmanager.cpp \
        ../src/imgurmanager.cpp \
        ../src/gallerymanager.cpp \
        ../src/inboxmanager.cpp \
        ../src/linkmanager.cpp \
        ../src/linkmodel.cpp \
        ../src/linkobject.cpp \
        ../src/messagemanager.cpp \
        ../src/messagemodel.cpp \
        ../src/messageobject.cpp \
        ../src/multiredditmodel.cpp \
        ../src/multiredditobject.cpp \
        ../src/parser.cpp \
        ../src/qmlutils.cpp \
        ../src/quickdditmanager.cpp \
        ../src/savemanager.cpp \
        ../src/subredditmanager.cpp \
        ../src/subredditmodel.cpp \
        ../src/subredditobject.cpp \
        ../src/thing.cpp \
        ../src/usermanager.cpp \
        ../src/userobject.cpp \
        ../src/userthingmodel.cpp \
        ../src/utils.cpp \
        ../src/votemanager.cpp


HEADERS += \
    ../src/aboutmultiredditmanager.h \
    ../src/aboutsubredditmanager.h \
    ../src/abstractlistmodelmanager.h \
    ../src/abstractmanager.h \
    ../src/apirequest.h \
    ../src/appsettings.h \
    ../src/commentmanager.h \
    ../src/commentmodel.h \
    ../src/commentobject.h \
    ../src/flairmanager.h \
    ../src/imgurmanager.h \
    ../src/gallerymanager.h \
    ../src/inboxmanager.h \
    ../src/linkmanager.h \
    ../src/linkmodel.h \
    ../src/linkobject.h \
    ../src/messagemanager.h \
    ../src/messagemodel.h \
    ../src/messageobject.h \
    ../src/multiredditmodel.h \
    ../src/multiredditobject.h \
    ../src/parser.h \
    ../src/qmlutils.h \
    ../src/quickdditmanager.h \
    ../src/savemanager.h \
    ../src/subredditmanager.h \
    ../src/subredditmodel.h \
    ../src/subredditobject.h \
    ../src/thing.h \
    ../src/usermanager.h \
    ../src/userobject.h \
    ../src/userthingmodel.h \
    ../src/utils.h \
    ../src/votemanager.h
    
# Qt-Json
HEADERS += ../qt-json/json.h
SOURCES += ../qt-json/json.cpp

RESOURCES += qml.qrc

CLICK_FILES += \
    Icons/quickddit.svg \
    Icons/quickddit-splash-image.svg \
    clickable.json \
    manifest.json \
    quickddit.desktop \
    quickddit.apparmor

isEmpty(PREFIX) {
    flavor_uuitk {
        PREFIX = /
    } else {
        PREFIX = /usr/local
    }
}

flavor_uuitk {
    click_files.path = $${PREFIX}
    click_files.files += $${CLICK_FILES}
    INSTALLS += click_files

    youtube-dl.files = ../youtube-dl/youtube_dl
    youtube-dl.path = $$PREFIX
    INSTALLS += youtube-dl
}

flavor_qtcontrols {
    desktop_file.path = $${PREFIX}/share/applications
    desktop_file.files += quickddit.desktop
    icon_file.path = $${PREFIX}/share/icons/hicolor/scalable/apps/
    icon_file.files += Icons/quickddit.svg

    INSTALLS += desktop_file icon_file
}

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
target.path = $${PREFIX}/bin
INSTALLS += target


DISTFILES += $${CLICK_FILES}

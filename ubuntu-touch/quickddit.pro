QT += quick quickcontrols2 network
TARGET = quickddit
CONFIG += c++11
TEMPLATE =app

AppID= quickddit
# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0
DEFINES += Q_OS_UBUNTU APP_VERSION=\\\"1.3\\\"
INCLUDEPATH += ../


include(../src/src.pri)

SOURCES += \
        main.cpp

# Qt-Json
include(../qt-json/qt-json.pri)

RESOURCES += qml.qrc
CONF_FILES += \
    Icons/quickddit.svg \
    Icons/quickddit-splash-image.svg \
    clickable.json \
    manifest.json \
    quickddit.desktop \
    quickddit.apparmor


config_files.path = /
config_files.files += $${CONF_FILES}
INSTALLS += config_files

youtube-dl.files = ../youtube-dl/youtube_dl
youtube-dl.path = /

INSTALLS += youtube-dl

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =


# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    Icons/quickddit.svg \
    Icons/quickddit-splash-image.svg \
    clickable.json \
    manifest.json \
    quickddit.desktop \
    quickddit.apparmor

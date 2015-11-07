# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
#         - filename of rpm/$$TARGET.spec and rpm/$$TARGET.yaml
#         - the app name in rpm/$$TARGET.yaml file
TEMPLATE = app
TARGET = harbour-quickddit

DEFINES += APP_VERSION=\\\"$$VERSION\\\" Q_OS_SAILFISH

QT *= network dbus

# auto-installs 86x86 icon, desktop file, qml/* is automatically installed by sailfishapp.prf
# (but IDE don't show these when not in OTHER_FILES, so we still need to list them :( )
CONFIG += sailfishapp

INCLUDEPATH += ..

HEADERS += \
    dbusapp.h \
    ../src/linkmanager.h \
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
    ../src/inboxmanager.h

SOURCES += main.cpp \
    dbusapp.cpp \
    ../src/linkmanager.cpp \
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
    ../src/multiredditmodel.cpp \
    ../src/multiredditobject.cpp \
    ../src/messageobject.cpp \
    ../src/messagemodel.cpp \
    ../src/messagemanager.cpp \
    ../src/apirequest.cpp \
    ../src/aboutmultiredditmanager.cpp \
    ../src/captchamanager.cpp \
    ../src/inboxmanager.cpp

# Qt-Json
HEADERS += ../qt-json/json.h
SOURCES += ../qt-json/json.cpp

OTHER_FILES += \
    rpm/$${TARGET}.spec \
    rpm/$${TARGET}.yaml \
    rpm/$${TARGET}.changes \
    $${TARGET}.desktop \
    $${TARGET}.png \
    qml/cover/CoverPage.qml \
    qml/SubredditsBrowsePage.qml \
    qml/SubredditsPage.qml \
    qml/SubredditDelegate.qml \
    qml/SignInPage.qml \
    qml/SelectionDialog.qml \
    qml/SearchPage.qml \
    qml/SearchDialog.qml \
    qml/OpenLinkDialog.qml \
    qml/MainPage.qml \
    qml/main.qml \
    qml/LinkMenu.qml \
    qml/LinkDelegate.qml \
    qml/InfoBanner.qml \
    qml/ImageViewPage.qml \
    qml/Constant.qml \
    qml/CommentPage.qml \
    qml/CommentMenu.qml \
    qml/CommentDelegate.qml \
    qml/AppSettingsPage.qml \
    qml/AboutSubredditPage.qml \
    qml/AboutPage.qml \
    qml/AbstractPage.qml \
    qml/TextAreaDialog.qml \
    qml/MultiredditsPage.qml \
    qml/MessagePage.qml \
    qml/MessageDelegate.qml \
    qml/MessageMenu.qml \
    qml/LoadingFooter.qml \
    qml/SimpleListItem.qml \
    qml/AboutMultiredditPage.qml \
    qml/Bubble.qml \
    qml/VideoViewPage.qml \
    qml/AbstractDialog.qml \
    qml/Captcha.qml \
    qml/NewLinkPage.qml \
    qml/PostThumbnail.qml \
    qml/PostInfoText.qml \
    qml/PostButtonRow.qml \
    iface/org.quickddit.xml

icon128.files = icon128/$${TARGET}.png
icon128.path = /usr/share/icons/hicolor/128x128/apps

INSTALLS += icon128

DBUS_ADAPTORS += iface/org.quickddit.xml
DBUS_INTERFACES += iface/org.quickddit.xml

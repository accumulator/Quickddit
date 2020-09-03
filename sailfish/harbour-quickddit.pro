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

# sailfishapp.prf auto-installs icons, desktop file, qml/*
# (but IDE don't show these when not in OTHER_FILES, so we still need to list them :( )
CONFIG += sailfishapp link_pkgconfig

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# Harbour is quite strict about what it allows. Quickddit has features that would not allow it to pass
# through QA. Add CONFIG+=harbour to the .pro file (uncomment below) or add it to the qmake command
# to force harbour compatibility.
#CONFIG += harbour

PKGCONFIG += sailfishapp nemonotifications-qt5 keepalive

INCLUDEPATH += ..

HEADERS += \
    dbusapp.h \
    app_adaptor.h \
    app_interface.h \
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
    ../src/gallerymanager.h \
    ../src/votemanager.h \
    ../src/commentmanager.h \
    ../src/multiredditobject.h \
    ../src/multiredditmodel.h \
    ../src/messageobject.h \
    ../src/messagemodel.h \
    ../src/messagemanager.h \
    ../src/apirequest.h \
    ../src/aboutmultiredditmanager.h \
    ../src/inboxmanager.h \
    ../src/usermanager.h \
    ../src/userobject.h \
    ../src/userthingmodel.h \
    ../src/thing.h \
    ../src/savemanager.h \
    ../src/subredditmanager.h \
    ../src/flairmanager.h

SOURCES += main.cpp \
    dbusapp.cpp \
    app_adaptor.cpp \
    app_interface.cpp \
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
    ../src/gallerymanager.cpp \
    ../src/votemanager.cpp \
    ../src/commentmanager.cpp \
    ../src/multiredditmodel.cpp \
    ../src/multiredditobject.cpp \
    ../src/messageobject.cpp \
    ../src/messagemodel.cpp \
    ../src/messagemanager.cpp \
    ../src/apirequest.cpp \
    ../src/aboutmultiredditmanager.cpp \
    ../src/inboxmanager.cpp \
    ../src/usermanager.cpp \
    ../src/userobject.cpp \
    ../src/userthingmodel.cpp \
    ../src/thing.cpp \
    ../src/savemanager.cpp \
    ../src/subredditmanager.cpp \
    ../src/flairmanager.cpp

# Qt-Json
HEADERS += ../qt-json/json.h
SOURCES += ../qt-json/json.cpp

OTHER_FILES += \
    rpm/$${TARGET}.spec \
    rpm/$${TARGET}.yaml \
    rpm/$${TARGET}.changes \
    $${TARGET}.desktop \
    $${TARGET}.png \
    iface/org.quickddit.xml \
    qml/ytdl_wrapper.py \
    qml/cover/CoverPage.qml \
    qml/SubredditsBrowsePage.qml \
    qml/SubredditBrowseDelegate.qml \
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
    qml/SendLinkPage.qml \
    qml/PostThumbnail.qml \
    qml/PostInfoText.qml \
    qml/PostButtonRow.qml \
    qml/QuickdditPageHeader.qml \
    qml/FancyContextMenu.qml \
    qml/FancyMenuItemRow.qml \
    qml/FancyMenuItem.qml \
    qml/FancyMenuImage.qml \
    qml/UserPage.qml \
    qml/WideText.qml \
    qml/UserPageCommentDelegate.qml \
    qml/UserPageLinkDelegate.qml \
    qml/SendMessagePage.qml \
    qml/ImageViewer.qml \
    qml/AltMarker.qml \
    qml/WebViewer.qml \
    qml/SectionSelectionDialog.qml \
    qml/ModeratorListPage.qml \
    qml/AccountsPage.qml \
    qml/DonatePage.qml

# Translations
CONFIG += sailfishapp_i18n

include(translations/translations.pri)

# hm, I prefer generating code directly to the build dir, and not including the
# generated sources in the HEADERS and SOURCES lists.. Manually remove app_adaptor.h
# to force rebuilding the dbus iface spec.
!exists( app_adaptor.h ) {
    message("generating DBus adaptor and proxy..")
    system(qdbusxml2cpp iface/org.quickddit.xml -a app_adaptor -p app_interface)
}

harbour {
    message("build: HARBOUR Compliant")
    message("* Notification specification is excluded")
    DEFINES += HARBOUR_COMPLIANCE
    DEFINES += BUILD_VARIANT=\\\"Harbour\\\"
} else {
    message("build: Unrestricted")
    DEFINES += BUILD_VARIANT=\\\"Standard\\\"

    notification.files = notifications/harbour-quickddit.inbox.conf
    notification.path = /usr/share/lipstick/notificationcategories

    INSTALLS += notification
}

# kludge needed as qmake cannot control INSTALL permissions
system(chmod 0644 ../youtube-dl/youtube_dl/__main__.py ../youtube-dl/youtube_dl/YoutubeDL.py)

youtube-dl.files = ../youtube-dl/youtube_dl
youtube-dl.path = /usr/share/$${TARGET}

INSTALLS += youtube-dl

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

include(../src/src.pri)

HEADERS += \
    dbusapp.h \
    app_adaptor.h \
    app_interface.h \

SOURCES += main.cpp \
    dbusapp.cpp \
    app_adaptor.cpp \
    app_interface.cpp \

# Qt-Json
include(../qt-json/qt-json.pri)

OTHER_FILES += \
    rpm/$${TARGET}.spec \
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
    qml/SettingsPage.qml \
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
system(chmod 0644 ../yt-dlp/yt_dlp/__main__.py ../yt-dlp/yt_dlp/YoutubeDL.py)

youtube-dl.files = ../yt-dlp/yt_dlp
youtube-dl.path = /usr/share/$${TARGET}

INSTALLS += youtube-dl

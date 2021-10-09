defined(REDDIT_CLIENT_ID, var) {
       DEFINES += REDDIT_CLIENT_ID=\\\"$${REDDIT_CLIENT_ID}\\\"
}
defined(REDDIT_CLIENT_SECRET, var) {
       DEFINES += REDDIT_CLIENT_SECRET=\\\"$${REDDIT_CLIENT_SECRET}\\\"
}
defined(REDDIT_REDIRECT_URL, var) {
       DEFINES += REDDIT_REDIRECT_URL=\\\"$${REDDIT_REDIRECT_URL}\\\"
}

SOURCES += \
        $$PWD/aboutmultiredditmanager.cpp \
        $$PWD/aboutsubredditmanager.cpp \
        $$PWD/abstractlistmodelmanager.cpp \
        $$PWD/abstractmanager.cpp \
        $$PWD/apirequest.cpp \
        $$PWD/appsettings.cpp \
        $$PWD/commentmanager.cpp \
        $$PWD/commentmodel.cpp \
        $$PWD/commentobject.cpp \
        $$PWD/flairmanager.cpp \
        $$PWD/imgurmanager.cpp \
        $$PWD/gallerymanager.cpp \
        $$PWD/inboxmanager.cpp \
        $$PWD/linkmanager.cpp \
        $$PWD/linkmodel.cpp \
        $$PWD/linkobject.cpp \
        $$PWD/messagemanager.cpp \
        $$PWD/messagemodel.cpp \
        $$PWD/messageobject.cpp \
        $$PWD/multiredditmodel.cpp \
        $$PWD/multiredditobject.cpp \
        $$PWD/parser.cpp \
        $$PWD/qmlutils.cpp \
        $$PWD/quickdditmanager.cpp \
        $$PWD/savemanager.cpp \
        $$PWD/subredditmanager.cpp \
        $$PWD/subredditmodel.cpp \
        $$PWD/subredditobject.cpp \
        $$PWD/thing.cpp \
        $$PWD/usermanager.cpp \
        $$PWD/userobject.cpp \
        $$PWD/userthingmodel.cpp \
        $$PWD/utils.cpp \
        $$PWD/votemanager.cpp



HEADERS += \
    $$PWD/aboutmultiredditmanager.h \
    $$PWD/aboutsubredditmanager.h \
    $$PWD/abstractlistmodelmanager.h \
    $$PWD/abstractmanager.h \
    $$PWD/apirequest.h \
    $$PWD/appsettings.h \
    $$PWD/commentmanager.h \
    $$PWD/commentmodel.h \
    $$PWD/commentobject.h \
    $$PWD/flairmanager.h \
    $$PWD/imgurmanager.h \
    $$PWD/gallerymanager.h \
    $$PWD/inboxmanager.h \
    $$PWD/linkmanager.h \
    $$PWD/linkmodel.h \
    $$PWD/linkobject.h \
    $$PWD/messagemanager.h \
    $$PWD/messagemodel.h \
    $$PWD/messageobject.h \
    $$PWD/multiredditmodel.h \
    $$PWD/multiredditobject.h \
    $$PWD/parser.h \
    $$PWD/qmlutils.h \
    $$PWD/quickdditmanager.h \
    $$PWD/savemanager.h \
    $$PWD/subredditmanager.h \
    $$PWD/subredditmodel.h \
    $$PWD/subredditobject.h \
    $$PWD/thing.h \
    $$PWD/usermanager.h \
    $$PWD/userobject.h \
    $$PWD/userthingmodel.h \
    $$PWD/utils.h \
    $$PWD/votemanager.h
    
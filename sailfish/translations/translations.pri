TRANSLATION_SOURCES += ../src

TRANSLATIONS = translations/harbour-quickddit-en_GB.ts \
    translations/harbour-quickddit-nl.ts \
    translations/harbour-quickddit-nl_BE.ts \
    translations/harbour-quickddit-sv.ts \
    translations/harbour-quickddit-el.ts \
    translations/harbour-quickddit-de.ts \
    translations/harbour-quickddit-fr.ts \
    translations/harbour-quickddit-it.ts \
    translations/harbour-quickddit-pl.ts \
    translations/harbour-quickddit-pt_BR.ts


updateqm.input = TRANSLATIONS
updateqm.output = translations/${QMAKE_FILE_BASE}.qm
updateqm.commands = \
        lrelease ${QMAKE_FILE_IN} \
        -qm translations/${QMAKE_FILE_BASE}.qm
updateqm.CONFIG += no_link
QMAKE_EXTRA_COMPILERS += updateqm

PRE_TARGETDEPS += compiler_updateqm_make_all

localization.files = $$files($$top_builddir/translations/*.qm)
localization.path = /usr/share/$${TARGET}/translations

INSTALLS += localization

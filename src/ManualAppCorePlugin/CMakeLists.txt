qt_add_qml_module(ManualAppCorePlugin
    URI ManualAppCorePlugin
    VERSION 1.0
    DEPENDENCIES
        QtQuick
        QtQml
        QtCore
    SOURCES
        datamanager.cpp datamanager.h
        settingsmanager.cpp settingsmanager.h
        stepmodel.cpp stepmodel.h
        fileservice.cpp fileservice.h
        networkservice.cpp networkservice.h
        pdfexporter.cpp pdfexporter.h
        reportmanager.cpp reportmanager.h
        configmanager.cpp configmanager.h
        step.h
        utils.h
)

target_link_libraries(ManualAppCorePlugin PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Network
    Qt6::PrintSupport
    quazip
)

install(TARGETS ManualAppCorePlugin
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/qt6/qml/ManualAppCorePlugin
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
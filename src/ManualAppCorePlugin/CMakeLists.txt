qt_add_qml_module(ManualAppCorePlugin
    URI ManualAppCorePlugin
    VERSION 1.0
    DEPENDENCIES
    QtQuick
    QtQml
    QtCore
    SOURCES
    datamanager.cpp datamanager.h
    installmanager.h installmanager.cpp
    adminmanager.h adminmanager.cpp

    # files 
    file/fileservice.cpp file/fileservice.h
    file/loger.h
    file/configmanager.cpp file/configmanager.h

    # settings
    settings/settingsmanager.cpp settings/settingsmanager.h
    settings/modelsettings.cpp settings/modelsettings.h

    # license
    software/licensehandler.h software/licensehandler.cpp
    

    # networks
    networkservice.cpp networkservice.h
    network/httpclient.h network/httpclient.cpp
    network/djangoerrorparser.h
)

target_link_libraries(ManualAppCorePlugin PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Network
    Qt6::Concurrent
    Qt6::PrintSupport
    quazip
)

install(TARGETS ManualAppCorePlugin
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/qt6/qml/ManualAppCorePlugin
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

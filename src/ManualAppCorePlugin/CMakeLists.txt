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
)

target_link_libraries(ManualAppCorePlugin PRIVATE Qt6::Gui)

install(TARGETS ManualAppCorePlugin
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/qt6/qml/ManualAppCorePlugin
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
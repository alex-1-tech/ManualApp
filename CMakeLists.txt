cmake_minimum_required(VERSION 3.16)

project(ManualApp VERSION 1.0 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(WIN32)
    set(ZLIB_ROOT "C:/libs/zlib")
    set(ZLIB_INCLUDE_DIR "C:/libs/zlib/include")
    set(ZLIB_LIBRARY "C:/libs/zlib/lib/zlib.lib")
endif()

find_package(ZLIB REQUIRED)
if(NOT TARGET ZLIB::ZLIB)
    add_library(ZLIB::ZLIB UNKNOWN IMPORTED)
    set_target_properties(ZLIB::ZLIB PROPERTIES
        IMPORTED_LOCATION "C:/libs/zlib/lib/zlib.lib"
        INTERFACE_INCLUDE_DIRECTORIES "C:/libs/zlib/include"
    )
endif()

find_package(Qt6 REQUIRED COMPONENTS
    Core
    Gui
    Qml
    Quick
    QuickControls2
    QuickDialogs2
    QuickTemplates2
    QuickLayouts
    PrintSupport
    Network
)

qt_standard_project_setup(REQUIRES 6.8)

add_subdirectory(src/quazip)
add_subdirectory(src/ManualAppCorePlugin)

qt_add_executable(${PROJECT_NAME}
    src/main.cpp
    resources.qrc
)

if(WIN32)
    function(deploy_qt_app target)
        get_target_property(QMAKE_EXE Qt6::qmake IMPORTED_LOCATION)
        get_filename_component(QT_BIN_DIR "${QMAKE_EXE}" DIRECTORY)

        set(QT_DLLS
            Qt6Core Qt6Gui Qt6Widgets
            Qt6Qml Qt6Quick Qt6Network
            Qt6PrintSupport
        )

        foreach(DLL ${QT_DLLS})
            add_custom_command(TARGET ${target} POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "${QT_BIN_DIR}/${DLL}.dll"
                "$<TARGET_FILE_DIR:${target}>"
                COMMENT "Copying ${DLL}.dll"
            )
        endforeach()

        add_custom_command(TARGET ${target} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E make_directory
            "$<TARGET_FILE_DIR:${target}>/platforms"
        )
        add_custom_command(TARGET ${target} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${QT_BIN_DIR}/../plugins/platforms/qwindows.dll"
            "$<TARGET_FILE_DIR:${target}>/platforms/"
        )

        add_custom_command(TARGET ${target} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "$<TARGET_FILE:quazip>"
            "$<TARGET_FILE_DIR:${target}>"
        )

        if(EXISTS "C:/libs/zlib/bin/zlib.dll")
            add_custom_command(TARGET ${target} POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "C:/libs/zlib/bin/zlib.dll"
                "$<TARGET_FILE_DIR:${target}>"
            )
        endif()

        if(TARGET ManualAppCorePlugin)
            add_custom_command(TARGET ${target} POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "$<TARGET_FILE:ManualAppCorePlugin>"
                "$<TARGET_FILE_DIR:${target}>"
            )
        endif()
    endfunction()

    deploy_qt_app(ManualApp)
endif()

target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_QML_RESOURCE_USE_URI_PATHS
)

target_link_libraries(ManualApp PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::QuickTemplates2
    Qt6::QuickDialogs2
    Qt6::QuickLayouts
    Qt6::PrintSupport
    Qt6::Network
    quazip
    ManualAppCorePlugin
)

include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

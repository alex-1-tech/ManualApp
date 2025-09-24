cmake_minimum_required(VERSION 3.16)

project(ManualApp VERSION 1.0 LANGUAGES CXX)

if(POLICY QTP0001)
    cmake_policy(SET QTP0001 NEW)
endif()

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QuaZip-Qt6 REQUIRED)

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

file(GLOB DATA_SOURCES "src/data/*.cpp" "src/data/*.h")
file(GLOB MAIN_SOURCES "src/main.cpp")

set(SRC_FILES
    ${MAIN_SOURCES}
    ${DATA_SOURCES}
)

set(RESOURCES
    "resources.qrc"
)

# set(QT_QML_GENERATE_QMLLS_INI ON CACHE BOOL "" FORCE)

qt_add_executable(${PROJECT_NAME}
    ${SRC_FILES}
    ${RESOURCES}
)



target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_QML_RESOURCE_USE_URI_PATHS
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    WIN32_EXECUTABLE TRUE
)

add_subdirectory(src/ManualAppCorePlugin)

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
    QuaZip::QuaZip
    ManualAppCorePlugin
)


include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

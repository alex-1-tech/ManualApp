cmake_minimum_required(VERSION 3.16)

project(ManualApp VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)


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
)

SET(SRC_FILES
    "src/main.cpp"
    "src/data/settingsmanager.cpp"
    "src/data/settingsmanager.h"
    "src/data/datamanager.cpp"
    "src/data/datamanager.h"
    "src/data/jsonstorage.cpp"
    "src/data/jsonstorage.h"
    "src/data/pdfexporter.cpp"
    "src/data/pdfexporter.h"
    "src/data/stepmodel.cpp"
    "src/data/stepmodel.h"
    "src/data/step.h"
    "src/data/utils.h"
)

SET(RESOURCES
    "resources.qrc"
)

qt_add_executable(${PROJECT_NAME}
    ${SRC_FILES}
    ${RESOURCES}
)



target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_QML_RESOURCE_USE_URI_PATHS
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
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
)
# qt6_import_qml_plugins(${PROJECT_NAME})
include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

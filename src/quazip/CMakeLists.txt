project(quazip)

find_package(ZLIB REQUIRED)

set(QUAZIP_SOURCES
    quazip.cpp
    quazipfile.cpp
    quazipnewinfo.cpp
    JlCompress.cpp
    qioapi.cpp
    quaadler32.cpp
    quacrc32.cpp
    quagzipfile.cpp
    quaziodevice.cpp
    quazipdir.cpp
    quazipfileinfo.cpp
    quazip_textcodec.cpp
    unzip.c
    zip.c
)

set(QUAZIP_HEADERS
    quazip.h
    quazipfile.h
    quazipnewinfo.h
    quazip_global.h
    quazip_qt_compat.h
    quazipfileinfo.h
    JlCompress.h
    ioapi.h
    unzip.h
    zip.h
    minizip_crypt.h
    quaadler32.h
    quacrc32.h
    quachecksum32.h
    quagzipfile.h
    quaziodevice.h
    quazipdir.h
    quazip_textcodec.h
)

add_library(quazip STATIC ${QUAZIP_SOURCES} ${QUAZIP_HEADERS})

target_include_directories(quazip PUBLIC .)
target_link_libraries(quazip PRIVATE Qt6::Core ZLIB::ZLIB)

target_compile_definitions(quazip PRIVATE
    QUAZIP_BUILD
    _LARGEFILE64_SOURCE
    _FILE_OFFSET_BITS=64
)

if(WIN32)
    target_compile_definitions(quazip PRIVATE
        _CRT_SECURE_NO_WARNINGS
        _CRT_NONSTDC_NO_DEPRECATE
    )
endif()
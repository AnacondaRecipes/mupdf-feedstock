cmake_minimum_required(VERSION 3.15)
project(libmupdf C CXX)

include(GNUInstallDirs)

set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS True)

find_package(PkgConfig REQUIRED)
find_package(freetype NO_MODULE REQUIRED)
find_package(JPEG REQUIRED)
find_package(ZLIB REQUIRED)

find_library(GUMBO NAMES gumbo REQUIRED)
find_library(JBIG2DEC_LIB NAMES jbig2decd jbig2dec)

# ---- pkg-config dependencies (IMPORTED TARGETS) ----
pkg_check_modules(MUJS REQUIRED IMPORTED_TARGET mujs)
pkg_check_modules(OPENJPEG REQUIRED IMPORTED_TARGET libopenjp2)
pkg_check_modules(HARFBUZZ REQUIRED IMPORTED_TARGET harfbuzz)
pkg_check_modules(BROTLI REQUIRED IMPORTED_TARGET
    libbrotlienc
    libbrotlidec
    libbrotlicommon
)

file(GLOB_RECURSE SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/source/**/*.c*
    ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/extract/src/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/generated/*.c
)
# Exclude optional tools and huge resources
list(FILTER SOURCES EXCLUDE REGEX "source/tools/[a-z]*\\.c$")
list(FILTER SOURCES EXCLUDE REGEX "/source/tests/")
list(FILTER SOURCES EXCLUDE REGEX "/thirdparty/extract/src/[^/]*test[^/]*\\.c$")
list(REMOVE_ITEM SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/extract/src/memento.c
    ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/extract/src/extract-exe.c
)

add_library(libmupdf STATIC ${SOURCES})

if(CMAKE_C_COMPILER_ID MATCHES "Clang")
    target_compile_options(libmupdf PRIVATE -msse4.1 -mssse3)
endif()

target_compile_definitions(libmupdf PRIVATE
    SHARE_JPEG
    FZ_DLL
    FZ_DLL_CLIENT
    FZ_ENABLE_WIN32
    FZ_ENABLE_ICC=0
    FZ_ENABLE_BARCODE=0
)

target_include_directories(libmupdf
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/generated
        ${CMAKE_CURRENT_SOURCE_DIR}/include/mupdf
        ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/extract/include
        ${JPEG_INCLUDE_DIR}
)

target_link_libraries(libmupdf PRIVATE
    freetype
    ZLIB::ZLIB
    ${GUMBO}
    ${JPEG_LIBRARIES}
    ${JBIG2DEC_LIB}

    # pkg-config imported targets
    PkgConfig::MUJS
    PkgConfig::OPENJPEG
    PkgConfig::HARFBUZZ
    PkgConfig::BROTLI
)

# ---- mutool ----

file(GLOB TOOL_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/source/tools/*.c)
list(REMOVE_ITEM TOOL_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/source/tools/mutool.c)

add_executable(mutool
    ${CMAKE_CURRENT_SOURCE_DIR}/source/tools/mutool.c
    ${TOOL_SOURCES}
)

target_compile_definitions(mutool PRIVATE)
target_link_libraries(mutool PRIVATE libmupdf)
target_include_directories(mutool PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)

install(
    DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/mupdf
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.h"
)
install(TARGETS libmupdf
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
install(TARGETS mutool RUNTIME DESTINATION bin)
install(
    FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/platform/win32/x64/Release/mupdfcpp64.dll
    DESTINATION
        ${CMAKE_INSTALL_BINDIR}
    RENAME
        libmupdfcpp.dll
)

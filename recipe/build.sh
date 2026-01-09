#!/usr/bin/env bash
set -ex

# build system uses non-standard env vars
if [[ "$target_platform" == osx* ]]; then
  export CFLAGS="${CFLAGS} -I ${PREFIX}/include/freetype2"
  export CFLAGS="${CFLAGS} -I $(ls -d ${PREFIX}/include/openjpeg-*)"
  export CFLAGS="${CFLAGS} -Wno-incompatible-function-pointer-types"
fi

export CFLAGS="${CFLAGS} -I ${PREFIX}/include/harfbuzz"
export XCFLAGS="${CFLAGS}"
export XLIBS="${LIBS}"
export USE_GUMBO=yes
export USE_SYSTEM_GUMBO=yes
export SYS_GUMBO_CFLAGS="-I${PREFIX}/include"
export SYS_GUMBO_LIBS="-L${PREFIX}/lib -lgumbo"
export USE_SYSTEM_LIBS=yes
export USE_SYSTEM_MUJS=yes
export USE_SYSTEM_JPEGXR=yes
export VENV_FLAG=""

# build and install
# Clang chokes on large font lexing so reduce the number of jobs
if [[ "$target_platform" == osx* ]]; then
  make prefix="${PREFIX}" pydir="${SP_DIR}" shared=yes -j1
else
  make prefix="${PREFIX}" pydir="${SP_DIR}" shared=yes -j${CPU_COUNT}
fi
make prefix="${PREFIX}" pydir="${SP_DIR}" shared=yes install install-shared-python

if [[ "$target_platform" == osx* ]]; then
    install_name_tool -id @rpath/libmupdfcpp.dylib $PREFIX/lib/libmupdfcpp.dylib
fi
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

# Point the mupdf Python binding build to the HOST Python (not BUILD_PREFIX Python).
# Without this, pipcl.PythonFlags uses sys.executable (BUILD_PREFIX) to find
# python-config, causing an ABI mismatch with the target Python.
export PIPCL_PYTHON_CONFIG="${PREFIX}/bin/python3-config"

# USE_ARGUMENT_FILE=no: conda's ar doesn't support @file response files
# Build 'all' and 'python' separately to avoid a race: 'python' depends on
# 'shared-release' which triggers a recursive make that races with the parent
# make's link step for mutool (undefined murun_main).
# Clang chokes on large font lexing so reduce the number of jobs on osx.
if [[ "$target_platform" == osx* ]]; then
  JOBS=1
else
  JOBS=${CPU_COUNT}
fi

make prefix="${PREFIX}" pydir="${SP_DIR}" shared=yes USE_ARGUMENT_FILE=no -j${JOBS} all
make prefix="${PREFIX}" pydir="${SP_DIR}" shared=yes USE_ARGUMENT_FILE=no -j${JOBS} python
make prefix="${PREFIX}" pydir="${SP_DIR}" shared=yes USE_ARGUMENT_FILE=no install install-shared-python

if [[ "$target_platform" == osx* ]]; then
    install_name_tool -id @rpath/libmupdfcpp.dylib $PREFIX/lib/libmupdfcpp.dylib
fi

#!/bin/bash


# Usage:
# bash build.sh [clean] [package]
if [ -z $BASH ]; then
    # We weren't invoked using bash; probably sh was used. Re-invoke using bash.
    bash $0 "$@"
    exit $?
fi

while [ ! -z $1 ]; do
    if [ "$1" == "package" ]; then
        DO_PACKAGE=1
    elif [ "$1" == "install" ]; then
        DO_PACKAGE=1
        DO_INSTALL=1
    elif [ "$1" == "clean" ]; then
        DO_CLEAN=1
    elif [ "$1" == "asan" ]; then
        # This needs to be exported so maskrcnn-benchmark/setup.py can see it.
        export USE_ASAN=1
    else
        break
    fi
    shift
done

REPO_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MAKE_CACHE_ROOT="$REPO_ROOT/.cmakecache"

# Clean the CMake cache to ensure a clean build. For now, cmake cache generation is
# very fast so regenerating each time is fine.
rm -rf $MAKE_CACHE_ROOT
RESULT=$?
if [ $RESULT -ne 0 ]; then
    echo Failure encountered while running rm -rf $MAKE_CACHE_ROOT! >&2
    exit $RESULT
fi

# Recompiling native code is expensive so only do it when explicitly cleaning.
if [ ! -z $DO_CLEAN ]; then
    find "$REPO_ROOT" -name "build" -type d -exec rm -r "{}" \;
    find "$REPO_ROOT" -name "dist" -type d -exec rm -r "{}" \;
    find "$REPO_ROOT" -name "*.egg-infot" -type d -exec rm -r "{}" \;
fi


#
# Build
#
mkdir -p $MAKE_CACHE_ROOT
pushd $MAKE_CACHE_ROOT

# Determine python bin dir.
PYTHON_BIN_PATH=`which python`
PYTHON_BIN_PATH=`dirname $PYTHON_BIN_PATH`

# Use CMake to build.
# cmake -DPYTHON_BIN_PATH=$PYTHON_BIN_PATH -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_FILE ..
cmake -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON ..
RESULT=$?
if [ $RESULT -ne 0 ]; then
    echo Failure encountered while running cmake! >&2
    exit $RESULT
fi

cmake --build .
RESULT=$?
if [ $RESULT -ne 0 ]; then
    echo Failure encountered while running make! >&2
    exit $RESULT
fi

if [ ! -z $DO_PACKAGE ]; then
    # Build deb package.
    cmake --build . --target packages
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
        echo Failure encountered while running make packages! >&2
        exit $RESULT
    fi
fi

popd

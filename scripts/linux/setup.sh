#!/bin/sh

cd "`dirname \"$0\"`/../.."

mkdir -p dist.native
cp scripts/linux/sbinit.config dist.native/

mkdir -p build.native
cd build.native

if [ -d /usr/lib/ccache ]; then
  export PATH=/usr/lib/ccache/:$PATH
fi

LINUX_LIB_DIR=../lib/linux

cmake \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
  -DCMAKE_BUILD_TYPE=Release \
  -DSTAR_USE_JEMALLOC=ON \
  -DCMAKE_INCLUDE_PATH=$LINUX_LIB_DIR/include \
  -DCMAKE_LIBRARY_PATH=$LINUX_LIB_DIR/ \
  ../source

if [ $# -ne 0 ]; then 
  make -j$*
fi

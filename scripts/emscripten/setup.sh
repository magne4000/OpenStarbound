#!/bin/sh

cd "$(dirname $0)/../.."

mkdir -p dist
mkdir -p build
cd build

emcmake cmake \
  -DSTAR_COMPILER=clang \
  -DCMAKE_BUILD_TYPE=Release \
  ../source

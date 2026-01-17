#!/bin/sh

cd "$(dirname $0)/../../build"

# Bypass a cache issue and ensure those are properly build beforehand
embuilder --lto build sdl2
embuilder --lto build freetype zlib libpng ogg vorbis sdl2_mixer

emmake make -j`nproc`

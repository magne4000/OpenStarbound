#!/bin/sh

cd "`dirname \"$0\"`/../.."
cd build.native

make -j`nproc`

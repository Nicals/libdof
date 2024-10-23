#!/bin/bash

set -e

SOCKPP_SHA=e6c4688a576d95f42dd7628cefe68092f6c5cd0f

if [[ $(uname) == "Linux" ]]; then
   NUM_PROCS=$(nproc)
elif [[ $(uname) == "Darwin" ]]; then
   NUM_PROCS=$(sysctl -n hw.ncpu)
else
   NUM_PROCS=1
fi

echo "Building libraries..."
echo "  SOCKPP_SHA: ${SOCKPP_SHA}"
echo ""

if [ -z "${BUILD_TYPE}" ]; then
   BUILD_TYPE="Release"
fi

echo "Build type: ${BUILD_TYPE}"
echo "Procs: ${NUM_PROCS}"
echo ""

rm -rf external
mkdir external
cd external

#
# build sockpp and copy to external
#

curl -sL https://github.com/fpagliughi/sockpp/archive/${SOCKPP_SHA}.zip -o sockpp.zip
unzip sockpp.zip
cd sockpp-$SOCKPP_SHA
patch -p1 < ../../platforms/android/arm64-v8a/sockpp/001.patch
cmake \
   -DSOCKPP_BUILD_SHARED=ON \
   -DSOCKPP_BUILD_STATIC=OFF \
   -DCMAKE_SYSTEM_NAME=Android \
   -DCMAKE_SYSTEM_VERSION=30 \
   -DCMAKE_ANDROID_ARCH_ABI=arm64-v8a \
   -DCMAKE_BUILD_WITH_INSTALL_RPATH=TRUE \
   -DCMAKE_INSTALL_RPATH="\$ORIGIN" \
   -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
   -B build
cmake --build build -- -j${NUM_PROCS}
cp -r include/sockpp ../../third-party/include/
cp build/libsockpp.so ../../third-party/runtime-libs/android/arm64-v8a/
cd ..

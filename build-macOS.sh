#!/bin/bash

### Version ###
VERSION='4.33'

### Build ###
ROOTPATH=`pwd`
SRCPATH="${ROOTPATH}/src/libev-${VERSION}"
DEVELOPERPATH=`xcode-select -print-path`
SDKVERSION=`xcrun -sdk macosx --show-sdk-version`

ARCHS='arm64 x86_64'

for ARCH in ${ARCHS}
do
  if [[ $ARCH == 'arm64' ]]; then
    HOST='arm'
  else
    HOST=$ARCH
  fi
  OUTPUT_PATH="${ROOTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"
  export CFLAGS="-arch ${ARCH} -isysroot $DEVELOPERPATH/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
  set -e
  mkdir -p $OUTPUT_PATH
  cd $SRCPATH
  echo "Building libev-${VERSION} for ${PLATFORM} ${SDKVERSION} ${ARCH}"
  (./configure --host=$HOST-apple-darwin > "${OUTPUT_PATH}/config.log")
  make clean && make
  cp .libs/libev.a $OUTPUT_PATH
  set +e
done

### lipo ###
echo 'Lipo...'
lipo -create `find ${ROOTPATH}/bin -name "*.a"` -output "${ROOTPATH}/lib/libev.a"

echo 'Done.'

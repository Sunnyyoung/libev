#!/bin/bash

### Version ###
VERSION='4.33'

### Build ###
ROOTPATH=`pwd`
SRCPATH="${ROOTPATH}/src/libev-${VERSION}"
DEVELOPERPATH=`xcode-select -print-path`
SDKVERSION=`xcrun -sdk iphoneos --show-sdk-version`

MIN_SDK_VERSION='6.0'
ARCHS='i386 x86_64 armv7 armv7s arm64'

for ARCH in ${ARCHS}
do
  if [[ ${ARCH} == 'i386' || ${ARCH} == 'x86_64' ]]; then
    PLATFORM='iPhoneSimulator'
    MIN_VERSION=""
  else
    PLATFORM='iPhoneOS'
    MIN_VERSION="-miphoneos-version-min=${MIN_SDK_VERSION}"
  fi
  if [[ $ARCH == 'arm64' ]]; then
    HOST='arm'
  else
    HOST=$ARCH
  fi
  export OTHER_CFLAGS='-fembed-bitcode'
  export AR=`xcrun -sdk iphoneos -find ar`
  export RANLIB=`xcrun -sdk iphoneos -find ranlib`
  export CC=`xcrun -sdk iphoneos -find clang`
  export CFLAGS="-arch ${ARCH} -isysroot $DEVELOPERPATH/Platforms/$PLATFORM.platform/Developer/SDKs/$PLATFORM$SDKVERSION.sdk ${MIN_VERSION} ${OTHER_CFLAGS}"
  export CPPFLAGS="-arch ${ARCH} -isysroot $DEVELOPERPATH/Platforms/$PLATFORM.platform/Developer/SDKs/$PLATFORM$SDKVERSION.sdk ${MIN_VERSION} ${OTHER_CFLAGS}"
  export LDFLAGS="-arch ${ARCH} -isysroot $DEVELOPERPATH/Platforms/$PLATFORM.platform/Developer/SDKs/$PLATFORM$SDKVERSION.sdk"
  set -e
  cd $SRCPATH
  echo "Building libev-${VERSION} for ${PLATFORM} ${SDKVERSION} ${ARCH}"
  (./configure --host=$HOST-apple-darwin)
  make clean && make
  OUTPUT_PATH="${ROOTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"
  mkdir -p $OUTPUT_PATH && cp .libs/libev.a $OUTPUT_PATH
  set +e
done

### lipo ###
echo 'Lipo...'
lipo -create `find ${ROOTPATH}/bin -name "*.a"` -output "${ROOTPATH}/lib/libev.a"

echo 'Done.'

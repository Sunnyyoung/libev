#! /bin/sh

export ROOT="$(pwd)"
export SRC="$(pwd)/libev-4.33"

export PREFIX="$(pwd)/build"
export MACOS_ARM64_PREFIX="${PREFIX}/tmp/macos-arm64"
export MACOS_X86_64_PREFIX="${PREFIX}/tmp/macos-x86_64"
export IOS32_PREFIX="${PREFIX}/tmp/ios32"
export IOS32s_PREFIX="${PREFIX}/tmp/ios32s"
export IOS64_PREFIX="${PREFIX}/tmp/ios64"
export IOS_SIMULATOR_ARM64_PREFIX="${PREFIX}/tmp/ios-simulator-arm64"
export IOS_SIMULATOR_I386_PREFIX="${PREFIX}/tmp/ios-simulator-i386"
export IOS_SIMULATOR_X86_64_PREFIX="${PREFIX}/tmp/ios-simulator-x86_64"
export WATCHOS32_PREFIX="${PREFIX}/tmp/watchos32"
export WATCHOS64_32_PREFIX="${PREFIX}/tmp/watchos64_32"
export WATCHOS_SIMULATOR_ARM64_PREFIX="${PREFIX}/tmp/watchos-simulator-arm64"
export WATCHOS_SIMULATOR_I386_PREFIX="${PREFIX}/tmp/watchos-simulator-i386"
export WATCHOS_SIMULATOR_X86_64_PREFIX="${PREFIX}/tmp/watchos-simulator-x86_64"
export TVOS64_PREFIX="${PREFIX}/tmp/tvos64"
export TVOS_SIMULATOR_ARM64_PREFIX="${PREFIX}/tmp/tvos-simulator-arm64"
export TVOS_SIMULATOR_X86_64_PREFIX="${PREFIX}/tmp/tvos-simulator-x86_64"
export CATALYST_ARM64_PREFIX="${PREFIX}/tmp/catalyst-arm64"
export CATALYST_X86_64_PREFIX="${PREFIX}/tmp/catalyst-x86_64"
export LOG_FILE="${PREFIX}/tmp/build_log"
export XCODEDIR="$(xcode-select -p)"

export MACOS_VERSION_MIN=${MACOS_VERSION_MIN-"10.10"}
export IOS_SIMULATOR_VERSION_MIN=${IOS_SIMULATOR_VERSION_MIN-"8.0"}
export IOS_VERSION_MIN=${IOS_VERSION_MIN-"8.0"}
export WATCHOS_SIMULATOR_VERSION_MIN=${WATCHOS_SIMULATOR_VERSION_MIN-"2.0"}
export WATCHOS_VERSION_MIN=${WATCHOS_VERSION_MIN-"2.0"}
export TVOS_SIMULATOR_VERSION_MIN=${TVOS_SIMULATOR_VERSION_MIN-"8.0"}
export TVOS_VERSION_MIN=${TVOS_VERSION_MIN-"8.0"}

echo "Buiding..."

APPLE_SILICON_SUPPORTED=false
echo 'int main(void){return 0;}' >comptest.c && cc --target=arm64-macos comptest.c 2>/dev/null && APPLE_SILICON_SUPPORTED=true
rm -f comptest.c
rm -f a.out

NPROCESSORS=$(getconf NPROCESSORS_ONLN 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null)
PROCESSORS=${NPROCESSORS:-3}

build_macos() {
  export BASEDIR="${XCODEDIR}/Platforms/MacOSX.platform/Developer"
  export PATH="${BASEDIR}/usr/bin:$BASEDIR/usr/sbin:$PATH"

  ## macOS arm64
  if [ "$APPLE_SILICON_SUPPORTED" = "true" ]; then
    export CFLAGS="-O2 -arch arm64 -mmacosx-version-min=${MACOS_VERSION_MIN}"
    export LDFLAGS="-arch arm64 -mmacosx-version-min=${MACOS_VERSION_MIN}"

    make distclean >/dev/null 2>&1
    ./configure --host=arm-apple-darwin20 --prefix="$MACOS_ARM64_PREFIX" || exit 1
    make -j${PROCESSORS} install || exit 1
  fi

  ## macOS x86_64
  export CFLAGS="-O2 -arch x86_64 -mmacosx-version-min=${MACOS_VERSION_MIN}"
  export LDFLAGS="-arch x86_64 -mmacosx-version-min=${MACOS_VERSION_MIN}"

  make distclean >/dev/null 2>&1
  ./configure --host=x86_64-apple-darwin10 --prefix="$MACOS_X86_64_PREFIX" || exit 1
  make -j${PROCESSORS} install || exit 1
}

build_ios() {
  export BASEDIR="${XCODEDIR}/Platforms/iPhoneOS.platform/Developer"
  export PATH="${BASEDIR}/usr/bin:$BASEDIR/usr/sbin:$PATH"
  export SDK="${BASEDIR}/SDKs/iPhoneOS.sdk"

  ## 32-bit iOS
  export CFLAGS="-fembed-bitcode -O2 -mthumb -arch armv7 -isysroot ${SDK} -mios-version-min=${IOS_VERSION_MIN}"
  export LDFLAGS="-fembed-bitcode -mthumb -arch armv7 -isysroot ${SDK} -mios-version-min=${IOS_VERSION_MIN}"

  make distclean >/dev/null 2>&1
  ./configure --host=arm-apple-darwin10 --prefix="$IOS32_PREFIX" || exit 1
  make -j${PROCESSORS} install || exit 1

  ## 32-bit armv7s iOS
  export CFLAGS="-fembed-bitcode -O2 -mthumb -arch armv7s -isysroot ${SDK} -mios-version-min=${IOS_VERSION_MIN}"
  export LDFLAGS="-fembed-bitcode -mthumb -arch armv7s -isysroot ${SDK} -mios-version-min=${IOS_VERSION_MIN}"

  make distclean >/dev/null 2>&1
  ./configure --host=arm-apple-darwin10 --prefix="$IOS32s_PREFIX" || exit 1
  make -j${PROCESSORS} install || exit 1

  ## 64-bit iOS
  export CFLAGS="-fembed-bitcode -O2 -arch arm64 -isysroot ${SDK} -mios-version-min=${IOS_VERSION_MIN}"
  export LDFLAGS="-fembed-bitcode -arch arm64 -isysroot ${SDK} -mios-version-min=${IOS_VERSION_MIN}"

  make distclean >/dev/null 2>&1
  ./configure --host=arm-apple-darwin10 --prefix="$IOS64_PREFIX" || exit 1
  make -j${PROCESSORS} install || exit 1
}

build_ios_simulator() {
  export BASEDIR="${XCODEDIR}/Platforms/iPhoneSimulator.platform/Developer"
  export PATH="${BASEDIR}/usr/bin:$BASEDIR/usr/sbin:$PATH"
  export SDK="${BASEDIR}/SDKs/iPhoneSimulator.sdk"

  ## arm64 simulator
  if [ "$APPLE_SILICON_SUPPORTED" = "true" ]; then
    export CFLAGS="-fembed-bitcode -O2 -arch arm64 -isysroot ${SDK} -mios-simulator-version-min=${IOS_SIMULATOR_VERSION_MIN}"
    export LDFLAGS="-fembed-bitcode -arch arm64 -isysroot ${SDK} -mios-simulator-version-min=${IOS_SIMULATOR_VERSION_MIN}"

    make distclean >/dev/null 2>&1
    ./configure --host=arm-apple-darwin20 --prefix="$IOS_SIMULATOR_ARM64_PREFIX" || exit 1
    make -j${PROCESSORS} install || exit 1
  fi

  ## i386 simulator
  export CFLAGS="-fembed-bitcode -O2 -arch i386 -isysroot ${SDK} -mios-simulator-version-min=${IOS_SIMULATOR_VERSION_MIN}"
  export LDFLAGS="-fembed-bitcode -arch i386 -isysroot ${SDK} -mios-simulator-version-min=${IOS_SIMULATOR_VERSION_MIN}"

  make distclean >/dev/null 2>&1
  ./configure --host=i686-apple-darwin10 --prefix="$IOS_SIMULATOR_I386_PREFIX" || exit 1
  make -j${PROCESSORS} install || exit 1

  ## x86_64 simulator
  export CFLAGS="-fembed-bitcode -O2 -arch x86_64 -isysroot ${SDK} -mios-simulator-version-min=${IOS_SIMULATOR_VERSION_MIN}"
  export LDFLAGS="-fembed-bitcode -arch x86_64 -isysroot ${SDK} -mios-simulator-version-min=${IOS_SIMULATOR_VERSION_MIN}"

  make distclean >/dev/null 2>&1
  ./configure --host=x86_64-apple-darwin10 --prefix="$IOS_SIMULATOR_X86_64_PREFIX"
  make -j${PROCESSORS} install || exit 1
}

build_watchos() {
  export BASEDIR="${XCODEDIR}/Platforms/WatchOS.platform/Developer"
  export PATH="${BASEDIR}/usr/bin:$BASEDIR/usr/sbin:$PATH"
  export SDK="${BASEDIR}/SDKs/WatchOS.sdk"

  # 32-bit watchOS
  export CFLAGS="-fembed-bitcode -O2 -mthumb -arch armv7k -isysroot ${SDK} -mwatchos-version-min=${WATCHOS_VERSION_MIN}"
  export LDFLAGS="-fembed-bitcode -mthumb -arch armv7k -isysroot ${SDK} -mwatchos-version-min=${WATCHOS_VERSION_MIN}"

  make distclean >/dev/null 2>&1
  ./configure --host=arm-apple-darwin10 --prefix="$WATCHOS32_PREFIX" || exit 1
  make -j${PROCESSORS} install || exit 1

  ## 64-bit arm64_32 watchOS
  export CFLAGS="-fembed-bitcode -O2 -mthumb -arch arm64_32 -isysroot ${SDK} -mwatchos-version-min=${WATCHOS_VERSION_MIN}"
  export LDFLAGS="-fembed-bitcode -mthumb -arch arm64_32 -isysroot ${SDK} -mwatchos-version-min=${WATCHOS_VERSION_MIN}"

  make distclean >/dev/null 2>&1
  ./configure --host=arm-apple-darwin10 --prefix="$WATCHOS64_32_PREFIX" || exit 1
  make -j${PROCESSORS} install || exit 1
}

build_watchos_simulator() {
  export BASEDIR="${XCODEDIR}/Platforms/WatchSimulator.platform/Developer"
  export PATH="${BASEDIR}/usr/bin:$BASEDIR/usr/sbin:$PATH"
  export SDK="${BASEDIR}/SDKs/WatchSimulator.sdk"

  ## arm64 simulator
  if [ "$APPLE_SILICON_SUPPORTED" = "true" ]; then
    export CFLAGS="-fembed-bitcode -O2 -arch arm64 -isysroot ${SDK} -mwatchos-simulator-version-min=${WATCHOS_SIMULATOR_VERSION_MIN}"
    export LDFLAGS="-fembed-bitcode -arch arm64 -isysroot ${SDK} -mwatchos-simulator-version-min=${WATCHOS_SIMULATOR_VERSION_MIN}"

    make distclean >/dev/null 2>&1
    ./configure --host=arm-apple-darwin20 --prefix="$WATCHOS_SIMULATOR_ARM64_PREFIX" || exit 1
    make -j${PROCESSORS} install || exit 1
  fi

  ## i386 simulator
  export CFLAGS="-fembed-bitcode -O2 -arch i386 -isysroot ${SDK} -mwatchos-simulator-version-min=${WATCHOS_SIMULATOR_VERSION_MIN}"
  export LDFLAGS="-fembed-bitcode -arch i386 -isysroot ${SDK} -mwatchos-simulator-version-min=${WATCHOS_SIMULATOR_VERSION_MIN}"

  make distclean >/dev/null 2>&1
  ./configure --host=i686-apple-darwin10 --prefix="$WATCHOS_SIMULATOR_I386_PREFIX" || exit 1
  make -j${PROCESSORS} install || exit 1

  ## x86_64 simulator
  export CFLAGS="-fembed-bitcode -O2 -arch x86_64 -isysroot ${SDK} -mwatchos-simulator-version-min=${WATCHOS_SIMULATOR_VERSION_MIN}"
  export LDFLAGS="-fembed-bitcode -arch x86_64 -isysroot ${SDK} -mwatchos-simulator-version-min=${WATCHOS_SIMULATOR_VERSION_MIN}"

  make distclean >/dev/null 2>&1
  ./configure --host=x86_64-apple-darwin10 --prefix="$WATCHOS_SIMULATOR_X86_64_PREFIX" || exit 1
  make -j${PROCESSORS} install || exit 1
}

build_tvos() {
  export BASEDIR="${XCODEDIR}/Platforms/AppleTVOS.platform/Developer"
  export PATH="${BASEDIR}/usr/bin:$BASEDIR/usr/sbin:$PATH"
  export SDK="${BASEDIR}/SDKs/AppleTVOS.sdk"

  ## 64-bit tvOS
  export CFLAGS="-fembed-bitcode -O2 -arch arm64 -isysroot ${SDK} -mtvos-version-min=${TVOS_VERSION_MIN}"
  export LDFLAGS="-fembed-bitcode -arch arm64 -isysroot ${SDK} -mtvos-version-min=${TVOS_VERSION_MIN}"

  make distclean >/dev/null 2>&1
  ./configure --host=arm-apple-darwin10 --prefix="$TVOS64_PREFIX" || exit 1
  make -j${PROCESSORS} install || exit 1
}

build_tvos_simulator() {
  export BASEDIR="${XCODEDIR}/Platforms/AppleTVSimulator.platform/Developer"
  export PATH="${BASEDIR}/usr/bin:$BASEDIR/usr/sbin:$PATH"
  export SDK="${BASEDIR}/SDKs/AppleTVSimulator.sdk"

  ## arm64 simulator
  if [ "$APPLE_SILICON_SUPPORTED" = "true" ]; then
    export CFLAGS="-fembed-bitcode -O2 -arch arm64 -isysroot ${SDK} -mtvos-simulator-version-min=${TVOS_SIMULATOR_VERSION_MIN}"
    export LDFLAGS="-fembed-bitcode -arch arm64 -isysroot ${SDK} -mtvos-simulator-version-min=${TVOS_SIMULATOR_VERSION_MIN}"

    make distclean >/dev/null 2>&1
    ./configure --host=arm-apple-darwin20 --prefix="$TVOS_SIMULATOR_ARM64_PREFIX" || exit 1
    make -j${PROCESSORS} install || exit 1
  fi

  ## x86_64 simulator
  export CFLAGS="-fembed-bitcode -O2 -arch x86_64 -isysroot ${SDK} -mtvos-simulator-version-min=${TVOS_SIMULATOR_VERSION_MIN}"
  export LDFLAGS="-fembed-bitcode -arch x86_64 -isysroot ${SDK} -mtvos-simulator-version-min=${TVOS_SIMULATOR_VERSION_MIN}"

  make distclean >/dev/null 2>&1
  ./configure --host=x86_64-apple-darwin10 --prefix="$TVOS_SIMULATOR_X86_64_PREFIX"
  make -j${PROCESSORS} install || exit 1
}

build_catalyst() {
  export BASEDIR="${XCODEDIR}/Platforms/MacOSX.platform/Developer"
  export PATH="${BASEDIR}/usr/bin:$BASEDIR/usr/sbin:$PATH"
  export SDK="${BASEDIR}/SDKs/MacOSX.sdk"

  ## arm64 catalyst
  if [ "$APPLE_SILICON_SUPPORTED" = "true" ]; then
    export CFLAGS="-O2 -arch arm64 -target arm64-apple-ios13.0-macabi -isysroot ${SDK}"
    export LDFLAGS="-arch arm64 -target arm64-apple-ios13.0-macabi -isysroot ${SDK}"

    make distclean >/dev/null 2>&1
    ./configure --host=arm-apple-ios --prefix="$CATALYST_ARM64_PREFIX" || exit 1
    make -j${PROCESSORS} install || exit 1
  fi

  ## x86_64 catalyst
  export CFLAGS="-O2 -arch x86_64 -target x86_64-apple-ios13.0-macabi -isysroot ${SDK}"
  export LDFLAGS="-arch x86_64 -target x86_64-apple-ios13.0-macabi -isysroot ${SDK}"

  make distclean >/dev/null 2>&1
  ./configure --host=x86_64-apple-ios --prefix="$CATALYST_X86_64_PREFIX" || exit 1
  make -j${PROCESSORS} install || exit 1
}

cd ${SRC}
mkdir -p "${PREFIX}/tmp"
echo "Building for macOS..."
build_macos >"$LOG_FILE" 2>&1 || exit 1
echo "Building for iOS..."
build_ios >"$LOG_FILE" 2>&1 || exit 1
echo "Building for the iOS simulator..."
build_ios_simulator >"$LOG_FILE" 2>&1 || exit 1
echo "Building for watchOS..."
build_watchos >"$LOG_FILE" 2>&1 || exit 1
echo "Building for the watchOS simulator..."
build_watchos_simulator >"$LOG_FILE" 2>&1 || exit 1
echo "Building for tvOS..."
build_tvos >"$LOG_FILE" 2>&1 || exit 1
echo "Building for the tvOS simulator..."
build_tvos_simulator >"$LOG_FILE" 2>&1 || exit 1
echo "Building for Catalyst..."
build_catalyst >"$LOG_FILE" 2>&1 || exit 1

echo "Bundling macOS targets..."

mkdir -p "${PREFIX}/macos/lib" "${PREFIX}/macos/include/libev"
cp -a "${MACOS_X86_64_PREFIX}/include/" "${PREFIX}/macos/include/libev"
if [ "$APPLE_SILICON_SUPPORTED" = "true" ]; then
  lipo -create \
    "${MACOS_ARM64_PREFIX}/lib/libev.a" \
    "${MACOS_X86_64_PREFIX}/lib/libev.a" \
    -output "${PREFIX}/macos/lib/libev.a"
else
  lipo -create \
    "${MACOS_X86_64_PREFIX}/lib/libev.a" \
    -output "${PREFIX}/macos/lib/libev.a"
fi

echo "Bundling iOS targets..."

mkdir -p "${PREFIX}/ios/lib" "${PREFIX}/ios/include/libev"
cp -a "${IOS64_PREFIX}/include/" "${PREFIX}/ios/include/libev"
lipo -create \
  "$IOS32_PREFIX/lib/libev.a" \
  "$IOS32s_PREFIX/lib/libev.a" \
  "$IOS64_PREFIX/lib/libev.a" \
  -output "$PREFIX/ios/lib/libev.a"

echo "Bundling iOS simulators..."

mkdir -p "${PREFIX}/ios-simulators/lib" "${PREFIX}/ios-simulators/include/libev"
cp -a "${IOS_SIMULATOR_X86_64_PREFIX}/include/" "${PREFIX}/ios-simulators/include/libev"
if [ "$APPLE_SILICON_SUPPORTED" = "true" ]; then
  lipo -create \
    "${IOS_SIMULATOR_ARM64_PREFIX}/lib/libev.a" \
    "${IOS_SIMULATOR_I386_PREFIX}/lib/libev.a" \
    "${IOS_SIMULATOR_X86_64_PREFIX}/lib/libev.a" \
    -output "${PREFIX}/ios-simulators/lib/libev.a" || exit 1
else
  lipo -create \
    "${IOS_SIMULATOR_I386_PREFIX}/lib/libev.a" \
    "${IOS_SIMULATOR_X86_64_PREFIX}/lib/libev.a" \
    -output "${PREFIX}/ios-simulators/lib/libev.a" || exit 1
fi

echo "Bundling watchOS targets..."

mkdir -p "${PREFIX}/watchos/lib" "${PREFIX}/watchos/include/libev"
cp -a "${WATCHOS64_32_PREFIX}/include/" "${PREFIX}/watchos/include/libev"
lipo -create \
  "${WATCHOS32_PREFIX}/lib/libev.a" \
  "${WATCHOS64_32_PREFIX}/lib/libev.a" \
  -output "${PREFIX}/watchos/lib/libev.a"

echo "Bundling watchOS simulators..."

mkdir -p "${PREFIX}/watchos-simulators/lib" "${PREFIX}/watchos-simulators/include/libev"
cp -a "${WATCHOS_SIMULATOR_X86_64_PREFIX}/include/" "${PREFIX}/watchos-simulators/include/libev"
if [ "$APPLE_SILICON_SUPPORTED" = "true" ]; then
  lipo -create \
    "${WATCHOS_SIMULATOR_ARM64_PREFIX}/lib/libev.a" \
    "${WATCHOS_SIMULATOR_I386_PREFIX}/lib/libev.a" \
    "${WATCHOS_SIMULATOR_X86_64_PREFIX}/lib/libev.a" \
    -output "${PREFIX}/watchos-simulators/lib/libev.a"
else
  lipo -create \
    "${WATCHOS_SIMULATOR_I386_PREFIX}/lib/libev.a" \
    "${WATCHOS_SIMULATOR_X86_64_PREFIX}/lib/libev.a" \
    -output "${PREFIX}/watchos-simulators/lib/libev.a"
fi

echo "Bundling tvOS targets..."

mkdir -p "${PREFIX}/tvos/lib" "${PREFIX}/tvos/include/libev"
cp -a "${TVOS64_PREFIX}/include/" "${PREFIX}/tvos/include/libev"
lipo -create \
  "$TVOS64_PREFIX/lib/libev.a" \
  -output "$PREFIX/tvos/lib/libev.a"

echo "Bundling tvOS simulators..."

mkdir -p "${PREFIX}/tvos-simulators/lib" "${PREFIX}/tvos-simulators/include/libev"
cp -a "${TVOS_SIMULATOR_X86_64_PREFIX}/include/" "${PREFIX}/tvos-simulators/include/libev"
if [ "$APPLE_SILICON_SUPPORTED" = "true" ]; then
  lipo -create \
    "${TVOS_SIMULATOR_ARM64_PREFIX}/lib/libev.a" \
    "${TVOS_SIMULATOR_X86_64_PREFIX}/lib/libev.a" \
    -output "${PREFIX}/tvos-simulators/lib/libev.a" || exit 1
else
  lipo -create \
    "${TVOS_SIMULATOR_X86_64_PREFIX}/lib/libev.a" \
    -output "${PREFIX}/tvos-simulators/lib/libev.a" || exit 1
fi

echo "Bundling Catalyst targets..."

mkdir -p "${PREFIX}/catalyst/lib" "${PREFIX}/catalyst/include/libev"
cp -a "${CATALYST_X86_64_PREFIX}/include/" "${PREFIX}/catalyst/include/libev"
if [ ! -f "${CATALYST_X86_64_PREFIX}/lib/libev.a" ]; then
  continue
fi
if [ "$APPLE_SILICON_SUPPORTED" = "true" ]; then
  lipo -create \
    "${CATALYST_ARM64_PREFIX}/lib/libev.a" \
    "${CATALYST_X86_64_PREFIX}/lib/libev.a" \
    -output "${PREFIX}/catalyst/lib/libev.a"
else
  lipo -create \
    "${CATALYST_X86_64_PREFIX}/lib/libev.a" \
    -output "${PREFIX}/catalyst/lib/libev.a"
fi

echo "Creating libev.xcframework..."

XCFRAMEWORK_ARGS=""
for f in macos ios ios-simulators watchos watchos-simulators tvos tvos-simulators catalyst; do
  XCFRAMEWORK_ARGS="${XCFRAMEWORK_ARGS} -library ${PREFIX}/${f}/lib/libev.a"
  XCFRAMEWORK_ARGS="${XCFRAMEWORK_ARGS} -headers ${PREFIX}/${f}/include"
done
xcodebuild -create-xcframework ${XCFRAMEWORK_ARGS} -output "${PREFIX}/libev.xcframework" >/dev/null

ls -l -- "$PREFIX/libev.xcframework"

rm -rf "${ROOT}/libev.xcframework"
cp -a "${PREFIX}/libev.xcframework" ${ROOT}

echo "Done!"

# Cleanup
rm -rf -- "$PREFIX/tmp"
make distclean >/dev/null

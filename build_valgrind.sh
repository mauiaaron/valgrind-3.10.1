#!/bin/bash

##set -x

# These need to be set to the proper Android NDK ...
export NDK_HOME=$HOME/Android/android-ndk
export HWKIND=generic
export TOOLCHAIN=$NDK_HOME/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi
##APP_PLATFORM_LEVEL=$(make --no-print-dir -f $NDK_HOME/build/core/build-local.mk -C . DUMP_APP_PLATFORM_LEVEL)
APP_PLATFORM_LEVEL=21

export AR=$TOOLCHAIN-ar
export LD=$TOOLCHAIN-ld
export CC=$TOOLCHAIN-gcc

pushd ./valgrind-3.10.1

CPPFLAGS="--sysroot=$NDK_HOME/platforms/android-21/arch-arm -DAPP_PLATFORM_LEVEL=$APP_PLATFORM_LEVEL -DANDROID_HARDWARE_$HWKIND" CFLAGS="--sysroot=$NDK_HOME/platforms/android-21/arch-arm" ./configure --prefix=/data/local/Inst --host=armv7-unknown-linux --target=armv7-unknown-linux --with-tmpdir=/sdcard

make -j4

popd

##set +x

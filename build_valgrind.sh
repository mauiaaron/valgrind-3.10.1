#!/bin/bash

#
# Build script inspired from http://stackoverflow.com/questions/16450650/android-valgrind-build-fails/19255251
#

set -x

# These need to be set to the proper Android NDK ...
export NDK_HOME=$HOME/Android/android-ndk
export SDK_HOME=$HOME/Android/Sdk
export HWKIND=generic
export TOOLCHAIN_PREFIX=$NDK_HOME/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi

##APP_PLATFORM_LEVEL=$(make --no-print-dir -f $NDK_HOME/build/core/build-local.mk -C . DUMP_APP_PLATFORM_LEVEL)
APP_PLATFORM=android-21
APP_PLATFORM_LEVEL=21

set +x

###############################################################################
# hopefully you don't need to edit below here

usage() {
    echo "$0 clean"
    echo "$0 [autogen] [build] [install] [load]"
    exit 0
}

while test "x$1" != "x"; do
    case "$1" in
        "clean")
            do_clean=1
            ;;

        "autogen")
            do_autogen=1
            ;;

        "build")
            do_build=1
            ;;

        "install")
            do_install=1
            ;;

        "load")
            do_load=1
            ;;

        "--help")
            usage
            ;;

        *)
            usage
            ;;
    esac
    shift
done

set -x

export AR=$TOOLCHAIN_PREFIX-ar
export LD=$TOOLCHAIN_PREFIX-ld
export CC=$TOOLCHAIN_PREFIX-gcc

export CPPFLAGS="--sysroot=$NDK_HOME/platforms/$APP_PLATFORM/arch-arm -DAPP_PLATFORM_LEVEL=$APP_PLATFORM_LEVEL -DANDROID_HARDWARE_$HWKIND"
export CFLAGS="--sysroot=$NDK_HOME/platforms/$APP_PLATFORM/arch-arm" 

ADB_BIN=$SDK_HOME/platform-tools/adb

pushd ./valgrind-3.10.1

if test "x$do_clean" = "x1" ; then
    make distclean
    exit 1
fi

if test "x$do_autogen" = "x1" ; then
    ./autogen.sh
fi

if test "x$do_build" = "x1" ; then
    ./configure --prefix=/data/local/Inst --host=armv7-unknown-linux --target=armv7-unknown-linux --with-tmpdir=/sdcard
    make -j4
    make -j4 install DESTDIR=`pwd`/Inst
fi

if test "x$do_install" = "x1" ; then

    if [[ $($ADB_BIN shell ls -ld /data/local/Inst/bin/valgrind) = *"No such file or directory"* ]]; then
        if [[ $($ADB_BIN root) = *"root access is disabled"* ]] ; then
            echo "Oops, adb root failed ... maybe need to edit device root access settings?"
            exit 1
        fi
        $ADB_BIN remount
        $ADB_BIN shell "[ ! -d /data/local/Inst ] && mkdir /data/local/Inst"
        $ADB_BIN push Inst /
        $ADB_BIN shell "ls -l /data/local/Inst"

        # Ensure Valgrind on the phone is running
        $ADB_BIN shell "/data/local/Inst/bin/valgrind --version"

        # Add Valgrind executable to PATH (this might fail)
        $ADB_BIN shell "export PATH=$PATH:/data/local/Inst/bin/"
    fi
fi

if test "x$do_load" = "x1" ; then
    TODO
fi

popd

set +x

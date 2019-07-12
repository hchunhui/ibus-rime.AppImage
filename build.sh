#!/bin/bash

J=1
H="$PWD"
INC_PATH="$H/librime/thirdparty/include"
LIB_PATH="$H/librime/thirdparty/lib"

fetch_boost_mini() {
    pushd . &&
    cd boost &&
    git clone --depth=1 https://github.com/boostorg/system.git &&
    git clone --depth=1 https://github.com/boostorg/filesystem.git &&
    git clone --depth=1 https://github.com/boostorg/locale.git &&
    git clone --depth=1 https://github.com/boostorg/regex.git &&
    popd
}

fetch_librime() {
    pushd . &&
    git clone --depth=1 https://github.com/rime/librime.git --recursive &&
    cd librime &&
    ./install-plugins.sh lotem/librime-octagram &&
    ./install-plugins.sh hchunhui/librime-lua &&
    cd plugins/lua &&
    bash ./travis-install.sh &&
    patch -p1 < "$H/patches/lua.patch" &&
    cd ../.. &&
    patch -p1 < "$H/patches/librime.patch" &&
    popd
}

fetch_ibus_rime() {
    pushd . &&
    git clone --depth=1 https://github.com/rime/ibus-rime.git &&
    cd ibus-rime &&
    patch -p1 < "$H/patches/ibus-rime.patch" &&
    popd
}

build_boost_mini() {
    pushd . &&
    cd boost &&
    rm -rf build &&
    mkdir build &&
    cd build && cmake .. && make -j"$J" &&
    cp *.a "$LIB_PATH" &&
    cd .. &&
    cp -r filesystem/include/* "$INC_PATH" &&
    cp -r locale/include/* "$INC_PATH" &&
    cp -r regex/include/* "$INC_PATH" &&
    cp -r system/include/* "$INC_PATH" &&
    popd
}

build_thirdparty() {
    cd librime &&
    make thirdparty -j"$J" &&
    cd ..
}

build_librime() {
    cd librime &&
    make -j"$J" &&
    cd ..
}

build_ibus_rime() {
    cd ibus-rime &&
    make &&
    cd ..
}

fetch_plum() {
    pushd . &&
    git clone --depth=1 https://github.com/rime/plum.git &&
    cd plum &&
    make &&
    popd
}

bundle() {
    ./linuxdeploy-x86_64.AppImage -e ibus-rime/build/ibus-engine-rime --appdir=AppDir &&
    ./linuxdeploy-x86_64.AppImage -e librime/build/bin/rime_deployer --appdir=AppDir &&
    ./linuxdeploy-x86_64.AppImage -e librime/build/bin/rime_dict_manager --appdir=AppDir &&
    ./linuxdeploy-x86_64.AppImage -e librime/build/bin/rime_patch --appdir=AppDir &&
    mkdir -p AppDir/usr/share/ibus-rime &&
    cp -r ibus-rime/icons AppDir/usr/share/ibus-rime/ &&
    mv plum/output AppDir/usr/share/rime-data &&
    cp -r librime/thirdparty/share/opencc AppDir/usr/share/rime-data/ &&
    ./appimagetool-x86_64.AppImage AppDir
}

wget "https://github.com/AppImage/AppImageKit/releases/download/12/appimagetool-x86_64.AppImage" &&
wget "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage" &&
chmod +x appimagetool-x86_64.AppImage &&
chmod +x linuxdeploy-x86_64.AppImage &&
fetch_boost_mini &&
fetch_librime &&

build_boost_mini &&
build_thirdparty &&
build_librime &&

fetch_ibus_rime &&
build_ibus_rime &&

fetch_plum &&

bundle

mkdir out
cd out
mv ../ibus-engine-rime-x86_64.AppImage .
mv ../librime/build/lib/librime-*.so .
cd ..
tar czvf out.tgz out

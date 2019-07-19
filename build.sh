#!/bin/bash

J=1
H="$PWD"
INC_PATH="$H/librime/thirdparty/include"
LIB_PATH="$H/librime/thirdparty/lib"

get_version() {
    git describe --always
}

fetch_boost_mini() {
    pushd . &&
    cd boost &&
    git clone -b 'boost-1.54.0' --depth=1 https://github.com/boostorg/system.git &&
    git clone -b 'boost-1.54.0' --depth=1 https://github.com/boostorg/filesystem.git &&
    git clone -b 'boost-1.54.0' --depth=1 https://github.com/boostorg/locale.git &&
    git clone -b 'boost-1.54.0' --depth=1 https://github.com/boostorg/regex.git &&
    popd
}

fetch_plugin() {
    ./install-plugins.sh "$1/librime-$2" &&
    cd "plugins/$2" &&
    echo "librime-$2 `get_version`" >> $H/version &&
    if [ -e "travis-install.sh" ]; then
        bash ./travis-install.sh
    fi &&
    cd ../..
}

fetch_librime() {
    pushd . &&
    git clone --shallow-exclude='1.5.0' https://github.com/rime/librime.git --recursive &&
    cd librime &&
    echo "librime `get_version`" >> $H/version &&
    patch -p1 < "$H/patches/librime/0001-link-boost-mini.patch" &&
    patch -p1 < "$H/patches/librime/0002-thirdparty-PIC.patch" &&
    fetch_plugin lotem octagram &&
    fetch_plugin hchunhui lua &&
    popd
}

fetch_ibus_rime() {
    pushd . &&
    git clone --shallow-exclude='1.3.0' https://github.com/rime/ibus-rime.git &&
    cd ibus-rime &&
    echo "ibus-rime `get_version`" >> $H/version &&
    patch -p1 < "$H/patches/ibus-rime/0001-patch-build-system.patch" &&
    patch -p1 < "$H/patches/ibus-rime/0002-relocatable.patch" &&
    patch -p1 < "$H/patches/ibus-rime/0003-my-color-scheme.patch" && # XXX
    popd
}

build_boost_mini() {
    pushd . &&
    cd boost &&
    rm -rf build &&
    mkdir build &&
    cd build && cmake -DCMAKE_BUILD_TYPE=Release .. && make -j"$J" &&
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

patch_exe () {
    cp "$1/$2" AppDir/usr/bin &&
    ./patchelf AppDir/usr/bin/"$2" --set-rpath '$ORIGIN/../lib'
}

patch_lib () {
    cp "$1/$2" AppDir/usr/lib &&
    ./patchelf AppDir/usr/lib/"$2" --set-rpath '$ORIGIN'
}

bundle() {
    cp ibus-rime/icons/rime.png AppDir/ibus-rime.png &&

    mkdir -p AppDir/usr/bin &&
    mkdir -p AppDir/usr/lib &&
    patch_exe /usr/bin notify-send &&
    patch_exe ibus-rime/build ibus-engine-rime &&
    patch_exe librime/build/bin rime_deployer &&
    patch_exe librime/build/bin rime_dict_manager &&
    patch_exe librime/build/bin rime_patch &&
    patch_lib librime/build/lib librime.so.1 &&
    patch_lib librime/build/lib librime-lua.so &&
    patch_lib librime/build/lib librime-octagram.so &&
    patch_lib "/usr/lib/$(gcc -print-multiarch)" libnotify.so.4 &&
    patch_exe librime/build/plugins/octagram/bin build_grammar &&

    mkdir -p AppDir/usr/share/ibus-rime &&
    cp -r ibus-rime/icons AppDir/usr/share/ibus-rime/ &&
    mv plum/output AppDir/usr/share/rime-data &&
    cp -r librime/thirdparty/share/opencc AppDir/usr/share/rime-data/ &&
    cp ibus_rime.yaml AppDir/usr/share/rime-data/ &&

    echo 'EOF' >> version &&
    cp version AppDir/usr/bin &&
    gcc -O2 -o AppDir/usr/lib/exec0 tools/exec0.c &&

    ./appimagetool-x86_64.AppImage AppDir
}

fetch_build_patchelf() {
    git clone https://github.com/NixOS/patchelf.git --depth=1 patchelf-src &&
    g++ patchelf-src/src/patchelf.cc -Wall -std=c++11 -D_FILE_OFFSET_BITS=64 -DPACKAGE_STRING='""' -DPAGESIZE=`getconf PAGESIZE` -o patchelf
}

set -x
echo -e '#!/bin/sh\ncat << EOF' > version &&
chmod +x version &&
wget "https://github.com/AppImage/AppImageKit/releases/download/12/appimagetool-x86_64.AppImage" &&
chmod +x appimagetool-x86_64.AppImage &&
fetch_build_patchelf &&
fetch_boost_mini &&
fetch_librime &&

build_boost_mini &&
build_thirdparty &&
build_librime &&

fetch_ibus_rime &&
build_ibus_rime &&

fetch_plum &&

bundle

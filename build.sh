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
    cp ibus-rime/icons/rime.png AppDir/ibus-rime.png &&
    ./linuxdeploy-x86_64.AppImage \
	-e /usr/bin/notify-send \
	-e ibus-rime/build/ibus-engine-rime \
	-e librime/build/bin/rime_deployer \
	-e librime/build/bin/rime_dict_manager \
	-e librime/build/bin/rime_patch \
	-l librime/build/lib/librime-lua.so \
	-l librime/build/lib/librime-octagram.so \
	-e librime/build/plugins/octagram/bin/build_grammar \
	--appdir=AppDir &&
    mkdir -p AppDir/usr/share/ibus-rime &&
    cp -r ibus-rime/icons AppDir/usr/share/ibus-rime/ &&
    mv plum/output AppDir/usr/share/rime-data &&
    cp -r librime/thirdparty/share/opencc AppDir/usr/share/rime-data/ &&
    cp ibus_rime.yaml AppDir/usr/share/rime-data/ &&
    echo 'EOF' >> version &&
    cp version AppDir/usr/bin &&
    ./appimagetool-x86_64.AppImage AppDir
}

set -x
echo -e '#!/bin/sh\ncat << EOF' > version &&
chmod +x version &&
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

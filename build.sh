#!/bin/bash

J=1
H="$PWD"
INC_PATH="$H/librime/include"
LIB_PATH="$H/librime/lib"
BOOST_VERSION="1.58.0"

fetch_boost_mini() {
    pushd . &&
    cd boost &&
    git clone -b "boost-$BOOST_VERSION" --depth=1 https://github.com/boostorg/system.git &&
    git clone -b "boost-$BOOST_VERSION" --depth=1 https://github.com/boostorg/filesystem.git &&
    git clone -b "boost-$BOOST_VERSION" --depth=1 https://github.com/boostorg/locale.git &&
    git clone -b "boost-$BOOST_VERSION" --depth=1 https://github.com/boostorg/regex.git &&
    git clone --depth=1 https://github.com/boostorg/dll.git &&
    popd
}

fetch_plugin() {
    ./install-plugins.sh "$1/librime-$2" &&
    cd "plugins/$2" &&
    if [ -e "action-install.sh" ]; then
        bash ./action-install.sh
    fi &&
    cd ../..
}

fetch_librime() {
    pushd . &&
    git clone --shallow-exclude='1.6.0' https://github.com/rime/librime.git &&
    cd librime &&
    patch -p1 < "$H/patches/librime/relocatable-plugins.patch" &&
    cd deps &&
        git clone https://github.com/google/snappy.git -b 1.1.9 snappy &&
        git clone https://github.com/google/glog.git -b v0.5.0  glog &&
        git clone https://github.com/google/leveldb.git -b 1.23 leveldb &&
        git clone https://github.com/s-yata/marisa-trie.git -b v0.2.6 marisa-trie &&
        git clone https://github.com/BYVoid/OpenCC.git opencc &&
        git clone https://github.com/jbeder/yaml-cpp.git -b yaml-cpp-0.7.0 yaml-cpp &&
    cd opencc &&
    patch -p1 < "$H/patches/opencc/0001-relocatable-opencc.patch" &&
    cd .. &&
    cd snappy &&
    patch -p1 < "$H/patches/snappy/add-static.patch" &&
    cd .. &&
    cd .. &&
    fetch_plugin rime charcode &&
    fetch_plugin lotem octagram &&
    fetch_plugin hchunhui lua &&
    popd
}

fetch_ibus_rime() {
    pushd . &&
    git clone --shallow-exclude='1.3.0' https://github.com/rime/ibus-rime.git &&
    cd ibus-rime &&
    cp "$H/cmake/FindRime.cmake" cmake &&
    patch -p1 < "$H/patches/ibus-rime/0002-relocatable.patch" &&
    popd
}

build_boost_mini() {
    pushd . &&
    cd boost &&
    rm -rf build &&
    mkdir build &&
    cd build && cmake -DCMAKE_BUILD_TYPE=MinSizeRel .. && make -j"$J" &&
    cp *.a "$LIB_PATH" &&
    cd .. &&
    cp -r filesystem/include/* "$INC_PATH" &&
    cp -r locale/include/* "$INC_PATH" &&
    cp -r regex/include/* "$INC_PATH" &&
    cp -r system/include/* "$INC_PATH" &&
    cp -r dll/include/* "$INC_PATH" &&
    popd
}

build_thirdparty() {
    cd librime &&
    make -f ../thirdparty.mk -j"$J" &&
    cd ..
}

build_librime() {
    cd librime &&
    cmake . -Bbuild \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_BUILD_TYPE=MinSizeRel \
        -DBUILD_TEST=OFF \
        -DBUILD_WITH_ICU=OFF \
        -DBUILD_MERGED_PLUGINS=OFF \
        -DENABLE_EXTERNAL_PLUGINS=ON \
        -DRIME_PLUGINS_DIR="/usr/lib/rime-plugins" \
        -DCMAKE_MODULE_PATH="$H/cmake" &&
    cmake --build build &&
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
    strip AppDir/usr/bin/"$2" &&
    ./patchelf AppDir/usr/bin/"$2" --set-rpath '$ORIGIN/../lib'
}

patch_lib () {
    cp "$1/$2" AppDir/usr/lib &&
    strip AppDir/usr/lib/"$2" &&
    ./patchelf AppDir/usr/lib/"$2" --set-rpath '$ORIGIN'
}

patch_plugin () {
    cp "$1/$2" AppDir/usr/lib/rime-plugins &&
    strip AppDir/usr/lib/rime-plugins/"$2" &&
    ./patchelf AppDir/usr/lib/rime-plugins/"$2" --set-rpath '$ORIGIN'
}

bundle() {
    cp ibus-rime/icons/rime.png AppDir/ibus-rime.png &&

    mkdir -p AppDir/usr/bin &&
    mkdir -p AppDir/usr/lib &&
    mkdir -p AppDir/usr/lib/rime-plugins
    patch_exe /usr/bin notify-send &&
    patch_exe ibus-rime/build ibus-engine-rime &&
    patch_exe librime/build/bin rime_deployer &&
    patch_exe librime/build/bin rime_dict_manager &&
    patch_exe librime/build/bin rime_patch &&
    patch_lib librime/build/lib librime.so.1 &&
    patch_lib librime/lib libglog.so.0 &&
    patch_plugin librime/build/lib librime-lua.so &&
    patch_plugin librime/build/lib librime-octagram.so &&
    patch_plugin librime/build/lib librime-charcode.so &&
    patch_lib librime/lib libopencc.so.1.1 &&
    patch_exe librime/bin opencc &&
    patch_exe librime/bin opencc_dict &&
    patch_exe librime/bin opencc_phrase_extract &&
    patch_lib "/usr/lib/$(gcc -print-multiarch)" libnotify.so.4 &&
    patch_exe librime/build/plugins/octagram/bin build_grammar &&

    mkdir -p AppDir/usr/share/ibus-rime &&
    cp -r ibus-rime/icons AppDir/usr/share/ibus-rime/ &&
    mv plum/output AppDir/usr/share/rime-data &&
    cp -r librime/share/opencc AppDir/usr/share/rime-data/ &&

    mkdir -p AppDir/usr/plum &&
    cd plum && (git archive master | tar -xv -C ../AppDir/usr/plum) && cd .. &&
    cd AppDir/usr/plum && patch -p1 < "$H/patches/plum/0001-relocatable-plum.patch" && cd ../../.. &&
    cd AppDir/usr/bin && ln -s ../plum/rime-install rime-install && cd ../../.. &&

    echo -e -n '#!/bin/sh\ncat << '"'EOF'"'\nPackaged by ' > version &&
    ./appimagetool-x86_64.AppImage --version 2>> version &&
    if [ -n "${TRAVIS_BUILD_WEB_URL}" ]; then
        echo "Travis CI build log: ${TRAVIS_BUILD_WEB_URL}" >> version
    fi &&
    echo '---' >> version &&
    (echo Source Version From && (find * .git -path '*.git' -exec ./describe '{}' \; | LC_ALL=C sort)) | column -t >> version &&
    echo '---' >> version &&
    (echo Binary From && (apt-get download --print-uris libnotify4 libnotify-bin | tr -d "'" | awk '{print $2" "$1}')) | column -t >> version &&
    echo 'EOF' >> version &&
    chmod +x version &&
    cp version AppDir/usr/bin &&
    gcc -O2 -o AppDir/usr/lib/exec0 tools/exec0.c &&

    ./appimagetool-x86_64.AppImage --comp zstd AppDir
}

fetch_build_patchelf() {
    git clone -b '0.10' --depth=1 https://github.com/NixOS/patchelf.git patchelf-src &&
    cd patchelf-src && patch -p1 < ../patches/patchelf/adjust_startPage_issue127_commit1cc234fea.patch && cd .. &&
    g++ patchelf-src/src/patchelf.cc -Wall -std=c++11 -D_FILE_OFFSET_BITS=64 -DPACKAGE_STRING='""' -DPAGESIZE=`getconf PAGESIZE` -o patchelf
}

check() {
    file=ibus-rime-x86_64.AppImage
    md5sum=$(md5sum "$file" | cut -d' ' -f1)
    sha1sum=$(sha1sum "$file" | cut -d' ' -f1)
    sha256sum=$(sha256sum "$file" | cut -d' ' -f1)
    echo "------"
    echo "$file:"
    echo ""
    echo "MD5 checksum: $md5sum"
    echo "SHA1 checksum: $sha1sum"
    echo "SHA256 checksum: $sha256sum"
}

set -x

git tag -d continuous

wget "https://github.com/hchunhui/AppImageKit/releases/download/zstd-only/appimagetool-x86_64.AppImage" &&
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

bundle &&

set +x &&
check

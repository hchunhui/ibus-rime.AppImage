# a minimal build of third party libraries for static linking

THIRD_PARTY_DIR = $(CURDIR)/thirdparty
SRC_DIR = $(THIRD_PARTY_DIR)/src
INCLUDE_DIR = $(THIRD_PARTY_DIR)/include
LIB_DIR = $(THIRD_PARTY_DIR)/lib
BIN_DIR = $(THIRD_PARTY_DIR)/bin
SHARE_DIR = $(THIRD_PARTY_DIR)/share

THIRD_PARTY_LIBS = capnproto snappy glog leveldb marisa opencc yaml-cpp

.PHONY: all clean-src $(THIRD_PARTY_LIBS)

all: $(THIRD_PARTY_LIBS)

# note: this won't clean output files under include/, lib/ and bin/.
clean-src:
	rm -r $(SRC_DIR)/glog/cmake-build || true
	rm -r $(SRC_DIR)/googletest/build || true
	rm -r $(SRC_DIR)/leveldb/build || true
	rm -r $(SRC_DIR)/marisa-trie/build || true
	rm -r $(SRC_DIR)/opencc/build || true
	rm -r $(SRC_DIR)/yaml-cpp/build || true

capnproto:
	cd $(SRC_DIR)/capnproto; \
	cmake . -Bbuild \
	-DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON \
	-DBUILD_SHARED_LIBS:BOOL=OFF \
	-DBUILD_TESTING:BOOL=OFF \
	-DCMAKE_BUILD_TYPE:STRING="Release" \
	-DCMAKE_INSTALL_PREFIX:PATH="$(THIRD_PARTY_DIR)" \
	&& cmake --build $(build) --target install

snappy:
	cd $(SRC_DIR)/snappy; \
	cmake . -Bcmake-build \
	-DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON \
	-DBUILD_SHARED_LIBS:BOOL=OFF \
	-DSNAPPY_BUILD_TESTS:BOOL=OFF \
	-DCMAKE_BUILD_TYPE:STRING="Release" \
	-DCMAKE_INSTALL_PREFIX:PATH="$(THIRD_PARTY_DIR)" \
	&& cmake --build cmake-build --target install

glog:
	cd $(SRC_DIR)/glog; \
	cmake . -Bcmake-build \
	-DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON \
	-DBUILD_TESTING:BOOL=OFF \
	-DWITH_GFLAGS:BOOL=OFF \
	-DWITH_UNWIND:BOOL=OFF \
	-DCMAKE_BUILD_TYPE:STRING="Release" \
	-DCMAKE_INSTALL_PREFIX:PATH="$(THIRD_PARTY_DIR)" \
	&& cmake --build cmake-build --target install

leveldb:
	cd $(SRC_DIR)/leveldb; \
	CXXFLAGS="-I$(INCLUDE_DIR)" LDFLAGS="-L$(LIB_DIR)" cmake . -Bbuild \
	-DHAVE_SNAPPY=1 \
	-DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON \
	-DLEVELDB_BUILD_BENCHMARKS:BOOL=OFF \
	-DLEVELDB_BUILD_TESTS:BOOL=OFF \
	-DCMAKE_BUILD_TYPE:STRING="Release" \
	-DCMAKE_INSTALL_PREFIX:PATH="$(THIRD_PARTY_DIR)" \
	&& cmake --build build --target install

marisa:
	cd $(SRC_DIR)/marisa-trie; \
	cmake $(SRC_DIR) -Bbuild \
	-DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON \
	-DCMAKE_BUILD_TYPE:STRING="Release" \
	-DCMAKE_INSTALL_PREFIX:PATH="$(THIRD_PARTY_DIR)" \
	&& cmake --build build --target install

opencc:
	cd $(SRC_DIR)/opencc; \
	cmake . -Bbuild \
	-DCMAKE_BUILD_TYPE:STRING="Release" \
	-DCMAKE_INSTALL_PREFIX:PATH="$(THIRD_PARTY_DIR)" \
	&& cmake --build build --target install

yaml-cpp:
	cd $(SRC_DIR)/yaml-cpp; \
	cmake . -Bbuild \
	-DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON \
	-DYAML_CPP_BUILD_CONTRIB:BOOL=OFF \
	-DYAML_CPP_BUILD_TESTS:BOOL=OFF \
	-DYAML_CPP_BUILD_TOOLS:BOOL=OFF \
	-DCMAKE_BUILD_TYPE:STRING="Release" \
	-DCMAKE_INSTALL_PREFIX:PATH="$(THIRD_PARTY_DIR)" \
	&& cmake --build build --target install

gtest:
	cd $(SRC_DIR)/googletest; \
	cmake . -Bbuild \
	-DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON \
	-DBUILD_GMOCK:BOOL=OFF \
	-DCMAKE_BUILD_TYPE:STRING="Release" \
	-DCMAKE_INSTALL_PREFIX:PATH="$(THIRD_PARTY_DIR)" \
	&& cmake --build build --target install

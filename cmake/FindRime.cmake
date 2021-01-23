include_directories(${PROJECT_SOURCE_DIR}/../librime/src)
link_directories(${PROJECT_SOURCE_DIR}/../librime/build/lib)
set(Rime_LIBRARIES rime)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=gnu99")
set(RIME_DATA_DIR "/usr/share/rime-data")


add_library(Level_01_01 STATIC ${CMAKE_CURRENT_SOURCE_DIR}/Level_01_01.cpp)
target_include_directories(Level_01_01
    PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../Level_01_01_inc>
)
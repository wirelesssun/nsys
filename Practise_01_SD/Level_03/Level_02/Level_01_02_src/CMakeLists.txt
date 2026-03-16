add_library(Level_01_02 STATIC ${CMAKE_CURRENT_SOURCE_DIR}/Level_01_02.cpp)
target_include_directories(Level_01_02
    PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../Level_01_02_inc>
)
add_subdirectory(Level_01_01_src)
add_subdirectory(Level_01_02_src)
add_library(Level_02 STATIC ${CMAKE_CURRENT_SOURCE_DIR}/Level_02.cpp)
target_link_libraries(Level_02 Level_01_01 Level_01_02)
target_include_directories(Level_02 PUBLIC 
${CMAKE_CURRENT_SOURCE_DIR}/Level_01_01_inc 
${CMAKE_CURRENT_SOURCE_DIR}/Level_01_02_inc
)
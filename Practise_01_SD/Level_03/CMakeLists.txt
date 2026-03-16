cmake_minimum_required(VERSION 3.10)
project(SortAlgorithmDemo LANGUAGES CXX)

# 设置 C++ 17 标准；
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON) 

# 全局设置所有目标生成位置无关代码
set(CMAKE_POSITION_INDEPENDENT_CODE ON) #先生成静态库，再被动态库链接，因此这个设置必须使能；

add_subdirectory(Level_02)
add_executable(Level_03 ${CMAKE_CURRENT_SOURCE_DIR}/Level_03.cpp)
target_link_libraries(Level_03 Level_02)
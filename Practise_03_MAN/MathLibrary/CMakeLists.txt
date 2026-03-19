cmake_minimum_required(VERSION 3.15)
project(MathLibrary VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# 1. 定义库目标
add_library(TestAdd STATIC src/TestAdd.cpp)

# 2. 配置头文件路径
target_include_directories(TestAdd PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)

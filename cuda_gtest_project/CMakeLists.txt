cmake_minimum_required(VERSION 3.10)
project(CudaGTestDemo LANGUAGES CXX CUDA)

# 设置标准
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CUDA_STANDARD 14)

# 包含头文件目录
include_directories(include)

# 编译核心库 (CUDA 实现)
add_library(vector_ops src/vector_ops.cu)

# 1. 编译主程序
add_executable(main_app src/main.cu)
target_link_libraries(main_app vector_ops)

# 2. 编译单元测试
# 在 Ubuntu 上通常可以通过 find_package 找到 GTest
find_package(GTest REQUIRED)
add_executable(unit_tests tests/test_vector_add.cpp)
target_link_libraries(unit_tests vector_ops GTest::GTest GTest::Main)
cmake_minimum_required(VERSION 3.18)
project(CudaMatrixAdd LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CUDA_STANDARD 17)

# 包含头文件目录
include_directories(include)

# 寻找 Google Test 库 (Ubuntu 需安装: sudo apt install libgtest-dev)
find_package(GTest REQUIRED)

# 编译 CUDA 核心库
add_library(matrix_lib STATIC src/main.cu)
set_target_properties(matrix_lib PROPERTIES CUDA_ARCHITECTURES 75) # 适配常见的 T4/RTX 显卡

# 编译主程序
add_executable(matrix_app src/main_entry.cpp)
target_link_libraries(matrix_app matrix_lib)

# 编译单元测试
add_executable(unit_tests tests/test_matrix.cpp)
target_link_libraries(unit_tests matrix_lib GTest::GTest GTest::Main)
cmake_minimum_required(VERSION 3.18)
project(CudaGTestMatrix LANGUAGES CXX CUDA)

# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CUDA_STANDARD 17)

# 自动获取 Google Test
include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/heads/main.zip
)
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

# 编译 CUDA 库
add_library(matrix_lib STATIC main.cu)
set_target_properties(matrix_lib PROPERTIES CUDA_RESOLVE_DEVICE_SYMBOLS ON)

# 编译测试可执行文件
add_executable(cuda_test tests/test_main.cpp)
target_link_libraries(cuda_test PRIVATE matrix_lib GTest::gtest_main)

# 启用测试功能
enable_testing()
add_test(NAME MatrixTest COMMAND cuda_test)
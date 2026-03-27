cmake_minimum_required(VERSION 3.18)
project(MatrixPerformance_V2 LANGUAGES CXX CUDA)

# 针对 NVIDIA T4 (Turing 架构) 优化
set(CMAKE_CUDA_ARCHITECTURES 75)
set(CMAKE_CXX_STANDARD 17)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

add_executable(MatMulCompare src/main.cpp src/matmul_kernels.cu)

target_link_libraries(MatMulCompare PRIVATE cuda cudart)
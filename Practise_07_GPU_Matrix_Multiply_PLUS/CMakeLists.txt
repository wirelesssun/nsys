cmake_minimum_required(VERSION 3.18)
project(MatrixT4Optimization LANGUAGES CXX CUDA)

set(CMAKE_CUDA_ARCHITECTURES 75) # NVIDIA T4
set(CMAKE_CXX_STANDARD 17)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
add_executable(MatMulRunner src/main.cpp src/matmul_kernels.cu)
target_link_libraries(MatMulRunner PRIVATE cuda cudart)
cmake_minimum_required(VERSION 3.18)
project(NR_PUSCH_Deinterleave LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CUDA_STANDARD 17)
# 针对 NVIDIA T4 (Turing SM 7.5) 架构优化
set(CMAKE_CUDA_ARCHITECTURES 75)

add_executable(deinterleaver_bench 
    src/main.cpp 
    src/cpu_impl.cpp 
    src/gpu_impl.cu
)

target_include_directories(deinterleaver_bench PRIVATE include)
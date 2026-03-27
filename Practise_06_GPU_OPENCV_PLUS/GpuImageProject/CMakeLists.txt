cmake_minimum_required(VERSION 3.18)
project(CudaImageProc LANGUAGES CXX CUDA)

# 针对 T4 GPU (Turing 架构) 的算力优化
set(CMAKE_CUDA_ARCHITECTURES 75)
set(CMAKE_CXX_STANDARD 17)

# 查找 OpenCV (仅用于 I/O)
find_package(OpenCV REQUIRED COMPONENTS core imgcodecs)

# 添加包含目录
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

# 定义可执行程序
add_executable(CudaImageProc src/main.cpp src/kernel.cu)

# 链接库
target_link_libraries(CudaImageProc PRIVATE ${OpenCV_LIBS})
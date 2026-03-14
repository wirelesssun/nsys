cmake_minimum_required(VERSION 3.10)
project(SortAlgorithmDemo LANGUAGES CXX)
# 设置 C++ 17 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# 禁用编译器的默认优化选项
set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_CXX_FLAGS_DEBUG "-g -O0")
# 包含头文件路径
include_directories(include)
aux_source_directory(src SRC1)
aux_source_directory(tests SRC2)
# 编译可执行程序
add_executable(sort_app
    ${SRC1}
    ${SRC2}
)
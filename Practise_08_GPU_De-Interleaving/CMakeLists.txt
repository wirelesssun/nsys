cmake_minimum_required(VERSION 3.10)
project(5G_NR_LDPC_Library CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 编译优化与兼容性配置
if(NOT MSVC)
    # 为 Linux 环境模拟 sprintf_s 的宏定义 (简单粗暴但有效)
    add_definitions(-Dsprintf_s=snprintf)
    
    # 忽略符号比较警告，避免刷屏，同时开启优化
    add_compile_options(-O3 -march=native -Wno-sign-compare -Wno-maybe-uninitialized)
else()
    add_compile_options(/O2 /W4)
endif()

# 指定头文件路径
include_directories("source")

# 获取源文件 (根据报错显示路径为 source 而非 Source files，请核对大小写)
file(GLOB_RECURSE SRC_FILES "source/*.cpp")

add_executable(ldpc_runner ${SRC_FILES})
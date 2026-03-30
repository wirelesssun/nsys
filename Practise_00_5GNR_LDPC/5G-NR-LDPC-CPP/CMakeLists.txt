cmake_minimum_required(VERSION 3.10)

# 项目名称
project(5G_NR_LDPC_Library CXX)

# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 编译优化选项 (针对 CPU 性能)
if(MSVC)
    add_compile_options(/W4 /O2)
else()
    add_compile_options(-Wall -Wextra -O3 -march=native)
endif()

# 指定头文件搜索路径
include_directories("source")

# 自动获取 Source files 目录下所有的源文件
file(GLOB_RECURSE SRC_FILES "source/*.cpp")

# 定义生成的目标可执行程序名称
add_executable(ldpc_runner ${SRC_FILES})

# 打印构建信息 (可选)
message(STATUS "Found Source Files: ${SRC_FILES}")
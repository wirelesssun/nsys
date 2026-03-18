cmake_minimum_required(VERSION 3.15)
project(MathLibrary VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# 1. 定义库目标
# add_library(TestAdd STATIC src/TestAdd.cpp include/TestAdd.h)
add_library(TestAdd STATIC src/TestAdd.cpp)

# 2. 配置头文件路径（核心：支持本地路径与安装路径）
target_include_directories(TestAdd PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

# 3. 设置安装规则
install(TARGETS TestAdd
    EXPORT TestAddTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    INCLUDES DESTINATION include
)

# 安装头文件
install(FILES include/TestAdd.h DESTINATION include)

# 4. 导出 CMake 配置文件 (供 find_package 搜索)
install(EXPORT TestAddTargets
    FILE TestAddConfig.cmake
    NAMESPACE Math::
    DESTINATION lib/cmake/TestAdd
)
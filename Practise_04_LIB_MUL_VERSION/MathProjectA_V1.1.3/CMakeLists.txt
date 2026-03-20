cmake_minimum_required(VERSION 3.15)
project(MathProjectA VERSION 1.1.3 LANGUAGES CXX)

# ---- 1. 全局配置 ----
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# 开启位置无关代码，防止链接错误
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# ---- 2. 定义目标库 ----
add_library(MathOperationsAdd STATIC src/addition.cpp)
add_library(MathOperationsSub STATIC src/subtraction.cpp)
add_library(MathOperationsMul STATIC src/multiplication.cpp)
add_library(MathOperationsDiv STATIC src/division.cpp)

# ---- 3. 配置头文件搜索路径 (关键：BUILD vs INSTALL) ----
target_include_directories(MathOperationsAdd PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)
target_include_directories(MathOperationsSub PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)
target_include_directories(MathOperationsMul PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)
target_include_directories(MathOperationsDiv PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

# ---- 4. 设置安装规则 (INSTALL) ----
# 将编译好的库、包含路径信息导出到 MathOperationsTargets 组中
install(TARGETS MathOperationsAdd
    EXPORT MathOperationsTargets
    LIBRARY DESTINATION lib             # 动态库安装路径
    ARCHIVE DESTINATION lib             # 静态库安装路径
    INCLUDES DESTINATION include        # 告知使用者头文件位置
)
install(TARGETS MathOperationsSub
    EXPORT MathOperationsTargets
    LIBRARY DESTINATION lib             # 动态库安装路径
    ARCHIVE DESTINATION lib             # 静态库安装路径
    INCLUDES DESTINATION include        # 告知使用者头文件位置
)
install(TARGETS MathOperationsMul
    EXPORT MathOperationsTargets
    LIBRARY DESTINATION lib             # 动态库安装路径
    ARCHIVE DESTINATION lib             # 静态库安装路径
    INCLUDES DESTINATION include        # 告知使用者头文件位置
)
install(TARGETS MathOperationsDiv
    EXPORT MathOperationsTargets
    LIBRARY DESTINATION lib             # 动态库安装路径
    ARCHIVE DESTINATION lib             # 静态库安装路径
    INCLUDES DESTINATION include        # 告知使用者头文件位置
)

# 安装公共头文件到系统的 include 目录
# install(FILES include/MathOps.h DESTINATION include)
install(DIRECTORY include/ DESTINATION include)
# ---- 5. 导出 CMake 配置文件 (供其他项目 find_package 使用) ----
# 这一步会自动生成 MathOperationsConfig.cmake
install(EXPORT MathOperationsTargets
    FILE MathOperationsConfig.cmake
    NAMESPACE MathProjectA::           # 使用命名空间防止库名冲突
    DESTINATION lib/cmake/MathOperations
)

# ---- 6. 生成版本控制文件 (可选但推荐) ----
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/MathOperationsConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
)


install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/MathOperationsConfigVersion.cmake"
    DESTINATION lib/cmake/MathOperations
)
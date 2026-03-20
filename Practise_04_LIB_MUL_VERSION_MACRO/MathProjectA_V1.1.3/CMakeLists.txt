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
macro(TAR_INC_DIR_MACRO)
    target_include_directories(${ARGV} PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
    )
endmacro()

TAR_INC_DIR_MACRO(MathOperationsAdd)
TAR_INC_DIR_MACRO(MathOperationsSub)
TAR_INC_DIR_MACRO(MathOperationsMul)
TAR_INC_DIR_MACRO(MathOperationsDiv)

# ---- 4. 设置安装规则 (INSTALL) ----
# 将编译好的库、包含路径信息导出到 MathOperationsTargets 组中
macro(INSTALL_MACRO)
    install(TARGETS ${ARGV}
        EXPORT MathOperationsTargets
        LIBRARY DESTINATION lib             # 动态库安装路径
        ARCHIVE DESTINATION lib             # 静态库安装路径
        INCLUDES DESTINATION include        # 告知使用者头文件位置
    )
endmacro()

INSTALL_MACRO(MathOperationsAdd)
INSTALL_MACRO(MathOperationsSub)
INSTALL_MACRO(MathOperationsMul)
INSTALL_MACRO(MathOperationsDiv)

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
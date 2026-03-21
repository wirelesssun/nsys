cmake_minimum_required(VERSION 3.10)
project(ImageProcessor LANGUAGES CXX)

# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 1. 寻找 OpenCV 库 (OpenCV 自身支持 CMake)
# REQUIRED 表示如果找不到则报错
find_package(OpenCV REQUIRED)

# 2. 打印 OpenCV 信息（可选，用于调试）
message(STATUS "OpenCV library status:")
message(STATUS "    version: ${OpenCV_VERSION}")
message(STATUS "    libraries: ${OpenCV_LIBS}")
message(STATUS "    include path: ${OpenCV_INCLUDE_DIRS}")

# 3. 添加你的可执行文件
add_executable(${PROJECT_NAME} src/main.cpp)

# 4. 链接 OpenCV 库
# OpenCV_LIBS 包含了读取、处理和显示图像所需的所有模块
target_link_libraries(${PROJECT_NAME} PRIVATE ${OpenCV_LIBS})

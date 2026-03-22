cmake_minimum_required(VERSION 3.10)
project(ImageProcessor LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 1. 指向你本地编译安装的 OpenCV 配置文件路径
# 注意：路径需指向包含 OpenCVConfig.cmake 的文件夹
# 2. 寻找本地 OpenCV 库
message(STATUS "OpenCV Path: ${OpenCV_DIR}")
# 使用 NO_DEFAULT_PATH 强制 CMake 忽略系统路径，本地搜索
find_package(OpenCV 4.14.0 REQUIRED NO_DEFAULT_PATH)
#find_package(OpenCV 4.13.0 REQUIRED NO_DEFAULT_PATH),Also would be OK.
#find_package(OpenCV 4.12.0 REQUIRED NO_DEFAULT_PATH),Also would be OK.
# 3. 添加执行文件
add_executable(${PROJECT_NAME} src/main.cpp)

# 4. 链接库
target_link_libraries(${PROJECT_NAME} PRIVATE ${OpenCV_LIBS})
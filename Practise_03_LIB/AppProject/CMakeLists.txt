cmake_minimum_required(VERSION 3.15)
project(AppProject LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)

# 1. 搜索 TestAdd 库
# 如果库安装在非标准路径，运行 cmake 时需指定 -DTestAdd_DIR=/安装路径/lib/cmake/TestAdd
find_package(TestAdd REQUIRED)

# 2. 定义可执行文件
add_executable(MyApp src/main.cpp)

# 3. 链接库 (自动获取头文件路径)
target_link_libraries(MyApp PRIVATE Math::TestAdd)
cmake_minimum_required(VERSION 3.12)
project(MySignalProject LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)

# 引入外部库配置
include(cmake/ExternalFFTW3.cmake)

# 添加你的源文件
add_executable(${PROJECT_NAME} src/main.cpp)

# 链接 FFTW3
target_link_libraries(${PROJECT_NAME} PRIVATE fftw3_lib pthread)
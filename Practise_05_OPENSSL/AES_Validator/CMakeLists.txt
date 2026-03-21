cmake_minimum_required(VERSION 3.12)
project(AES_Validator LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)

# 1. 包含外部库配置
include(cmake/ExternalOpenSSL.cmake)

# 2. 添加可执行文件
add_executable(${PROJECT_NAME} src/main.cpp)

# 3. 链接加密库及系统底层依赖 (pthread, dl)
target_link_libraries(${PROJECT_NAME} PRIVATE openssl_crypto pthread dl)
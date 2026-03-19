cmake_minimum_required(VERSION 3.15)
project(AppProject LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)

# 2. 定义可执行文件
add_executable(MyApp src/main.cpp)

# 3. 链接库
target_link_libraries(MyApp PRIVATE TestAdd)
target_link_directories(MyApp PRIVATE ../MathLibrary/build)
target_include_directories(MyApp PRIVATE ../MathLibrary/include)

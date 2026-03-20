cmake_minimum_required(VERSION 3.15)
project(CalculatorApp LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)

# 寻找 MathOps，并明确要求版本 1.2.0
find_package(MathOperations 1.2.0 REQUIRED)

add_executable(CalculatorApp src/main.cpp)

# 链接带命名空间的目标，自动获取头文件路径
target_link_libraries(CalculatorApp PRIVATE MathProjectA::MathOperations)
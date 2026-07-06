cmake_minimum_required(VERSION 3.10)
project(OFDM_Simulator)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 查找FFTW3库
find_package(PkgConfig REQUIRED)
pkg_check_modules(FFTW3 REQUIRED fftw3)

add_executable(ofdm_sim main.cpp)

# 链接FFTW3
target_include_directories(ofdm_sim PRIVATE ${FFTW3_INCLUDE_DIRS})
target_link_libraries(ofdm_sim ${FFTW3_LIBRARIES})
# 有些系统可能需要 -lfftw3，pkg-config会提供
target_link_libraries(ofdm_sim ${FFTW3_STATIC_LIBRARIES} ${FFTW3_LIBRARIES})
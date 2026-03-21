include(ExternalProject)

# 定义 FFTW3 的安装路径
set(FFTW3_INSTALL_DIR ${CMAKE_BINARY_DIR}/extern/fftw3)
set(FFTW3_INCLUDE_DIR ${FFTW3_INSTALL_DIR}/include)
set(FFTW3_LIB_DIR     ${FFTW3_INSTALL_DIR}/lib)
set(FFTW3_LIBRARIES   ${FFTW3_LIB_DIR}/libfftw3.a)

# 自动化下载、配置、编译和安装过程
ExternalProject_Add(ext_fftw3
    URL https://www.fftw.org/fftw-3.3.10.tar.gz  # 推荐使用预生成的发布包
    PREFIX ${CMAKE_BINARY_DIR}/fftw3_build
    CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${FFTW3_INSTALL_DIR} --enable-shared=no --enable-static=yes --enable-threads
    BUILD_COMMAND make -j8
    INSTALL_COMMAND make install
    BUILD_BYPRODUCTS ${FFTW3_LIBRARIES}
)

# 创建一个伪目标供主项目链接
file(MAKE_DIRECTORY ${FFTW3_INCLUDE_DIR})
add_library(fftw3_lib STATIC IMPORTED GLOBAL)
set_target_properties(fftw3_lib PROPERTIES
    IMPORTED_LOCATION ${FFTW3_LIBRARIES}
    INTERFACE_INCLUDE_DIRECTORIES ${FFTW3_INCLUDE_DIR}
)
add_dependencies(fftw3_lib ext_fftw3)
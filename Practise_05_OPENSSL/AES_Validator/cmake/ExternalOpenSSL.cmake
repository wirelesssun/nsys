include(ExternalProject)

# 定义安装路径
set(OPENSSL_INSTALL_DIR ${CMAKE_BINARY_DIR}/extern/openssl)
set(OPENSSL_INCLUDE_DIR ${OPENSSL_INSTALL_DIR}/include)
# 注意：根据系统架构 ARM/X86 和 OpenSSL 版本，库文件可能位于 lib 或 lib64 目录
set(OPENSSL_CRYPTO_LIB  ${OPENSSL_INSTALL_DIR}/lib/libcrypto.a) 
# set(OPENSSL_CRYPTO_LIB  ${OPENSSL_INSTALL_DIR}/lib64/libcrypto.a)
# 我很难理解的是，这个路径原本是：
# set(OPENSSL_CRYPTO_LIB  ${OPENSSL_INSTALL_DIR}/lib/libcrypto.a)
# 自动化构建 OpenSSL
ExternalProject_Add(ext_openssl
    URL https://www.openssl.org/source/openssl-3.0.13.tar.gz
    PREFIX ${CMAKE_BINARY_DIR}/openssl_build
    # 配置参数：仅编译静态库，不编译测试程序和共享库，以加快速度
    CONFIGURE_COMMAND <SOURCE_DIR>/config --prefix=${OPENSSL_INSTALL_DIR} --openssldir=${OPENSSL_INSTALL_DIR} no-shared no-tests
    BUILD_COMMAND make -j$(nproc)
    INSTALL_COMMAND make install_sw
    BUILD_BYPRODUCTS ${OPENSSL_CRYPTO_LIB}
)

# 创建伪目标供主程序链接
file(MAKE_DIRECTORY ${OPENSSL_INCLUDE_DIR})
add_library(openssl_crypto STATIC IMPORTED GLOBAL)
set_target_properties(openssl_crypto PROPERTIES
    IMPORTED_LOCATION ${OPENSSL_CRYPTO_LIB}
    INTERFACE_INCLUDE_DIRECTORIES ${OPENSSL_INCLUDE_DIR}
)
add_dependencies(openssl_crypto ext_openssl)
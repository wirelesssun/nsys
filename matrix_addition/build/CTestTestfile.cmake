# CMake generated Testfile for 
# Source directory: /home/ubuntu/sunlibo/matrix_addition
# Build directory: /home/ubuntu/sunlibo/matrix_addition/build
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(MatrixTest "/home/ubuntu/sunlibo/matrix_addition/build/cuda_test")
set_tests_properties(MatrixTest PROPERTIES  _BACKTRACE_TRIPLES "/home/ubuntu/sunlibo/matrix_addition/CMakeLists.txt;27;add_test;/home/ubuntu/sunlibo/matrix_addition/CMakeLists.txt;0;")
subdirs("_deps/googletest-build")

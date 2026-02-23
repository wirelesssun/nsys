#ifndef MATRIX_ADD_H
#define MATRIX_ADD_H

// 封装 CUDA 调用，供 C++ 或测试框架调用
void launch_matrix_add(const float* A, const float* B, float* C, int N);

#endif
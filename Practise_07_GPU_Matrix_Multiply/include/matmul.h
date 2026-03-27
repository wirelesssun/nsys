#ifndef MATMUL_H
#define MATMUL_H

#include <iostream>
#include <vector>

const int N = 128;         // 矩阵大小
const int BLOCK_SIZE = 16; // 线程块大小 (16x16)

// 方案一：纯 CPU 接口
void matmul_cpu(const float* A, const float* B, float* C);

// 方案二：常规 GPU 接口 (Global Memory)
float matmul_gpu_global(const float* h_A, const float* h_B, float* h_C);

// 方案三：优化 GPU 接口 (Shared Memory)
float matmul_gpu_shared(const float* h_A, const float* h_B, float* h_C);

#endif
#ifndef MATMUL_H
#define MATMUL_H

#include <vector>

const int N = 1024;         
const int BLOCK_DIM = 16;  

// 接口定义
void matmul_cpu(const float* A, const float* B, float* C);
float run_gpu_v2(const float* A, const float* B, float* C); // Global Memory
float run_gpu_v3(const float* A, const float* B, float* C); // Shared Memory
float run_gpu_v4(const float* A, const float* B, float* C); // ILP 1x2 (Thread Tiling)
float run_gpu_v5(const float* A, const float* B, float* C); // ILP 1x4 (Thread Tiling)

#endif
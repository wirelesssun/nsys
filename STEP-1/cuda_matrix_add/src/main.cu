#include <cuda_runtime.h>
#include "matrix_add.h"
#include <iostream>

// CUDA Kernel: 每个线程计算一个元素的加法
__global__ void matrixAddKernel(const float* A, const float* B, float* C, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) {
        C[i] = A[i] + B[i];
    }
}

void launch_matrix_add(const float* h_A, const float* h_B, float* h_C, int N) {
    float *d_A, *d_B, *d_C;
    size_t size = N * sizeof(float);

    // 分配显存
    cudaMalloc(&d_A, size);
    cudaMalloc(&d_B, size);
    cudaMalloc(&d_C, size);

    // 拷贝数据到显存
    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);

    // 启动核函数 (256个线程为一个块)
    int threadsPerBlock = 256;
    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;
    matrixAddKernel<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, N);

    // 拷贝结果回内存
    cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);

    // 释放显存
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);
}
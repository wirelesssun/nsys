#include <cuda_runtime.h>
#include <iostream>
#include <vector>

// CUDA 核函数：执行矩阵加法 C = A + B
__global__ void matrixAdd(const float* A, const float* B, float* C, int rows, int cols) {
    int i = blockIdx.y * blockDim.y + threadIdx.y;
    int j = blockIdx.x * blockDim.x + threadIdx.x;

    if (i < rows && j < cols) {
        int index = i * cols + j;
        C[index] = A[index] + B[index];
    }
}

// 辅助函数：封装 CUDA 调用逻辑
void runMatrixAdd(const std::vector<float>& h_A, const std::vector<float>& h_B, std::vector<float>& h_C, int rows, int cols) {
    size_t size = rows * cols * sizeof(float);
    float *d_A, *d_B, *d_C;

    // 分配显存
    cudaMalloc(&d_A, size);
    cudaMalloc(&d_B, size);
    cudaMalloc(&d_C, size);

    // 拷贝数据到显存
    cudaMemcpy(d_A, h_A.data(), size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B.data(), size, cudaMemcpyHostToDevice);

    // 定义线程块和网格
    dim3 threadsPerBlock(16, 16);
    dim3 blocksPerGrid((cols + threadsPerBlock.x - 1) / threadsPerBlock.x,
                       (rows + threadsPerBlock.y - 1) / threadsPerBlock.y);

    // 启动核函数
    matrixAdd<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, rows, cols);

    // 将结果拷回内存
    cudaMemcpy(h_C.data(), d_C, size, cudaMemcpyDeviceToHost);

    // 释放显存
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);
}


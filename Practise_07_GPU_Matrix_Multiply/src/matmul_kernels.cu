#include "matmul.h"
#include <cuda_runtime.h>

// --- 方案二：常规 Global Memory 核函数 ---
__global__ void matmul_global_kernel(const float* A, const float* B, float* C, int n) {
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    if (row < n && col < n) {
        float sum = 0.0f;
        for (int k = 0; k < n; k++) {
            sum += A[row * n + k] * B[k * n + col];
        }
        C[row * n + col] = sum;
    }
}

// --- 方案三：Shared Memory 优化核函数 (Tiling) ---
__global__ void matmul_shared_kernel(const float* A, const float* B, float* C, int n) {
    __shared__ float s_A[BLOCK_SIZE][BLOCK_SIZE];
    __shared__ float s_B[BLOCK_SIZE][BLOCK_SIZE];

    int tx = threadIdx.x; int ty = threadIdx.y;
    int row = blockIdx.y * BLOCK_SIZE + ty;
    int col = blockIdx.x * BLOCK_SIZE + tx;

    float sum = 0.0f;

    for (int m = 0; m < n / BLOCK_SIZE; ++m) {
        // 协作加载数据到共享内存
        s_A[ty][tx] = A[row * n + (m * BLOCK_SIZE + tx)];
        s_B[ty][tx] = B[(m * BLOCK_SIZE + ty) * n + col];
        __syncthreads(); // 确保加载完成

        for (int k = 0; k < BLOCK_SIZE; ++k) {
            sum += s_A[ty][k] * s_B[k][tx];
        }
        __syncthreads(); // 确保计算完成再进入下一轮加载
    }
    if (row < n && col < n) C[row * n + col] = sum;
}

// 通用包装函数逻辑
float run_gpu_test(const float* h_A, const float* h_B, float* h_C, bool use_shared) {
    int size = N * N * sizeof(float);
    float *d_A, *d_B, *d_C;
    cudaMalloc(&d_A, size); cudaMalloc(&d_B, size); cudaMalloc(&d_C, size);
    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);

    cudaEvent_t start, stop;
    cudaEventCreate(&start); cudaEventCreate(&stop);
    dim3 threads(BLOCK_SIZE, BLOCK_SIZE);
    dim3 grid(N / BLOCK_SIZE, N / BLOCK_SIZE);

    cudaEventRecord(start);
    if (use_shared) matmul_shared_kernel<<<grid, threads>>>(d_A, d_B, d_C, N);
    else matmul_global_kernel<<<grid, threads>>>(d_A, d_B, d_C, N);
    cudaEventRecord(stop);

    cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);
    cudaEventSynchronize(stop);
    float ms = 0; cudaEventElapsedTime(&ms, start, stop);

    cudaFree(d_A); cudaFree(d_B); cudaFree(d_C);
    cudaEventDestroy(start); cudaEventDestroy(stop);
    return ms;
}

float matmul_gpu_global(const float* h_A, const float* h_B, float* h_C) { return run_gpu_test(h_A, h_B, h_C, false); }
float matmul_gpu_shared(const float* h_A, const float* h_B, float* h_C) { return run_gpu_test(h_A, h_B, h_C, true); }
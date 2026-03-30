#include <cuda_runtime.h>
#include "deinterleaver.h"

// 方案二：基础 2D Kernel (直接操作 Global Memory)
__global__ void kernel_v2_basic(const int8_t* in, int8_t* out, int R, int Qm) {
    int r = blockIdx.y * blockDim.y + threadIdx.y;
    int c = blockIdx.x * blockDim.x + threadIdx.x;
    if (r < R && c < Qm) {
        out[r * Qm + c] = in[c * R + r];
    }
}

// 方案三：Shared Memory 优化 (2D Tile 加载)
__global__ void kernel_v3_shared(const int8_t* in, int8_t* out, int R, int Qm) {
    // 针对 T4 设计的 Tile 大小，Qm 最大为 8，R 最大为 4096
    __shared__ int8_t s_tile[32][9]; // 增加 padding 避免 Bank Conflict
    
    int r = blockIdx.y * blockDim.y + threadIdx.y;
    int c = blockIdx.x * blockDim.x + threadIdx.x;

    if (r < R && c < Qm) {
        s_tile[threadIdx.y][threadIdx.x] = in[c * R + r];
        __syncthreads();
        out[r * Qm + c] = s_tile[threadIdx.y][threadIdx.x];
    }
}

void run_gpu_bench(int mode, const int8_t* h_in, int8_t* h_out, int Qm, float& avg_ms) {
    int8_t *d_in, *d_out;
    cudaMalloc(&d_in, E_SIZE);
    cudaMalloc(&d_out, E_SIZE);
    cudaMemcpy(d_in, h_in, E_SIZE, cudaMemcpyHostToDevice);

    int R = E_SIZE / Qm;
    dim3 threads(Qm, 32); // x 对应 Qm, y 对应矩阵行
    dim3 blocks(1, (R + 31) / 32);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    for (int i = 0; i < ITERS; ++i) {
        if (mode == 2) kernel_v2_basic<<<blocks, threads>>>(d_in, d_out, R, Qm);
        else           kernel_v3_shared<<<blocks, threads>>>(d_in, d_out, R, Qm);
    }
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    
    float total_ms = 0;
    cudaEventElapsedTime(&total_ms, start, stop);
    avg_ms = total_ms / ITERS;

    cudaMemcpy(h_out, d_out, E_SIZE, cudaMemcpyDeviceToHost);

    cudaFree(d_in); cudaFree(d_out);
    cudaEventDestroy(start); cudaEventDestroy(stop);
}

void gpu_deinterleave_v2(const int8_t* h_in, int8_t* h_out, int Qm, float& ms) { run_gpu_bench(2, h_in, h_out, Qm, ms); }
void gpu_deinterleave_v3(const int8_t* h_in, int8_t* h_out, int Qm, float& ms) { run_gpu_bench(3, h_in, h_out, Qm, ms); }
#include <cuda_runtime.h>
#include "deinterleaver.h"
#define TILE_R 128
#define TILE_Q 8
// 方案二：基础 2D 核函数
__global__ void kernel_v2(const int8_t* in, int8_t* out, int R, int Qm) {
    int r = blockIdx.y * blockDim.y + threadIdx.y;
    int c = blockIdx.x * blockDim.x + threadIdx.x;
    if (r < R && c < Qm) {
        out[r * Qm + c] = in[c * R + r];
    }
}

// 方案三至七：预留占位实现（当前逻辑与 V2 一致，供后续优化填充）
__global__ void kernel_v3(const int8_t* in, int8_t* out, int R, int Qm) {
    int r = blockIdx.y * blockDim.y + threadIdx.y;
    int c = blockIdx.x * blockDim.x + threadIdx.x;
    if (c < Qm)
    {
      for(int thread_r = 0; thread_r < E_SIZE; thread_r += blockDim.y)
      {
        int global_r = r + thread_r;
        if (global_r < R)
          out[global_r * Qm + c] = in[c * R + global_r];
      }
    }
}
__global__ void kernel_v4(const int8_t* in, int8_t* out, int R, int Qm) {
    int r = blockIdx.y * blockDim.y + threadIdx.y;
    int c = blockIdx.x * blockDim.x + threadIdx.x;
    if (c < Qm)
    {
      for(int thread_r = 0; thread_r < E_SIZE; thread_r += blockDim.y)
      {
        int global_r = r + thread_r;
        if (global_r < R)
          out[global_r * Qm + c] = in[c * R + global_r];
      }
    }
}
__global__ void kernel_v5(const int8_t* in, int8_t* out, int R, int Qm) {
    int r = blockIdx.y * blockDim.y + threadIdx.y;
    int c = blockIdx.x * blockDim.x + threadIdx.x;
    if (c < Qm)
    {
      for(int thread_r = 0; thread_r < E_SIZE; thread_r += blockDim.y)
      {
        int global_r = r + thread_r;
        if (global_r < R)
          out[global_r * Qm + c] = in[c * R + global_r];
      }
    }
}
__global__ void kernel_v6(const int8_t* in, int8_t* out, int R, int Qm) {
    // 定义共享内存。增加一列 [TILE_Q + 1] 彻底消除 Bank Conflict
    // 空间占用: 32 * 9 * 1 byte = 288 bytes，远小于 T4 的 48KB 限制
    __shared__ int8_t tile[TILE_R][TILE_Q + 1];

    // 计算当前线程在矩阵中的坐标 (r, c)
    int r = blockIdx.y * TILE_R + threadIdx.y;
    int c = threadIdx.x; // 因为 Qm <= 8，我们让一个 Block 在 x 方向覆盖所有 Qm

    // --- 步骤 1: 联合读取 (Coalesced Load) ---
    // 5G NR 交织规律是按列写入。我们让线程连续读取输入流中相邻的比特
    // 输入索引 index_in = c * R + r
    if (r < R && c < Qm) {
        tile[threadIdx.y][threadIdx.x] = in[c * R + r];
    }

    // 必须同步，确保整个 Block 的数据都搬运到了 Shared Memory
    __syncthreads();

    // --- 步骤 2: 转换并写回 (Coalesced Store) ---
    // 解交织后的输出是按行存储的：out[r * Qm + c]
    // 此时访问 out 的地址是非常集中的，有利于触发 T4 的 L2 Cache 写入合并
    if (r < R && c < Qm) {
        out[r * Qm + c] = tile[threadIdx.y][threadIdx.x];
    }
}

double gpu_bench_run(int mode, const int8_t* h_in, int8_t* h_out, int Qm) {
    int8_t *d_in, *d_out;
    cudaMalloc(&d_in, E_SIZE);
    cudaMalloc(&d_out, E_SIZE);
    
    // H2D DMA 搬移
    cudaMemcpy(d_in, h_in, E_SIZE, cudaMemcpyHostToDevice);

    int R = E_SIZE / Qm;
    dim3 threads_v2(Qm, 32); 
    dim3 blocks_v2(1, (R + 31) / 32);
    dim3 threads_v3(Qm, 32); 
    dim3 blocks_v3(1, 1);
    dim3 threads_v4(Qm, 64); 
    dim3 blocks_v4(1, 1);
    dim3 threads_v5(Qm, 128); 
    dim3 blocks_v5(1, 1);
    // 配置二维线程块：x 维度覆盖 Qm (最大8), y 维度覆盖 R 的分片 (32)
    dim3 threads_v6(TILE_Q, TILE_R); 
    // Grid 仅需在 y 维度增长
    dim3 blocks_v6(1, (R + TILE_R - 1) / TILE_R);

    cudaEvent_t start, stop;
    cudaEventCreate(&start); cudaEventCreate(&stop);

    cudaEventRecord(start);
    for (int i = 0; i < ITERS; ++i) {
        switch(mode) {
            case 2: kernel_v2<<<blocks_v2, threads_v2>>>(d_in, d_out, R, Qm); break;
            case 3: kernel_v3<<<blocks_v3, threads_v3>>>(d_in, d_out, R, Qm); break;
            case 4: kernel_v4<<<blocks_v4, threads_v4>>>(d_in, d_out, R, Qm); break;
            case 5: kernel_v5<<<blocks_v5, threads_v5>>>(d_in, d_out, R, Qm); break;
            case 6: kernel_v6<<<blocks_v6, threads_v6>>>(d_in, d_out, R, Qm); break;
            default: break;
        }
    }
    cudaEventRecord(stop);
    
    // D2H DMA 搬移
    cudaMemcpy(h_out, d_out, E_SIZE, cudaMemcpyDeviceToHost);
    cudaEventSynchronize(stop);

    float ms = 0;
    cudaEventElapsedTime(&ms, start, stop);
    
    cudaFree(d_in); cudaFree(d_out);
    cudaEventDestroy(start); cudaEventDestroy(stop);
    return (double)ms / ITERS;
}
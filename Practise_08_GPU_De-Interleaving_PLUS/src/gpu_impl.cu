#include <cuda_runtime.h>
#include "deinterleaver.h"

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
        if (global_r< R)
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
        if (global_r< R)
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
        if (global_r< R)
          out[global_r * Qm + c] = in[c * R + global_r];
      }
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

    cudaEvent_t start, stop;
    cudaEventCreate(&start); cudaEventCreate(&stop);

    cudaEventRecord(start);
    for (int i = 0; i < ITERS; ++i) {
        switch(mode) {
            case 2: kernel_v2<<<blocks_v2, threads_v2>>>(d_in, d_out, R, Qm); break;
            case 3: kernel_v3<<<blocks_v3, threads_v3>>>(d_in, d_out, R, Qm); break;
            case 4: kernel_v4<<<blocks_v4, threads_v4>>>(d_in, d_out, R, Qm); break;
            case 5: kernel_v5<<<blocks_v5, threads_v5>>>(d_in, d_out, R, Qm); break;
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
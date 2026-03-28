#include "matmul.h"
#include <cuda_runtime.h>

// V2: 基础全局内存访问
__global__ void k_v2(const float* A, const float* B, float* C, int n) {
    int r = blockIdx.y * blockDim.y + threadIdx.y;
    int c = blockIdx.x * blockDim.x + threadIdx.x;
    if (r < n && c < n) {
        float sum = 0.0f;
        for (int k = 0; k < n; k++) sum += A[r * n + k] * B[k * n + c];
        C[r * n + c] = sum;
    }
}

// V3: 基础共享内存 (16x16 Tile)
__global__ void k_v3(const float* A, const float* B, float* C, int n) {
    __shared__ float s_A[BLOCK_DIM][BLOCK_DIM], s_B[BLOCK_DIM][BLOCK_DIM];
    int tx = threadIdx.x, ty = threadIdx.y;
    int r = blockIdx.y * BLOCK_DIM + ty, c = blockIdx.x * BLOCK_DIM + tx;
    float sum = 0.0f;
    for (int m = 0; m < n/BLOCK_DIM; m++) {
        s_A[ty][tx] = A[r * n + m * BLOCK_DIM + tx];
        s_B[ty][tx] = B[(m * BLOCK_DIM + ty) * n + c];
        __syncthreads();
        #pragma unroll
        for (int k = 0; k < BLOCK_DIM; k++) sum += s_A[ty][k] * s_B[k][tx];
        __syncthreads();
    }
    C[r * n + c] = sum;
}

// V4: 1x2 ILP (垂直缩减一半)
__global__ void k_v4(const float* A, const float* B, float* C, int n) {
    __shared__ float s_A[BLOCK_DIM][BLOCK_DIM], s_B[BLOCK_DIM][BLOCK_DIM];
    int tx = threadIdx.x, ty = threadIdx.y; // ty: 0-7
    int r0 = blockIdx.y * BLOCK_DIM + ty, r1 = r0 + 8;
    int c = blockIdx.x * BLOCK_DIM + tx;
    float sum0 = 0, sum1 = 0;
    for (int m = 0; m < n/BLOCK_DIM; m++) {
        s_A[ty][tx] = A[r0*n + m*BLOCK_DIM + tx];
        s_A[ty+8][tx] = A[r1*n + m*BLOCK_DIM + tx];
        s_B[ty][tx] = B[(m*BLOCK_DIM + ty)*n + c];
        s_B[ty+8][tx] = B[(m*BLOCK_DIM + ty+8)*n + c];
        __syncthreads();
        #pragma unroll
        for (int k = 0; k < BLOCK_DIM; k++) {
            float b_val = s_B[k][tx];
            sum0 += s_A[ty][k] * b_val; sum1 += s_A[ty+8][k] * b_val;
        }
        __syncthreads();
    }
    C[r0*n+c] = sum0; C[r1*n+c] = sum1;
}

// V5: 1x4 ILP (垂直缩减四分之一)
__global__ void k_v5(const float* A, const float* B, float* C, int n) {
    __shared__ float s_A[BLOCK_DIM][BLOCK_DIM], s_B[BLOCK_DIM][BLOCK_DIM];
    int tx = threadIdx.x, ty = threadIdx.y; // ty: 0-3
    int c = blockIdx.x * BLOCK_DIM + tx;
    float res[4] = {0};
    for (int m = 0; m < n/BLOCK_DIM; m++) {
        for(int i=0; i<4; i++) {
            s_A[ty + i*4][tx] = A[(blockIdx.y*BLOCK_DIM + ty + i*4)*n + m*BLOCK_DIM + tx];
            s_B[ty + i*4][tx] = B[(m*BLOCK_DIM + ty + i*4)*n + c];
        }
        __syncthreads();
        #pragma unroll
        for (int k = 0; k < BLOCK_DIM; k++) {
            float b_val = s_B[k][tx];
            res[0] += s_A[ty][k] * b_val; res[1] += s_A[ty+4][k] * b_val;
            res[2] += s_A[ty+8][k] * b_val; res[3] += s_A[ty+12][k] * b_val;
        }
        __syncthreads();
    }
    for(int i=0; i<4; i++) C[(blockIdx.y*BLOCK_DIM + ty + i*4)*n + c] = res[i];
}

float wrapper(int v, const float* h_A, const float* h_B, float* h_C) {
    float *d_A, *d_B, *d_C; int size = N*N*sizeof(float);
    cudaMalloc(&d_A, size); cudaMalloc(&d_B, size); cudaMalloc(&d_C, size);
    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);
    cudaEvent_t start, stop; cudaEventCreate(&start); cudaEventCreate(&stop);
    cudaEventRecord(start);
    if(v==2) k_v2<<<dim3(N/16, N/16), dim3(16, 16)>>>(d_A, d_B, d_C, N);
    else if(v==3) k_v3<<<dim3(N/16, N/16), dim3(16, 16)>>>(d_A, d_B, d_C, N);
    else if(v==4) k_v4<<<dim3(N/16, N/16), dim3(16, 8)>>>(d_A, d_B, d_C, N);
    else if(v==5) k_v5<<<dim3(N/16, N/16), dim3(16, 4)>>>(d_A, d_B, d_C, N);
    cudaEventRecord(stop);
    cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);
    cudaEventSynchronize(stop); float ms; cudaEventElapsedTime(&ms, start, stop);
    cudaFree(d_A); cudaFree(d_B); cudaFree(d_C); return ms;
}
float run_gpu_v2(const float* A, const float* B, float* C) { return wrapper(2, A, B, C); }
float run_gpu_v3(const float* A, const float* B, float* C) { return wrapper(3, A, B, C); }
float run_gpu_v4(const float* A, const float* B, float* C) { return wrapper(4, A, B, C); }
float run_gpu_v5(const float* A, const float* B, float* C) { return wrapper(5, A, B, C); }
#include "kernel.h"
#include <device_launch_parameters.h>
#include <math.h>

// 辅助函数：实现镜像边界坐标计算 (__device__ 函数可在核函数中调用)
__device__ int get_mirror_idx(int idx, int max_val) {
    if (idx < 0) return -idx;               // 越过左/上边界，镜像回正
    if (idx >= max_val) return 2 * max_val - 2 - idx; // 越过右/下边界，镜像回负
    return idx;
}

// 1. 13*13 窗口精确高斯低通平滑滤波 (含镜像边界处理)
__global__ void lowpass_kernel(unsigned char* in, unsigned char* out, int w, int h, int c) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    const int radius = 6; 
    const float sigma = 3.0f;
    const float twoSigmaSq = 2.0f * sigma * sigma;

    if (x < w && y < h) {
        for (int k = 0; k < c; k++) {
            float weighted_sum = 0.0f;
            float weight_total = 0.0f;

            for (int i = -radius; i <= radius; i++) {
                // 计算 Y 方向镜像坐标
                int cur_y = get_mirror_idx(y + i, h);
                
                for (int j = -radius; j <= radius; j++) {
                    // 计算 X 方向镜像坐标
                    int cur_x = get_mirror_idx(x + j, w);
                    
                    float dist_sq = (float)(i * i + j * j);
                    float weight = expf(-dist_sq / twoSigmaSq);
                    
                    // 使用镜像后的坐标 cur_y 和 cur_x 取值
                    weighted_sum += weight * (float)in[(cur_y * w + cur_x) * c + k];
                    weight_total += weight;
                }
            }
            out[(y * w + x) * c + k] = (unsigned char)(weighted_sum / weight_total);
        }
    }
}

// 2. 13*13 窗口高通锐化滤波 (含镜像边界处理)
__global__ void highpass_kernel(unsigned char* in, unsigned char* out, int w, int h, int c) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    const int radius = 6;
    const float sigma = 3.0f;
    const float twoSigmaSq = 2.0f * sigma * sigma;
    const float strength = 1.5f;

    if (x < w && y < h) {
        for (int k = 0; k < c; k++) {
            float weighted_sum = 0.0f;
            float weight_total = 0.0f;
            int center_pixel = in[(y * w + x) * c + k];

            for (int i = -radius; i <= radius; i++) {
                int cur_y = get_mirror_idx(y + i, h);
                for (int j = -radius; j <= radius; j++) {
                    int cur_x = get_mirror_idx(x + j, w);
                    
                    float weight = expf(-(float)(i * i + j * j) / twoSigmaSq);
                    weighted_sum += weight * (float)in[(cur_y * w + cur_x) * c + k];
                    weight_total += weight;
                }
            }
            float lowpass_val = weighted_sum / weight_total;
            float res = (float)center_pixel + ((float)center_pixel - lowpass_val) * strength;

            out[(y * w + x) * c + k] = (unsigned char)max(0.0f, min(255.0f, res));
        }
    }
}

// 3. 顺时针 90 度旋转
__global__ void rotate_kernel(unsigned char* in, unsigned char* out, int w, int h, int c) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x < w && y < h) {
        int target_x = h - 1 - y;
        int target_y = x;
        for (int k = 0; k < c; k++) {
            out[(target_y * h + target_x) * c + k] = in[(y * w + x) * c + k];
        }
    }
}

void process_image_cuda(unsigned char* d_input, unsigned char* d_output_low, 
                        unsigned char* d_output_high, unsigned char* d_output_rotate,
                        int width, int height, int channels) {
    dim3 blockSize(16, 16);
    dim3 gridSize((width + blockSize.x - 1) / blockSize.x, (height + blockSize.y - 1) / blockSize.y);

    lowpass_kernel<<<gridSize, blockSize>>>(d_input, d_output_low, width, height, channels);
    highpass_kernel<<<gridSize, blockSize>>>(d_input, d_output_high, width, height, channels);
    rotate_kernel<<<gridSize, blockSize>>>(d_input, d_output_rotate, width, height, channels);
    
    cudaDeviceSynchronize();
}
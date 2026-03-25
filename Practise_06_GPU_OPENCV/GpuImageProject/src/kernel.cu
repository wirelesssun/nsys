#include "kernel.h"
#include <device_launch_parameters.h>

// 1. 低通滤波：3x3 均值平滑
__global__ void lowpass_kernel(unsigned char* in, unsigned char* out, int w, int h, int c) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x > 0 && x < w - 1 && y > 0 && y < h - 1) {
        for (int k = 0; k < c; k++) {
            int sum = 0;
            for (int i = -1; i <= 1; i++) {
                for (int j = -1; j <= 1; j++) {
                    sum += in[((y + i) * w + (x + j)) * c + k];
                }
            }
            out[(y * w + x) * c + k] = sum / 9;
        }
    }
}

// 2. 高通滤波：拉普拉斯锐化 (加权叠加)
__global__ void highpass_kernel(unsigned char* in, unsigned char* out, int w, int h, int c) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x > 0 && x < w - 1 && y > 0 && y < h - 1) {
        for (int k = 0; k < c; k++) {
            int center = in[(y * w + x) * c + k];
            int neighbors = in[((y-1)*w + x)*c + k] + in[((y+1)*w + x)*c + k] + 
                            in[(y*w + (x-1))*c + k] + in[(y*w + (x+1))*c + k];
            int laplacian = 4 * center - neighbors;
            int sharp = center + laplacian; 
            out[(y * w + x) * c + k] = (unsigned char)max(0, min(255, sharp));
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
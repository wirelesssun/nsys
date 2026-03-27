#ifndef KERNEL_H
#define KERNEL_H

#include <cuda_runtime.h>

// 导出给 main.cpp 调用的函数
void process_image_cuda(unsigned char* d_input, unsigned char* d_output_low, 
                        unsigned char* d_output_high, unsigned char* d_output_rotate,
                        int width, int height, int channels);

#endif
#include <iostream>
#include <opencv2/opencv.hpp>
#include "kernel.h"

int main() {
    cv::Mat img = cv::imread("../input.jpg", cv::IMREAD_COLOR);
    if (img.empty()) return -1;

    int w = img.cols;
    int h = img.rows;
    int c = img.channels();
    size_t size = w * h * c;

    unsigned char *d_in, *d_out_low, *d_out_high, *d_out_rotate;
    cudaMalloc(&d_in, size);
    cudaMalloc(&d_out_low, size);
    cudaMalloc(&d_out_high, size);
    cudaMalloc(&d_out_rotate, size); // 注意：旋转后宽高互换，size 相同

    cudaMemcpy(d_in, img.data, size, cudaMemcpyHostToDevice);

    process_image_cuda(d_in, d_out_low, d_out_high, d_out_rotate, w, h, c);

    cv::Mat res_low(h, w, CV_8UC3), res_high(h, w, CV_8UC3), res_rotate(w, h, CV_8UC3);
    cudaMemcpy(res_low.data, d_out_low, size, cudaMemcpyDeviceToHost);
    cudaMemcpy(res_high.data, d_out_high, size, cudaMemcpyDeviceToHost);
    cudaMemcpy(res_rotate.data, d_out_rotate, size, cudaMemcpyDeviceToHost);

    cv::imwrite("../lowpass.jpg", res_low);
    cv::imwrite("../highpass.jpg", res_high);
    cv::imwrite("../rotated.jpg", res_rotate);

    cudaFree(d_in); cudaFree(d_out_low); cudaFree(d_out_high); cudaFree(d_out_rotate);
    std::cout << "手动编写的 CUDA 核函数处理完成！" << std::endl;
    return 0;
}
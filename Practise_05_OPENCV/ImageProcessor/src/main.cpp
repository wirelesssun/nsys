#include <iostream>
#include <string>
#include <vector>
#include <opencv2/opencv.hpp>

int main() {
    // 1. 定义输入和输出路径
    // 假设在 build 目录下运行，使用相对路径指向项目根目录的文件
    std::string input_path  = "../input.jpg";
    std::string output_low  = "../output_lowpass_smooth.jpg";
    std::string output_high = "../output_highpass_sharpen.jpg";

    // 2. 读取彩色图像 (BGR 格式)
    cv::Mat color_image = cv::imread(input_path, cv::IMREAD_COLOR);

    // 检查图像是否读取成功
    if (color_image.empty()) {
        std::cerr << "错误：无法读取图像，请确认文件路径: " << input_path << std::endl;
        return -1;
    }

    std::cout << "彩色图像读取成功！" << std::endl;
    std::cout << "尺寸: " << color_image.cols << " x " << color_image.rows << std::endl;

    // ---------------------------------------------------------
    // 任务一：低通滤波 (Low-pass Filtering) - 平滑/模糊处理
    // ---------------------------------------------------------
    cv::Mat lowpass_image;
    // 使用高斯模糊作为低通滤波器
    // 参数：Size(7, 7) 是卷积核大小，3.0 是标准差 SigmaX。核越大、Sigma越大，越模糊。
    cv::GaussianBlur(color_image, lowpass_image, cv::Size(7, 7), 3.0);

    // 保存低通滤波结果
    if (cv::imwrite(output_low, lowpass_image)) {
        std::cout << ">> [低通滤波] 平滑图像已保存至: " << output_low << std::endl;
    } else {
        std::cerr << "错误：保存低通滤波图像失败。" << std::endl;
    }

    // ---------------------------------------------------------
    // 任务二：高通滤波 (High-pass Filtering) - 锐化处理
    // ---------------------------------------------------------
    // 经典方法：反掩蔽锐化 (Unsharp Masking)
    // 原理：锐化结果 = 原始图像 + (原始图像 - 低通图像) * 锐化强度
    
    cv::Mat highpass_image;
    double alpha = 1.5;  // 原始图像权重
    double beta  = -0.5; // 低通图像权重 (负值表示减去低通分量，即加上高通分量)
    double gamma = 0.0;  // 亮度偏移量

    // 使用 addWeighted 函数实现：dst = src1*alpha + src2*beta + gamma
    // 这里 src1 是原图，src2 是低通滤波后的图
    // 这实际上是一种获取图像高频细节并将其叠加回原图的方法
    cv::addWeighted(color_image, alpha, lowpass_image, beta, gamma, highpass_image);

    // 保存高通滤波（锐化）结果
    if (cv::imwrite(output_high, highpass_image)) {
        std::cout << ">> [高通滤波] 锐化图像已保存至: " << output_high << std::endl;
    } else {
        std::cerr << "错误：保存高通滤波图像失败。" << std::endl;
    }

    std::cout << "\n图像处理全部完成！" << std::endl;

    return 0;
}
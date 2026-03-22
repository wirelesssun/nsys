#include <iostream>
#include <string>
#include <opencv2/opencv.hpp>

int main() {
    // 文件路径配置
    std::string input_path    = "../input.jpg";
    std::string output_low     = "../output_lowpass_smooth.jpg";
    std::string output_high    = "../output_highpass_sharpen.jpg";
    std::string output_rotate  = "../output_rotated_90.jpg";

    // 1. 读取图像
    cv::Mat color_image = cv::imread(input_path, cv::IMREAD_COLOR);
    if (color_image.empty()) {
        std::cerr << "错误：无法读取图像 " << input_path << std::endl;
        return -1;
    }

    // 2. 低通滤波：高斯模糊 (平滑处理)
    cv::Mat lowpass_image;
    cv::GaussianBlur(color_image, lowpass_image, cv::Size(7, 7), 3.0);
    cv::imwrite(output_low, lowpass_image);

    // 3. 高通滤波：反掩蔽锐化 (增强边缘)
    cv::Mat highpass_image;
    cv::addWeighted(color_image, 1.5, lowpass_image, -0.5, 0.0, highpass_image);
    cv::imwrite(output_high, highpass_image);

    // 4. 新增功能：顺时针旋转 90 度
    cv::Mat rotated_image;
    // 参数说明：
    // ROTATE_90_CLOCKWISE: 顺时针 90 度
    // ROTATE_180: 旋转 180 度
    // ROTATE_90_COUNTERCLOCKWISE: 逆时针 90 度
    cv::rotate(color_image, rotated_image, cv::ROTATE_90_CLOCKWISE);
    cv::imwrite(output_rotate, rotated_image);

    std::cout << "--- OpenCV 图像处理任务完成 ---" << std::endl;
    std::cout << "1. 平滑图像已保存至: " << output_low << std::endl;
    std::cout << "2. 锐化图像已保存至: " << output_high << std::endl;
    std::cout << "3. 旋转图像已保存至: " << output_rotate << std::endl;

    return 0;
}
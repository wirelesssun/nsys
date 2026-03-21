#include <iostream>
#include <string>
#include <opencv2/opencv.hpp>

int main() {
    std::string input_path  = "../input.jpg";
    std::string output_low  = "../output_lowpass_smooth.jpg";
    std::string output_high = "../output_highpass_sharpen.jpg";

    cv::Mat color_image = cv::imread(input_path, cv::IMREAD_COLOR);
    if (color_image.empty()) {
        std::cerr << "错误：无法读取图像 " << input_path << std::endl;
        return -1;
    }

    // 低通滤波：高斯模糊
    cv::Mat lowpass_image;
    cv::GaussianBlur(color_image, lowpass_image, cv::Size(7, 7), 3.0);
    cv::imwrite(output_low, lowpass_image);

    // 高通滤波：反掩蔽锐化
    cv::Mat highpass_image;
    cv::addWeighted(color_image, 1.5, lowpass_image, -0.5, 0.0, highpass_image);
    cv::imwrite(output_high, highpass_image);

    std::cout << "本地编译的 OpenCV 处理完成！" << std::endl;
    return 0;
}
#include <iostream>
#include <vector>
#include <cmath>
#include <iomanip>
#include <fftw3.h>

int main() {
    // 1. 参数设置
    const int N = 1024;           // 1024点FFT
    const double fs = 8000.0;     // 采样频率 8000Hz
    double freq = 170.0;          // 正弦波频率（例如 A4 音符）
    
    // 2. 分配内存（使用 fftw_malloc 以确保 SIMD 指令集对齐）
    fftw_complex *in = (fftw_complex*) fftw_malloc(sizeof(fftw_complex) * N);
    fftw_complex *out = (fftw_complex*) fftw_malloc(sizeof(fftw_complex) * N);

    // 3. 生成输入正弦波信号
    // 信号公式: x(n) = sin(2 * pi * f * n / fs)
    for (int n = 0; n < N; ++n) {
        double time = (double)n / fs;
        in[n][0] = std::sin(2.0 * M_PI * freq * time); // 实部
        in[n][1] = 0.0;                                // 虚部
    }

    // 4. 创建执行计划 (FFTW_FORWARD 表示正向 FFT)
    // 对于 1024 点这样固定长度的多次运算，FFTW_MEASURE 会比 FFTW_ESTIMATE 更快，但初始化稍慢
    fftw_plan p = fftw_plan_dft_1d(N, in, out, FFTW_FORWARD, FFTW_ESTIMATE);

    // 5. 执行 FFT 计算
    fftw_execute(p);

    // 6. 输出部分结果进行验证
    std::cout << "--- FFTW3 1024点正弦波运算结果 ---" << std::endl;
    std::cout << "输入频率: " << freq << " Hz, 采样率: " << fs << " Hz" << std::endl;
    
    // 计算前 400 个频率分量的幅值 (Magnitude)
    std::cout << std::fixed << std::setprecision(2);
    std::cout << "前 400 个频点的幅值输出:" << std::endl;
    for (int i = 0; i < 400; ++i) {
        double magnitude = std::sqrt(out[i][0] * out[i][0] + out[i][1] * out[i][1]);
        double current_freq = i * fs / N;
        std::cout << "频点 " << i << " (" << current_freq << " Hz): " << magnitude << std::endl;
    }

    // 7. 资源释放
    fftw_destroy_plan(p);
    fftw_free(in);
    fftw_free(out);

    std::cout << "\nFFT 运算及资源释放完成！" << std::endl;

    return 0;
}
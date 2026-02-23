#include <iostream>
#include <vector>
#include <iomanip> // 用于格式化输出
#include "matrix_add.h"

int main() {
    const int N = 10;
    // 初始化：a 全为 1.1, b 全为 2.2，这样加起来有小数，方便观察结果
    std::vector<float> a(N, 1.1f), b(N, 2.2f), c(N, 0.0f);

    // 调用 CUDA 加法核函数
    launch_matrix_add(a.data(), b.data(), c.data(), N);

    std::cout << "=== Matrix Addition Results (N=" << N << ") ===" << std::endl;
    std::cout << std::left << std::setw(10) << "Index" 
              << std::setw(15) << "A + B" 
              << "Result (C)" << std::endl;
    std::cout << "------------------------------------------" << std::endl;

    // 遍历并显示每个元素
    for (int i = 0; i < N; ++i) {
        std::cout << "[" << i << "]:" << std::setw(6) << " " 
                  << a[i] << " + " << b[i] 
                  << "  =  " << std::fixed << std::setprecision(2) << c[i] 
                  << std::endl;
    }

    std::cout << "------------------------------------------" << std::endl;
    std::cout << "Computation Complete!" << std::endl;

    return 0;
}
#include <iostream>
#include <vector>
#include <chrono>
#include <iomanip>
#include "matmul.h"

void matmul_cpu(const float* A, const float* B, float* C) {
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            float sum = 0;
            for (int k = 0; k < N; ++k) sum += A[i * N + k] * B[k * N + j];
            C[i * N + j] = sum;
        }
    }
}

int main() {
    std::vector<float> A(N * N, 1.0f), B(N * N, 2.0f), C(N * N, 0);
    std::cout << std::fixed << std::setprecision(5) << ">> 测试规模: " << N << "x" << N << "\n";

    // 方案一
    auto s1 = std::chrono::high_resolution_clock::now();
    matmul_cpu(A.data(), B.data(), C.data());
    auto e1 = std::chrono::high_resolution_clock::now();
    std::cout << "方案一 (纯 CPU) 运行时间: " << std::chrono::duration<double, std::milli>(e1 - s1).count() << " ms\n";

    // 方案二
    float t2 = matmul_gpu_global(A.data(), B.data(), C.data());
    std::cout << "方案二 (GPU Global) Kernel 时间: " << t2 << " ms\n";

    // 方案三
    float t3 = matmul_gpu_shared(A.data(), B.data(), C.data());
    std::cout << "方案三 (GPU Shared) Kernel 时间: " << t3 << " ms\n";

    return 0;
}
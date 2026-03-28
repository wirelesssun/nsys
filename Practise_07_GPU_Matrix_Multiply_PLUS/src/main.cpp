#include <iostream>
#include <vector>
#include <chrono>
#include <iomanip>
#include "matmul.h"

void matmul_cpu(const float* A, const float* B, float* C) {
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j) {
            float sum = 0;
            for (int k = 0; k < N; ++k) sum += A[i * N + k] * B[k * N + j];
            C[i * N + j] = sum;
        }
}

int main() {
    std::vector<float> A(N * N, 1.5f), B(N * N, 2.0f), C(N * N, 0);

    std::cout << "==========================================================" << std::endl;
    std::cout << "  Matrix Multiplication Performance Benchmarking (" << N << "x" << N << ")" << std::endl;
    std::cout << "==========================================================" << std::endl;
    std::cout << std::left << std::setw(30) << "Implementation" << std::setw(15) << "Time (ms)" << "Status" << std::endl;
    std::cout << "----------------------------------------------------------" << std::endl;

    // 方案 1: CPU
    auto s = std::chrono::high_resolution_clock::now();
    matmul_cpu(A.data(), B.data(), C.data());
    auto e = std::chrono::high_resolution_clock::now();
    double cpu_time = std::chrono::duration<double, std::milli>(e - s).count();
    std::cout << std::left << std::setw(30) << "Scheme 1: Pure CPU" << std::fixed << std::setprecision(5) << std::setw(15) << cpu_time << "Done" << std::endl;

    // 方案 2-5: GPU
    std::cout << std::left << std::setw(30) << "Scheme 2: GPU Global Memory" << std::setw(15) << run_gpu_v2(A.data(), B.data(), C.data()) << "Done" << std::endl;
    std::cout << std::left << std::setw(30) << "Scheme 3: GPU Shared Memory" << std::setw(15) << run_gpu_v3(A.data(), B.data(), C.data()) << "Done" << std::endl;
    std::cout << std::left << std::setw(30) << "Scheme 4: GPU ILP (1x2 Tile)" << std::setw(15) << run_gpu_v4(A.data(), B.data(), C.data()) << "Done" << std::endl;
    std::cout << std::left << std::setw(30) << "Scheme 5: GPU ILP (1x4 Tile)" << std::setw(15) << run_gpu_v5(A.data(), B.data(), C.data()) << "Done" << std::endl;

    std::cout << "----------------------------------------------------------" << std::endl;
    std::cout << "Test completed successfully." << std::endl;

    return 0;
}
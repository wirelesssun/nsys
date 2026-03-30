#include <iostream>
#include <chrono>
#include <iomanip>
#include <algorithm>
#include <random>
#include "deinterleaver.h"

bool verify(const int8_t* ref, const int8_t* test, int size) {
    for (int i = 0; i < size; ++i) {
        if (ref[i] != test[i]) return false;
    }
    return true;
}

int main() {
    std::vector<int> Qm_list = {2, 4, 6, 8};
    std::vector<int8_t> h_in(E_SIZE), h_ref(E_SIZE), h_res2(E_SIZE), h_res3(E_SIZE);

    // 随机生成输入数据
    std::mt19937 gen(2026);
    std::uniform_int_distribution<> dis(-128, 127);
    std::generate(h_in.begin(), h_in.end(), [&]() { return (int8_t)dis(gen); });

    std::cout << "\n[5G NR PUSCH De-Interleaver Benchmark | E=" << E_SIZE << "]" << std::endl;
    std::cout << std::string(90, '=') << std::endl;
    printf("%-10s | %-4s | %-15s | %-15s | %-10s\n", "Scheme", "Qm", "Avg Time (ms)", "Total Iters", "Status");
    std::cout << std::string(90, '-') << std::endl;

    for (int Qm : Qm_list) {
        // 方案一：CPU
        auto start = std::chrono::high_resolution_clock::now();
        for (int i = 0; i < ITERS; ++i) cpu_deinterleave_v1(h_in.data(), h_ref.data(), Qm);
        auto end = std::chrono::high_resolution_clock::now();
        double cpu_ms = std::chrono::duration<double, std::milli>(end - start).count() / ITERS;
        printf("%-10s | %-4d | %-15.6f | %-15d | %-10s\n", "1:CPU", Qm, cpu_ms, ITERS, "PASS");

        // 方案二：GPU Basic
        float gpu_v2_ms = 0;
        gpu_deinterleave_v2(h_in.data(), h_res2.data(), Qm, gpu_v2_ms);
        bool v2_ok = verify(h_ref.data(), h_res2.data(), E_SIZE);
        printf("%-10s | %-4d | %-15.6f | %-15d | %-10s\n", "2:GPU-B", Qm, gpu_v2_ms, ITERS, v2_ok ? "PASS" : "FAIL");

        // 方案三：GPU Shared
        float gpu_v3_ms = 0;
        gpu_deinterleave_v3(h_in.data(), h_res3.data(), Qm, gpu_v3_ms);
        bool v3_ok = verify(h_ref.data(), h_res3.data(), E_SIZE);
        printf("%-10s | %-4d | %-15.6f | %-15d | %-10s\n", "3:GPU-S", Qm, gpu_v3_ms, ITERS, v3_ok ? "PASS" : "FAIL");
        
        std::cout << std::string(90, '-') << std::endl;
    }
    return 0;
}
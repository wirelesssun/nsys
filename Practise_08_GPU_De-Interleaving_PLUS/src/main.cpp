#include <iostream>
#include <iomanip>
#include <random>
#include <algorithm>
#include <string>
#include "deinterleaver.h"

bool check_result(const int8_t* ref, const int8_t* test, int size) {
    for (int i = 0; i < size; ++i) if (ref[i] != test[i]) return false;
    return true;
}

int main() {
    std::vector<int> Qm_list = {2, 4, 6, 8};
    std::vector<int8_t> h_in(E_SIZE), h_ref(E_SIZE), h_out(E_SIZE);

    // 随机数据生成
    std::mt19937 gen(2026);
    std::uniform_int_distribution<> dis(-128, 127);
    std::generate(h_in.begin(), h_in.end(), [&]() { return (int8_t)dis(gen); });

    std::cout << "\n[ 5G NR PUSCH De-Interleaver Bench | E=" << E_SIZE << " | Iterations=" << ITERS << " ]\n";
    std::cout << std::string(110, '=') << "\n";
    printf("%-15s | %-5s | %-25s | %-15s | %-10s\n", "Scheme", "Qm", "Avg Kernel Time (ms)", "Total Samples", "Verify");
    std::cout << std::string(110, '-') << "\n";

    for (int Qm : Qm_list) {
        // 方案一 (CPU Reference)
        double t1 = cpu_v1_run(h_in.data(), h_ref.data(), Qm);
        printf("%-15s | %-5d | %-25.7f | %-15d | %-10s\n", "1: Pure CPU", Qm, t1, ITERS, "PASS");

        // 方案二至七 (GPU Benchmarks)
        for (int m = 2; m <= 7; ++m) {
            double tm = gpu_bench_run(m, h_in.data(), h_out.data(), Qm);
            bool ok = check_result(h_ref.data(), h_out.data(), E_SIZE);
            std::string label = std::to_string(m) + ": GPU-V" + std::to_string(m);
            printf("%-15s | %-5d | %-25.7f | %-15d | %-10s\n", label.c_str(), Qm, tm, ITERS, ok ? "PASS" : "FAIL");
        }
        std::cout << std::string(110, '-') << "\n";
    }

    return 0;
}
#include "deinterleaver.h"
#include <chrono>

double cpu_v1_run(const int8_t* in, int8_t* out, int Qm) {
    int R = E_SIZE / Qm;
    auto start = std::chrono::high_resolution_clock::now();
    
    for (int it = 0; it < ITERS; ++it) {
        for (int r = 0; r < R; ++r) {
            for (int c = 0; c < Qm; ++c) {
                // 3GPP 标准：输入按列写入，输出按行读取
                out[r * Qm + c] = in[c * R + r];
            }
        }
    }
    
    auto end = std::chrono::high_resolution_clock::now();
    return std::chrono::duration<double, std::milli>(end - start).count() / ITERS;
}
#include "deinterleaver.h"

void cpu_deinterleave_v1(const int8_t* in, int8_t* out, int Qm) {
    int R = E_SIZE / Qm;
    // 3GPP PUSCH De-interleaving 逻辑：将输入按列填入矩阵，按行读出
    // 即：in[c*R + r] 映射到 out[r*Qm + c]
    for (int r = 0; r < R; ++r) {
        for (int c = 0; c < Qm; ++c) {
            out[r * Qm + c] = in[c * R + r];
        }
    }
}
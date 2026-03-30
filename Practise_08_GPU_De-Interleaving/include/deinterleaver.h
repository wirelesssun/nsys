#pragma once
#include <stdint.h>
#include <vector>

const int E_SIZE = 6144;
const int ITERS  = 1024;

// 方案接口
void cpu_deinterleave_v1(const int8_t* in, int8_t* out, int Qm);
void gpu_deinterleave_v2(const int8_t* h_in, int8_t* h_out, int Qm, float& avg_ms);
void gpu_deinterleave_v3(const int8_t* h_in, int8_t* h_out, int Qm, float& avg_ms);
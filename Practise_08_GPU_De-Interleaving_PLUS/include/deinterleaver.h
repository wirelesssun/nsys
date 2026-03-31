#pragma once
#include <stdint.h>
#include <vector>

const int E_SIZE = 6144;
const int ITERS  = 4096;

// 统一接口：输入/输出指针，调制阶数 Qm，返回平均执行时间(ms)
double cpu_v1_run(const int8_t* in, int8_t* out, int Qm);
// GPU 方案入口，mode 对应方案编号 2-6
double gpu_bench_run(int mode, const int8_t* h_in, int8_t* h_out, int Qm);
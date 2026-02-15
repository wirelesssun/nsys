#include <iostream>
#include <cuda_runtime.h>
#include <cmath>

// 通用幂次内核
__global__ void powerKernel(float* input, float* output, float exp, int n) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        output[idx] = powf(input[idx], exp);
    }
}

int main() {
    const int N = 1024;
    const int size = N * sizeof(float);
    
    // 主机和设备内存分配
    float *h_in = (float*)malloc(size), *h_out = (float*)malloc(size);
    float *d_data0, *d_data1, *d_data2, *d_data3;
    
    for(int i = 0; i < N; i++) h_in[i] = 1.1f; // 初始值

    cudaMalloc(&d_data0, size); // 原始输入
    cudaMalloc(&d_data1, size); // 2次方结果
    cudaMalloc(&d_data2, size); // 3次方结果 (2^3 = 6次方)
    cudaMalloc(&d_data3, size); // 4次方结果 (6^4 = 24次方)

    cudaMemcpy(d_data0, h_in, size, cudaMemcpyHostToDevice);

    // --- 1. CUDA Graph 创建过程 ---
    cudaGraph_t graph;
    cudaGraphCreate(&graph, 0);

    // 节点配置模板
    cudaKernelNodeParams nodeParams = {0};
    nodeParams.gridDim = dim3((N + 255) / 256);
    nodeParams.blockDim = dim3(256);

    // 任务1: 2次方 (d_data0 -> d_data1)
    float exp2 = 2.0f;
    void* args1[] = {&d_data0, &d_data1, &exp2, (void*)&N};
    nodeParams.func = (void*)powerKernel;
    nodeParams.kernelParams = args1;
    cudaGraphNode_t node1;
    cudaGraphAddKernelNode(&node1, graph, NULL, 0, &nodeParams);

    // 任务2: 3次方 (d_data1 -> d_data2)
    float exp3 = 3.0f;
    void* args2[] = {&d_data1, &d_data2, &exp3, (void*)&N};
    nodeParams.kernelParams = args2;
    cudaGraphNode_t node2;
    // 设置依赖：node2 必须在 node1 之后
    cudaGraphAddKernelNode(&node2, graph, &node1, 1, &nodeParams);

    // 任务3: 4次方 (d_data2 -> d_data3)
    float exp4 = 4.0f;
    void* args3[] = {&d_data2, &d_data3, &exp4, (void*)&N};
    nodeParams.kernelParams = args3;
    cudaGraphNode_t node3;
    // 设置依赖：node3 必须在 node2 之后
    cudaGraphAddKernelNode(&node3, graph, &node2, 1, &nodeParams);

    // --- 2. 实例化 (Instantiation) ---
    // 将图编译为可执行形式，预付所有启动开销
    cudaGraphExec_t instance;
    cudaGraphInstantiate(&instance, graph, NULL, NULL, 0);

    // --- 3. 执行 (Launch) ---
    // 在实际生产中，这一步通常在循环中执行多次以体现效率提升
    std::cout << "Launching CUDA Graph..." << std::endl;
    cudaGraphLaunch(instance, 0); 
    cudaDeviceSynchronize();

    // 拷贝最终结果
    cudaMemcpy(h_out, d_data3, size, cudaMemcpyDeviceToHost);

    // 验证：1.1^(2*3*4) = 1.1^24
    std::cout << "Input[0]: " << h_in[0] << " -> Final Output[0]: " << h_out[0] << std::endl;
    std::cout << "Expected: " << powf(1.1f, 24.0f) << std::endl;

    // 清理
    cudaGraphExecDestroy(instance);
    cudaGraphDestroy(graph);
    cudaFree(d_data0); cudaFree(d_data1); cudaFree(d_data2); cudaFree(d_data3);
    free(h_in); free(h_out);

    return 0;
}
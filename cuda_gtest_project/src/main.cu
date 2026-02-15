#include <iostream>
#include "vector_ops.h"

int main() {
    const int n = 3;
    float h_a[n] = {10.0f, 20.0f, 30.0f};
    float h_b[n] = {1.5f, 2.5f, 3.5f};
    float h_c[n];

    std::cout << "Running Vector Addition..." << std::endl;
    runVectorAdd(h_a, h_b, h_c, n);

    for (int i = 0; i < n; i++) {
        std::cout << h_a[i] << " + " << h_b[i] << " = " << h_c[i] << std::endl;
    }
    return 0;
}
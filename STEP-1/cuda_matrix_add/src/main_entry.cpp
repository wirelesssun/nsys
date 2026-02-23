#include <iostream>
#include <vector>
#include "matrix_add.h"

int main() {
    const int N = 10;
    std::vector<float> a(N, 1.0f), b(N, 2.0f), c(N, 0.0f);

    launch_matrix_add(a.data(), b.data(), c.data(), N);

    std::cout << "Result of 1.0 + 2.0: " << c[0] << std::endl;
    return 0;
}
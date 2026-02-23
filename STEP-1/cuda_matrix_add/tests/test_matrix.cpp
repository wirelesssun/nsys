#include <gtest/gtest.h>
#include "matrix_add.h"
#include <vector>

TEST(MatrixAddTest, SimpleAddition) {
    const int N = 1024;
    std::vector<float> h_A(N, 5.0f);
    std::vector<float> h_B(N, 3.0f);
    std::vector<float> h_C(N, 0.0f);

    launch_matrix_add(h_A.data(), h_B.data(), h_C.data(), N);

    for (int i = 0; i < N; ++i) {
        EXPECT_FLOAT_EQ(h_C[i], 8.0f);
    }
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
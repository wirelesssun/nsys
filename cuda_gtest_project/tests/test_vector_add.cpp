#include <gtest/gtest.h>
#include "vector_ops.h"

// 测试用例：验证 3 个元素的加法
TEST(VectorAddTest, HandlesPositiveNumbers) {
    const int n = 3;
    float h_a[n] = {10.0f, 20.0f, 30.0f};
    float h_b[n] = {1.5f, 2.5f, 3.5f};
    float h_c[n] = {0.0f, 0.0f, 0.0f};

    runVectorAdd(h_a, h_b, h_c, n);

    EXPECT_FLOAT_EQ(h_c[0], 11.5f);
    EXPECT_FLOAT_EQ(h_c[1], 22.5f);
    EXPECT_FLOAT_EQ(h_c[2], 33.5f);
}

// 测试用例：验证全零
TEST(VectorAddTest, HandlesZeros) {
    const int n = 3;
    float h_a[n] = {0.0f, 0.0f, 0.0f};
    float h_b[n] = {0.0f, 0.0f, 0.0f};
    float h_c[n];

    runVectorAdd(h_a, h_b, h_c, n);

    for(int i = 0; i < n; i++) {
        EXPECT_EQ(h_c[i], 0.0f);
    }
}

TEST(VectorAddTest, HandlesZeros1) {
    const int n = 3;
    float h_a[n] = {0.0f, 0.0f, 0.0f};
    float h_b[n] = {0.1f, 0.1f, 0.1f};
    float h_c[n];

    runVectorAdd(h_a, h_b, h_c, n);

    for(int i = 0; i < n; i++) {
        EXPECT_EQ(h_c[i], 0.1f);
    }
}
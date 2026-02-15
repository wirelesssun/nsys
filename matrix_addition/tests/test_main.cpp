#include <gtest/gtest.h>
#include <vector>

// 声明外部定义的 CUDA 辅助函数
void runMatrixAdd(const std::vector<float>& h_A, const std::vector<float>& h_B, std::vector<float>& h_C, int rows, int cols);

TEST(MatrixAdditionTest, CorrectSum) {
    int rows = 2;
    int cols = 3;
    std::vector<float> h_A = {1.0f, 2.0f, 3.0f, 4.0f, 5.0f, 6.0f};
    std::vector<float> h_B = {10.0f, 20.0f, 30.0f, 40.0f, 50.0f, 60.0f};
    std::vector<float> h_C(rows * cols, 0.0f);

    runMatrixAdd(h_A, h_B, h_C, rows, cols);

    // 预期结果
    std::vector<float> expected = {11.0f, 22.0f, 33.0f, 44.0f, 55.0f, 66.0f};

    for (int i = 0; i < rows * cols; ++i) {
        EXPECT_FLOAT_EQ(h_C[i], expected[i]);
    }
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
#include <iostream>
#include <TestAdd.h> // 自动从 find_package 获取路径

int main() {
    float val1 = 12.5f;
    float val2 = 7.5f;
    
    // 调用命名空间下的函数
    float result = Math::add(val1, val2);
    
    std::cout << "Math::add(" << val1 << ", " << val2 << ") = " << result << std::endl;
    return 0;
}
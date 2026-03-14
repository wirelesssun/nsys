#include <iostream>
#include <vector>
#include "sort_algorithms.h"

void printArray(const std::string& name, const std::vector<int>& arr) {
    std::cout << name << ": ";
    for (int num : arr) std::cout << num << " ";
    std::cout << std::endl;
}

int main() {
    std::vector<int> data1 = {64, 34, 25, 12, 22, 11, 90};
    std::vector<int> data2 = {10, 80, 30, 90, 40, 50, 70};

    std::cout << "--- 冒泡排序测试 ---" << std::endl;
    printArray("排序前", data1);
    bubbleSort(data1);
    printArray("排序后", data1);

    std::cout << "\n--- 快速排序测试 ---" << std::endl;
    printArray("排序前", data2);
    quickSort(data2, 0, data2.size() - 1);
    printArray("排序后", data2);

    return 0;
}
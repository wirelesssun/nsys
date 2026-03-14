#ifndef SORT_ALGORITHMS_H
#define SORT_ALGORITHMS_H

#include <vector>

// 冒泡排序
void bubbleSort(std::vector<int>& arr);

// 快速排序 (递归实现)
void quickSort(std::vector<int>& arr, int low, int high);

#endif
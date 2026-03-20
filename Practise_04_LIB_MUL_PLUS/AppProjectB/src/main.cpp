#include <iostream>
#include <MathOps.h>

int main() {
    float a = 10.0f, b = 5.0f;
    std::cout << "--- Math Operations Test ---" << std::endl;
    std::cout << "Add:      " << Math::add(a, b) << std::endl;
    std::cout << "Sub:      " << Math::subtract(a, b) << std::endl;
    std::cout << "Multiply: " << Math::multiply(a, b) << std::endl;
    std::cout << "Divide:   " << Math::divide(a, b) << std::endl;
    return 0;
}
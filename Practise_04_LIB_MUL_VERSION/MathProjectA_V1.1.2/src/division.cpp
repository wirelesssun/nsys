#include "MathOps.h"
#include <stdexcept>
namespace Math { 
    float divide(float a, float b) { 
        if (b == 0.0f) return 0.0f; // 简单处理，生产环境建议抛异常
        return a / b + 0.02f; 
    } 
}
#include <iostream>
#include <vector>
#include <string>
#include <cstring>
#include <openssl/evp.h>

// 辅助函数：处理 OpenSSL 错误
void handleErrors() {
    std::cerr << "加密/解密操作失败！" << std::endl;
    exit(1);
}

// 核心处理函数（AES-CTR-128 加解密逻辑一致）
int aes_ctr_128_process(const unsigned char* input, int input_len, 
                        const unsigned char* key, const unsigned char* iv, 
                        unsigned char* output) {
    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    if (!ctx) handleErrors();

    // 初始化算法：AES-128-CTR
    if (1 != EVP_CipherInit_ex(ctx, EVP_aes_128_ctr(), NULL, key, iv, 1)) // 1 为加密/加解密通用
        handleErrors();

    int len, total_len;
    if (1 != EVP_CipherUpdate(ctx, output, &len, input, input_len))
        handleErrors();
    total_len = len;

    if (1 != EVP_CipherFinal_ex(ctx, output + len, &len))
        handleErrors();
    total_len += len;

    EVP_CIPHER_CTX_free(ctx);
    return total_len;
}

int main() {
    // 1. 初始化数据
    std::string original_text = "Hello, Sun Libo! This is a test for AES-CTR-128.";
    unsigned char key[16] = {0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef, 0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef};
    unsigned char iv[16]  = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f};
    std::vector<unsigned char> ciphertext(original_text.size());
    std::vector<unsigned char> decrypted_text(original_text.size());

    std::cout << "原始明文: " << original_text << std::endl;

    // 2. 执行加密
    aes_ctr_128_process((unsigned char*)original_text.c_str(), original_text.length(), key, iv, ciphertext.data());
    std::cout << "加密成功。" << std::endl;

    // 3. 执行解密 (CTR 模式下加解密逻辑是对称的，直接使用相同的函数)
    aes_ctr_128_process(ciphertext.data(), ciphertext.size(), key, iv, decrypted_text.data());
    std::cout << "解密成功。" << std::endl;

    // 4. 对比验证
    std::string result((char*)decrypted_text.data(), decrypted_text.size());
    std::cout << "解密结果: " << result << std::endl;

    if (original_text == result) {
        std::cout << "\n[验证通过]：解密后的明文与原始明文完全一致！" << std::endl;
    } else {
        std::cout << "\n[验证失败]：数据不匹配。" << std::endl;
    }

    return 0;
}
#include <iostream>
#include <fstream>
#include <vector>
#include <complex>
#include <random>
#include <cmath>
#include <string>
#include <algorithm>
#include <cstring>
#include <getopt.h>
#include <fftw3.h>

// 调制方式枚举，顺序固定：BPSK, QPSK, 2ASK, 4ASK
enum class Modulation {
    BPSK,
    QPSK,
    ASK2,
    ASK4
};

// 全局参数
struct Parameters {
    int bitmap = 0b1111;            // 每一位对应一种调制，bit0=BPSK, bit1=QPSK, bit2=2ASK, bit3=4ASK
    int numSymbols = 1000;          // 每个SNR下每种调制传输的OFDM符号数
    double snrSingle = -100.0;      // 若指定单个SNR，则使用，否则为-100表示未指定
    std::string outputFile = "ber_results.csv";
    bool help = false;
};

// 解析命令行参数
Parameters parseArgs(int argc, char* argv[]) {
    Parameters params;
    static struct option long_options[] = {
        {"bitmap",     required_argument, 0, 'b'},
        {"snr",        required_argument, 0, 's'},
        {"symbols",    required_argument, 0, 'n'},
        {"output",     required_argument, 0, 'o'},
        {"help",       no_argument,       0, 'h'},
        {0, 0, 0, 0}
    };
    int c;
    while ((c = getopt_long(argc, argv, "b:s:n:o:h", long_options, nullptr)) != -1) {
        switch (c) {
            case 'b': {
                int val = std::stoi(optarg);
                if (val < 0 || val > 15) {
                    std::cerr << "Bitmap must be between 0 and 15.\n";
                    exit(1);
                }
                params.bitmap = val;
                break;
            }
            case 's':
                params.snrSingle = std::stod(optarg);
                break;
            case 'n':
                params.numSymbols = std::stoi(optarg);
                if (params.numSymbols <= 0) params.numSymbols = 1000;
                break;
            case 'o':
                params.outputFile = optarg;
                break;
            case 'h':
                params.help = true;
                break;
            default:
                std::cerr << "Unknown option.\n";
                params.help = true;
                break;
        }
    }
    return params;
}

// 打印帮助信息
void printHelp(const char* prog) {
    std::cout << "Usage: " << prog << " [options]\n"
              << "Options:\n"
              << "  -b, --bitmap <0-15>     4-bit bitmap: bit0=BPSK, bit1=QPSK, bit2=2ASK, bit3=4ASK (default 15)\n"
              << "  -s, --snr <dB>          Run a single SNR value (dB). If not given, sweep from -5 to 20 dB step 1.\n"
              << "  -n, --symbols <num>     Number of OFDM symbols per modulation per SNR (default 1000)\n"
              << "  -o, --output <file>     Output CSV file name (default ber_results.csv)\n"
              << "  -h, --help              Show this help\n";
}

// 返回每符号比特数
int bitsPerSymbol(Modulation mod) {
    switch (mod) {
        case Modulation::BPSK: return 1;
        case Modulation::QPSK: return 2;
        case Modulation::ASK2: return 1;
        case Modulation::ASK4: return 2;
    }
    return 0;
}

// 调制映射：比特 -> 复数符号 (归一化平均功率为1)
std::vector<std::complex<double>> modulate(const std::vector<uint8_t>& bits, Modulation mod) {
    int bps = bitsPerSymbol(mod);
    int numSym = bits.size() / bps;
    std::vector<std::complex<double>> symbols;
    symbols.reserve(numSym);
    for (int i = 0; i < numSym; ++i) {
        int idx = i * bps;
        int symbol = 0;
        for (int j = 0; j < bps; ++j) {
            symbol = (symbol << 1) | bits[idx + j];
        }
        switch (mod) {
            case Modulation::BPSK: {
                double val = (symbol == 0) ? -1.0 : 1.0;
                symbols.emplace_back(val, 0.0);
                break;
            }
            case Modulation::QPSK: {
                const double invSqrt2 = 1.0 / std::sqrt(2.0);
                double realPart, imagPart;
                switch (symbol) {
                    case 0: realPart = 1.0; imagPart = 1.0; break;  // 00
                    case 1: realPart = 1.0; imagPart = -1.0; break; // 01
                    case 2: realPart = -1.0; imagPart = 1.0; break; // 10
                    case 3: realPart = -1.0; imagPart = -1.0; break;// 11
                    default: realPart = 0.0; imagPart = 0.0;
                }
                symbols.emplace_back(realPart * invSqrt2, imagPart * invSqrt2);
                break;
            }
            case Modulation::ASK2: {
                double val = (symbol == 0) ? 0.0 : std::sqrt(2.0);
                symbols.emplace_back(val, 0.0);
                break;
            }
            case Modulation::ASK4: {
                const double a = 1.0 / std::sqrt(5.0);
                double val;
                switch (symbol) {
                    case 0: val = -3.0 * a; break;
                    case 1: val = -1.0 * a; break;
                    case 3: val =  1.0 * a; break;
                    case 2: val =  3.0 * a; break;
                    default: val = 0.0;
                }
                symbols.emplace_back(val, 0.0);
                break;
            }
        }
    }
    return symbols;
}

// 解调：复数符号 -> 比特 (硬判决)
std::vector<uint8_t> demodulate(const std::vector<std::complex<double>>& symbols, Modulation mod) {
    int bps = bitsPerSymbol(mod);
    std::vector<uint8_t> bits;
    bits.reserve(symbols.size() * bps);
    for (const auto& sym : symbols) {
        switch (mod) {
            case Modulation::BPSK: {
                bits.push_back(sym.real() > 0.0 ? 1 : 0);
                break;
            }
            case Modulation::QPSK: {
                int bit0 = (sym.real() > 0.0) ? 0 : 1;
                int bit1 = (sym.imag() > 0.0) ? 0 : 1;
                bits.push_back(bit0);
                bits.push_back(bit1);
                break;
            }
            case Modulation::ASK2: {
                bits.push_back(sym.real() > (std::sqrt(2.0) / 2.0) ? 1 : 0);
                break;
            }
            case Modulation::ASK4: {
                const double a = 1.0 / std::sqrt(5.0);
                double r = sym.real();
                int symbol;
                if (r < -2.0 * a) symbol = 0;
                else if (r < 0.0) symbol = 1;
                else if (r < 2.0 * a) symbol = 3;
                else symbol = 2;
                bits.push_back((symbol >> 1) & 1);
                bits.push_back(symbol & 1);
                break;
            }
        }
    }
    return bits;
}

// 计算两个比特向量的错误比特数
int countBitErrors(const std::vector<uint8_t>& txBits, const std::vector<uint8_t>& rxBits) {
    int errors = 0;
    for (size_t i = 0; i < txBits.size(); ++i) {
        if (txBits[i] != rxBits[i]) errors++;
    }
    return errors;
}

int main(int argc, char* argv[]) {
    // 解析参数
    Parameters params = parseArgs(argc, argv);
    if (params.help) {
        printHelp(argv[0]);
        return 0;
    }

    if (params.bitmap == 0) {
        std::cerr << "Bitmap is 0, no modulation enabled. Exiting.\n";
        return 1;
    }

    // OFDM 固定参数
    const int FFT_SIZE = 64;
    const int CP_LEN = 32;
    const int USED_SUBCARRIERS[] = {4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,
                                    36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59};
    const int NUM_USED = sizeof(USED_SUBCARRIERS) / sizeof(int);

    // 确定哪些是DM-RS (索引能被4整除)
    std::vector<bool> isDMRS(FFT_SIZE, false);
    for (int idx : USED_SUBCARRIERS) {
        if (idx % 4 == 0) isDMRS[idx] = true;
    }

    // 数据子载波数量
    int numDataSubcarriers = 0;
    for (int idx : USED_SUBCARRIERS) {
        if (!isDMRS[idx]) numDataSubcarriers++;
    }

    // 所有调制方式（顺序固定）
    const std::vector<Modulation> allMods = {
        Modulation::BPSK,
        Modulation::QPSK,
        Modulation::ASK2,
        Modulation::ASK4
    };
    const std::vector<std::string> modNames = {"BPSK", "QPSK", "2ASK", "4ASK"};

    // 确定哪些调制使能
    std::vector<bool> enabled(allMods.size(), false);
    for (size_t i = 0; i < allMods.size(); ++i) {
        if (params.bitmap & (1 << i)) enabled[i] = true;
    }

    // 准备随机数生成器（用于所有仿真）
    std::random_device rd;
    std::mt19937 rng(rd());
    std::uniform_int_distribution<int> bitDist(0, 1);

    // 准备FFTW计划（复用）
    std::vector<std::complex<double>> in(FFT_SIZE), out(FFT_SIZE);
    fftw_plan plan_ifft = fftw_plan_dft_1d(FFT_SIZE,
                                           reinterpret_cast<fftw_complex*>(in.data()),
                                           reinterpret_cast<fftw_complex*>(out.data()),
                                           FFTW_BACKWARD,
                                           FFTW_ESTIMATE);
    fftw_plan plan_fft = fftw_plan_dft_1d(FFT_SIZE,
                                          reinterpret_cast<fftw_complex*>(in.data()),
                                          reinterpret_cast<fftw_complex*>(out.data()),
                                          FFTW_FORWARD,
                                          FFTW_ESTIMATE);

    // 定义SNR范围
    std::vector<double> snrList;
    if (params.snrSingle > -100.0) {
        snrList.push_back(params.snrSingle);
    } else {
        for (double snr = -5.0; snr <= 20.0; snr += 1.0) {
            snrList.push_back(snr);
        }
    }

    // 打开CSV文件输出
    std::ofstream csv(params.outputFile);
    if (!csv.is_open()) {
        std::cerr << "Cannot open output file: " << params.outputFile << std::endl;
        return 1;
    }

    // 写入CSV标题
    csv << "SNR_dB";
    for (const auto& name : modNames) {
        csv << "," << name;
    }
    csv << "\n";

    // 仿真lambda：传入调制方式、信噪比、符号数，返回BER
    auto runSimulation = [&](Modulation mod, double snr_dB, int numSymbols) -> double {
        int bps = bitsPerSymbol(mod);
        int bitsPerSymbolData = numDataSubcarriers * bps;

        double snr_lin = std::pow(10.0, snr_dB / 10.0);
        double sigma = std::sqrt(1.0 / (2.0 * snr_lin));
        std::normal_distribution<double> noiseDist(0.0, sigma);

        long long totalBits = 0;
        long long errorBits = 0;

        for (int symIdx = 0; symIdx < numSymbols; ++symIdx) {
            // 生成数据比特
            std::vector<uint8_t> txBits(bitsPerSymbolData);
            for (int i = 0; i < bitsPerSymbolData; ++i) {
                txBits[i] = bitDist(rng);
            }

            // 调制
            std::vector<std::complex<double>> dataSymbols = modulate(txBits, mod);

            // 构建频域向量
            std::vector<std::complex<double>> freq(FFT_SIZE, std::complex<double>(0.0, 0.0));
            int dataIdx = 0;
            for (int idx : USED_SUBCARRIERS) {
                if (isDMRS[idx]) {
                    freq[idx] = std::complex<double>(1.0, 0.0);
                } else {
                    freq[idx] = dataSymbols[dataIdx++];
                }
            }

            // IFFT
            std::copy(freq.begin(), freq.end(), in.begin());
            fftw_execute(plan_ifft);
            for (int i = 0; i < FFT_SIZE; ++i) {
                out[i] /= std::sqrt(static_cast<double>(FFT_SIZE));
            }

            // 添加CP
            std::vector<std::complex<double>> txTime(FFT_SIZE + CP_LEN);
            std::copy(out.begin() + FFT_SIZE - CP_LEN, out.end(), txTime.begin());
            std::copy(out.begin(), out.end(), txTime.begin() + CP_LEN);

            // AWGN
            std::vector<std::complex<double>> rxTime(txTime.size());
            for (size_t i = 0; i < txTime.size(); ++i) {
                double noiseReal = noiseDist(rng);
                double noiseImag = noiseDist(rng);
                rxTime[i] = txTime[i] + std::complex<double>(noiseReal, noiseImag);
            }

            // 去除CP
            std::vector<std::complex<double>> rxNoCP(FFT_SIZE);
            std::copy(rxTime.begin() + CP_LEN, rxTime.end(), rxNoCP.begin());

            // FFT
            std::copy(rxNoCP.begin(), rxNoCP.end(), in.begin());
            fftw_execute(plan_fft);
            for (int i = 0; i < FFT_SIZE; ++i) {
                out[i] /= std::sqrt(static_cast<double>(FFT_SIZE));
            }

            // 提取数据子载波
            std::vector<std::complex<double>> rxDataSymbols;
            rxDataSymbols.reserve(numDataSubcarriers);
            dataIdx = 0;
            for (int idx : USED_SUBCARRIERS) {
                if (!isDMRS[idx]) {
                    rxDataSymbols.push_back(out[idx]);
                    dataIdx++;
                }
            }

            // 解调
            std::vector<uint8_t> rxBits = demodulate(rxDataSymbols, mod);

            // 统计错误
            errorBits += countBitErrors(txBits, rxBits);
            totalBits += txBits.size();
        }

        return (totalBits > 0) ? static_cast<double>(errorBits) / totalBits : 0.0;
    };

    // 主循环：每个SNR
    for (double snr_dB : snrList) {
        csv << snr_dB;
        for (size_t i = 0; i < allMods.size(); ++i) {
            if (enabled[i]) {
                double ber = runSimulation(allMods[i], snr_dB, params.numSymbols);
                csv << "," << ber;
                std::cout << "SNR=" << snr_dB << "dB, " << modNames[i] << " BER=" << ber << std::endl;
            } else {
                csv << ",-1";
            }
        }
        csv << "\n";
    }

    csv.close();

    // 清理FFTW
    fftw_destroy_plan(plan_ifft);
    fftw_destroy_plan(plan_fft);
    fftw_cleanup();

    std::cout << "Results saved to " << params.outputFile << std::endl;
    return 0;
}
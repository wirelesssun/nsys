ubuntu@VM-0-2-ubuntu:~$ nvidia-smi 
Mon Feb 23 19:01:01 2026       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 570.158.01             Driver Version: 570.158.01     CUDA Version: 12.8     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  Tesla T4                       On  |   00000000:00:08.0 Off |                  Off |
| N/A   31C    P8              8W /   70W |       0MiB /  16384MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|  No running processes found                                                             |
+-----------------------------------------------------------------------------------------+

1. 安装 CUDA Toolkit (官方推荐方式)

# 1. 下载并安装 NVIDIA 仓库密钥
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb

# 2. 更新软件包列表
sudo apt update

# 3. 安装 CUDA Toolkit 12.8 (与你的驱动匹配)
sudo apt -y install cuda-toolkit-12-8
(注：如果你的 Ubuntu 版本不是 22.04，请根据实际情况替换第一步链接中的 ubuntu2204，例如 ubuntu2004 或 ubuntu2404。如果不确定，运行 lsb_release -a 查看)

2. 配置环境变量 (至关重要)
安装完成后，系统默认还是找不到 nvcc。你需要手动把路径加到你的 Shell 配置文件中：

打开配置文件：
Bash
vim ~/.bashrc
在文件最末尾添加以下三行：

Bash
export PATH=/usr/local/cuda-12.8/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64:$LD_LIBRARY_PATH
export CUDA_HOME=/usr/local/cuda-12.8
保存并退出：按 Ctrl + O 然后 Enter 保存，按 Ctrl + X 退出。

激活配置：

Bash
source ~/.bashrc

3. 验证安装
现在再次检查 nvcc：

Bash
nvcc --version
预期输出： 看到 Cuda compilation tools, release 12.8, V12.8.x。
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2025 NVIDIA Corporation
Built on Fri_Feb_21_20:23:50_PST_2025
Cuda compilation tools, release 12.8, V12.8.93
Build cuda_12.8.r12.8/compiler.35583870_0

sudo apt install tree
sudo apt install cmake
cmake --version

cmake version 3.22.1
CMake suite maintained and supported by Kitware (kitware.com/cmake).


Gemini said
既然你的系统是 Ubuntu 22.04 LTS，安装不带 GUI 的 Nsight Systems CLI（命令行版本）最标准的方法是通过 NVIDIA 官方的 apt 仓库。

请按照以下步骤精准操作：
# 1. 下载并安装 22.04 专用的仓库配置包
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb

# 3. 必须运行一次更新，让系统看到 NVIDIA 仓库里的包
sudo apt update
2. 安装 Nsight Systems CLI
针对服务器端，我们只需要 nsight-systems-cli 这个包。它不包含任何图形界面依赖，非常精简。

Bash
# 安装命令行工具
sudo apt install -y nsight-systems-cli
如果上述命令仍然报错，请尝试使用包含版本号的安装命令（这是 NVIDIA 仓库的常见命名规则）：

Bash
sudo apt install -y cuda-nsight-systems-12-8
3. 验证安装
安装完成后，通过查看版本号来确认：

Bash
nsys --version
如果返回类似 NVIDIA Nsight Systems Command Line Interface v2024.x.x，说明安装成功。

ubuntu@VM-0-9-ubuntu:~$ nsys --version
NVIDIA Nsight Systems version 2024.6.2.225-246235244400v0
ubuntu@VM-0-9-ubuntu:~$ g++ --version
g++ (Ubuntu 11.4.0-1ubuntu1~22.04.2) 11.4.0
Copyright (C) 2021 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

第一步：下载 Google Test 源码
先确保系统中已经有了 Google Test 的源代码包：

Bash
sudo apt update
sudo apt install libgtest-dev
第二步：编译并安装（关键一步）
正如我之前提到的，Ubuntu 的 apt 只给源码，不给编译好的 .a 静态库。你需要手动编译它：

Bash
# 1. 进入源码目录
cd /usr/src/gtest

# 2. 编译源码 (使用 sudo 因为这是系统目录)
sudo mkdir -p build && cd build
sudo cmake ..
sudo make

# 3. 将生成的库文件拷贝到系统库搜索路径
sudo cp lib/*.a /usr/lib

# 4. 验证是否成功的方法
执行完上述步骤之后，你可以运行这个命令：
Bash
ls /usr/lib/libgtest.a

要生成一份能够供 Windows GUI 进行深度分析的、具有系统性、完备性的报告，你需要使用 nsys profile 命令并开启全部核心追踪标志。

以下是推荐的命令及其详细参数说明：

1. 推荐的收集命令
在 Ubuntu 终端执行：

Bash
nsys profile \
--trace=cuda,cudnn,cublas,osrt,nvtx,openacc \
--sample=cpu \
--cpuctxsw=none \
--backtrace=fp \
--force-overwrite=true \
--output=matrix_add_report \
--export=sqlite \
./matrix_app

2. 参数深度解析（为何这样配置最完备）
为了保证 Windows 端能看到最详细的瀑布图和性能瓶颈，参数选择如下：

--trace=cuda,osrt,nvtx:

cuda: 记录所有核函数（Kernel）的执行耗时、显存拷贝（HtoD/DtoH）。

osrt: (Operating System Runtime) 记录系统级调用（如内存分配、线程同步），这对于发现 CPU 阻塞 非常关键。

nvtx: 如果你在代码中加入了 NVTX 标记（用于标记代码段名称），此选项可以让你在 GUI 看到自定义的时间区间。

--sample=cpu: 定期对 CPU 进行采样，让你在 GUI 视图中看到 CPU 每一时刻都在干什么（函数的火焰图）。

--backtrace=fp: 记录调用栈。当你在 GUI 中点击一个 CUDA API 时，它能准确告诉你这个调用是从你 C++ 代码的哪一行发出的。

--output=matrix_add_report: 指定生成文件的名称。

--export=sqlite: 除了生成 .nsys-rep 原始文件外，额外生成一个 SQLite 数据库。这保证了数据的通用性，方便某些高级分析工具读取。

--force-overwrite=true: 多次实验时自动覆盖同名文件，避免因文件已存在导致收集失败。

3. 如何在 Windows 上查看
找到文件：命令执行完成后，你会发现在当前目录下生成了一个 matrix_add_report.nsys-rep 文件。

传输文件：使用 scp、WinSCP 或 Xshell 的文件传输功能，将该文件下载到你的 Windows 电脑上。

打开分析：

启动 Windows 上的 NVIDIA Nsight Systems 客户端。

点击 File -> Open，选择该 .nsys-rep 文件。

你将看到完整的 Timeline（时间轴）视图，包括 CUDA HW (Kernel 运行进度)、CUDA API 调用时间 以及 CPU 线程负载。

4. 专家级提示：如何获取更“具体”的数据？
如果你的程序运行时间很长，但你只想分析“矩阵加法”那几毫秒，你可以通过代码控制：

在 main.cu 中加入：

C++
#include <cuda_profiler_api.h>
// 在你想开始分析的地方
cudaProfilerStart();
// 运行你的矩阵加法
// ...
cudaProfilerStop();
在命令中加入 -c cudaProfilerApi：

Bash
nsys profile -c cudaProfilerApi ./test
这样收集到的数据库将只包含这两行代码之间发生的硬件事件，文件更小，分析更精准。

Generated:
    /home/ubuntu/sunlibo/nsys/STEP-1/cuda_matrix_add/build/matrix_add_report.nsys-rep
    /home/ubuntu/sunlibo/nsys/STEP-1/cuda_matrix_add/build/matrix_add_report.sqlite

以下是这两个文件的详细分工，帮助你决定如何处理它们：

1. .nsys-rep (核心报告文件) —— 必须传输
用途：这是 Nsight Systems 的标准工程格式。

GUI 兼容性：当你双击或在 Windows GUI 中点击 File -> Open 时，软件读取的就是这个文件。

内容：它包含了所有的 Timeline（时间轴）、采样数据、CUDA 核函数执行序列、CPU 调度等原始分析数据。

结论：如果你只是想在 Windows 上看图形化分析图表，只下载这一个文件就够了。

2. .sqlite (数据库文件) —— 可选（进阶使用）
用途：这是将分析数据结构化后的数据库。

GUI 兼容性：Windows 的 GUI 软件不直接读取这个文件来生成时间轴图表。

内容：它是为了方便开发者使用 SQL 语句进行“离线分析”或“自动化脚本处理”。例如，你想用 Python 脚本统计“所有 Kernel 的平均执行时间”，直接查这个数据库比解析原始文件快得多。

结论：除非你打算写脚本提取数据，或者进行超大规模的量化对比，否则不需要把它下载到 Windows。
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
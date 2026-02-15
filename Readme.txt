ubuntu@VM-0-13-ubuntu:~$ nvidia-smi       
Sun Feb 15 21:13:40 2026       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 570.158.01             Driver Version: 570.158.01     CUDA Version: 12.8     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  Tesla T4                       On  |   00000000:00:08.0 Off |                  Off |
| N/A   54C    P8             16W /   70W |       0MiB /  16384MiB |      0%      Default |
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
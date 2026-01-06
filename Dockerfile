# 使用支持CUDA和NVIDIA容器工具包的基础镜像
FROM nvidia/cuda:12.1.1-devel-ubuntu22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV NVIDIA_REQUIRE_CUDA="cuda>=12.1"

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    curl \
    pkg-config \
    libssl-dev \
    libxcb1-dev \
    libxkbcommon-dev \
    libgtk-3-dev \
    libvulkan1 \
    vulkan-tools \
    mesa-vulkan-drivers \
    libasound2-dev \
    libudev-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 安装Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# 创建工作目录
WORKDIR /app

# 复制项目文件
COPY . /app

# 构建项目
RUN cargo build --release --bin brush

# 创建目录结构并复制二进制文件到正确位置
RUN mkdir -p /app/brush/target/release && \
    cp /app/target/release/brush /app/brush/target/release/brush && \
    chmod +x /app/brush/target/release/brush

# 安装X11客户端库
RUN apt-get update && apt-get install -y \
    libx11-dev \
    libxrandr-dev \
    libxinerama-dev \
    libxcursor-dev \
    libxi-dev \
    libxss-dev \
    && rm -rf /var/lib/apt/lists/*

# 创建数据挂载点
RUN mkdir -p /data

# 设置入口点
ENTRYPOINT ["/bin/bash"]
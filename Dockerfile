FROM ubuntu:22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 设置时区
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 安装必要依赖
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    vim \
    net-tools \
    sudo \
    systemctl \
    && rm -rf /var/lib/apt/lists/*

# 下载并安装宝塔面板
RUN wget -O install.sh http://download.bt.cn/install/install-ubuntu_6.0.sh \
    && bash install.sh -y \
    && rm -f install.sh

# 复制启动脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 创建数据卷目录
RUN mkdir -p /www /workspace

# 暴露端口
# 8888: 宝塔面板端口
# 80: HTTP
# 888: phpMyAdmin
# 8080: 备用端口
# 88: 备用端口
# 21: FTP
EXPOSE 8888 80 888 8080 88 21

# 设置数据卷
VOLUME ["/www", "/workspace"]

# 启动脚本
CMD ["/start.sh"]

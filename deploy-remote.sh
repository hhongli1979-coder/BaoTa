#!/bin/bash
# 本地执行脚本 - 自动连接服务器并部署宝塔面板

echo "=========================================="
echo "  连接到服务器并自动部署宝塔面板"
echo "=========================================="
echo ""

# 服务器信息
SERVER_IP="154.54.102.19"
SERVER_PORT="16226"
SSH_KEY="~/.ssh/id_ed25519"

echo "服务器信息："
echo "  IP: $SERVER_IP"
echo "  端口: $SERVER_PORT"
echo ""

# 检查 SSH 密钥是否存在
if [ ! -f "${SSH_KEY/#\~/$HOME}" ]; then
    echo "错误: SSH 密钥文件不存在: $SSH_KEY"
    exit 1
fi

echo "正在连接到服务器..."
echo ""

# 创建远程部署脚本
ssh -p $SERVER_PORT -i $SSH_KEY root@$SERVER_IP 'bash -s' << 'ENDSSH'
#!/bin/bash

set -e

echo "=========================================="
echo "    开始在服务器上部署宝塔面板"
echo "=========================================="
echo ""

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then 
    echo "错误: 需要 root 权限"
    exit 1
fi

# 安装 Git（如果未安装）
if ! command -v git &> /dev/null; then
    echo "安装 Git..."
    if [ -f /etc/debian_version ]; then
        apt-get update && apt-get install -y git
    elif [ -f /etc/redhat-release ]; then
        yum install -y git
    fi
fi

# 安装 Docker（如果未安装）
if ! command -v docker &> /dev/null; then
    echo "安装 Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    systemctl start docker
    systemctl enable docker
    echo "✓ Docker 安装完成"
else
    echo "✓ Docker 已安装"
fi

# 安装 Docker Compose（如果未安装）
if ! command -v docker-compose &> /dev/null; then
    echo "安装 Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo "✓ Docker Compose 安装完成"
else
    echo "✓ Docker Compose 已安装"
fi

echo ""
docker --version
docker-compose --version
echo ""

# 创建工作目录
WORK_DIR="/opt/baota"
echo "创建工作目录: $WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# 创建数据目录
mkdir -p www workspace

# 创建 docker-compose.yml
echo "创建配置文件..."
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  baota:
    image: hhongli1979coder/baota:latest
    container_name: baota-panel
    privileged: true
    restart: unless-stopped
    ports:
      - "8888:8888"
      - "80:80"
      - "888:888"
      - "8080:8080"
      - "88:88"
      - "21:21"
    volumes:
      - ./www:/www
      - ./workspace:/workspace
    environment:
      - TZ=Asia/Shanghai
EOF

echo "✓ 配置文件创建完成"
echo ""

# 拉取镜像
echo "拉取 Docker 镜像（可能需要几分钟）..."
docker-compose pull

echo ""
echo "启动容器..."
docker-compose up -d

echo ""
echo "等待容器启动..."
sleep 10

# 检查容器状态
if docker ps | grep -q baota-panel; then
    echo "✓ 容器启动成功！"
else
    echo "✗ 容器启动失败"
    docker-compose logs
    exit 1
fi

echo ""
echo "=========================================="
echo "           部署完成！"
echo "=========================================="
echo ""

# 获取服务器 IP
SERVER_IP=$(curl -s ifconfig.me || hostname -I | awk '{print $1}')

echo "访问地址："
echo "  http://${SERVER_IP}:8888"
echo ""

echo "获取登录信息："
echo "----------------------------------------"
docker exec baota-panel bt default
echo "----------------------------------------"
echo ""

echo "常用命令："
echo "  cd /opt/baota"
echo "  docker-compose logs -f      # 查看日志"
echo "  docker-compose restart      # 重启服务"
echo "  docker exec -it baota-panel bash  # 进入容器"
echo ""

echo "下一步操作："
echo "1. 访问上面显示的地址"
echo "2. 使用显示的用户名和密码登录"
echo "3. 立即修改默认密码（重要！）"
echo ""

# 配置防火墙
echo "正在配置防火墙..."
if command -v ufw &> /dev/null; then
    ufw allow 8888/tcp
    ufw allow 80/tcp
    ufw --force enable
    echo "✓ UFW 防火墙已配置"
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-port=8888/tcp
    firewall-cmd --permanent --add-port=80/tcp
    firewall-cmd --reload
    echo "✓ Firewalld 防火墙已配置"
fi

echo ""
echo "=========================================="
echo "如果使用云服务器，请在云控制台安全组中"
echo "开放端口：8888, 80, 888"
echo "=========================================="

ENDSSH

echo ""
echo "=========================================="
echo "  部署脚本执行完成！"
echo "=========================================="
echo ""
echo "请在浏览器访问: http://154.54.102.19:8888"
echo ""

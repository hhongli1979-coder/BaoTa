#!/bin/bash
# 宝塔面板 Docker 服务器部署脚本
# 用于在独立服务器上快速部署宝塔面板容器

set -e

echo "=========================================="
echo "    宝塔面板 Docker 服务器部署脚本      "
echo "=========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}错误: 请使用 root 用户运行此脚本${NC}"
    echo "使用方法: sudo bash deploy-server.sh"
    exit 1
fi

echo -e "${GREEN}✓${NC} Root 权限检查通过"
echo ""

# 检查 Docker 是否已安装
echo "检查 Docker 安装状态..."
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Docker 未安装，正在安装...${NC}"
    
    # 安装 Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    
    # 启动 Docker 服务
    systemctl start docker
    systemctl enable docker
    
    echo -e "${GREEN}✓${NC} Docker 安装完成"
else
    echo -e "${GREEN}✓${NC} Docker 已安装"
fi

# 检查 Docker Compose 是否已安装
echo "检查 Docker Compose 安装状态..."
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}Docker Compose 未安装，正在安装...${NC}"
    
    # 安装 Docker Compose
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    echo -e "${GREEN}✓${NC} Docker Compose 安装完成"
else
    echo -e "${GREEN}✓${NC} Docker Compose 已安装"
fi

echo ""
echo "Docker 版本信息："
docker --version
docker-compose --version
echo ""

# 创建工作目录
WORK_DIR="/opt/baota"
echo "创建工作目录: $WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# 创建数据目录
echo "创建数据目录..."
mkdir -p "$WORK_DIR/www"
mkdir -p "$WORK_DIR/workspace"

# 创建 docker-compose.yml 文件
echo "创建 docker-compose.yml 配置文件..."
cat > docker-compose.yml <<'EOF'
version: '3.8'

services:
  baota:
    image: hhongli1979coder/baota:latest
    container_name: baota-panel
    privileged: true
    restart: unless-stopped
    ports:
      - "8888:8888"  # 宝塔面板
      - "80:80"      # HTTP
      - "888:888"    # phpMyAdmin
      - "8080:8080"  # 备用端口
      - "88:88"      # 备用端口
      - "21:21"      # FTP
    volumes:
      - ./www:/www
      - ./workspace:/workspace
    environment:
      - TZ=Asia/Shanghai
EOF

echo -e "${GREEN}✓${NC} 配置文件创建完成"
echo ""

# 拉取 Docker 镜像
echo "拉取宝塔面板 Docker 镜像..."
echo -e "${YELLOW}这可能需要几分钟时间，请耐心等待...${NC}"
docker-compose pull

echo -e "${GREEN}✓${NC} 镜像拉取完成"
echo ""

# 启动容器
echo "启动宝塔面板容器..."
docker-compose up -d

echo ""
echo "等待容器启动..."
sleep 10

# 检查容器状态
if docker ps | grep -q baota-panel; then
    echo -e "${GREEN}✓${NC} 容器启动成功！"
else
    echo -e "${RED}✗${NC} 容器启动失败，请检查日志"
    echo "查看日志命令: docker-compose logs"
    exit 1
fi

echo ""
echo "=========================================="
echo "           部署完成！                     "
echo "=========================================="
echo ""

# 获取服务器 IP
SERVER_IP=$(curl -s ifconfig.me || hostname -I | awk '{print $1}')

echo "访问信息："
echo "----------------------------------------"
echo -e "${GREEN}宝塔面板地址:${NC} http://${SERVER_IP}:8888"
echo "----------------------------------------"
echo ""

echo "获取登录信息："
echo "----------------------------------------"
docker exec baota-panel bt default
echo "----------------------------------------"
echo ""

echo "常用管理命令："
echo "  docker-compose logs -f      # 查看日志"
echo "  docker-compose restart      # 重启服务"
echo "  docker-compose stop         # 停止服务"
echo "  docker-compose start        # 启动服务"
echo "  docker exec -it baota-panel bash  # 进入容器"
echo "  docker exec baota-panel bt default # 查看面板信息"
echo ""

echo "面板管理命令（在容器内）："
echo "  bt default    # 查看面板默认信息"
echo "  bt 14         # 修改面板密码"
echo "  bt 8          # 修改面板端口"
echo "  bt restart    # 重启面板"
echo ""

echo -e "${GREEN}部署完成！请访问上述地址登录宝塔面板${NC}"
echo ""
echo "重要提示："
echo "1. 首次登录后请立即修改默认密码"
echo "2. 数据保存在: $WORK_DIR/www 和 $WORK_DIR/workspace"
echo "3. 如需开放防火墙端口，请执行："
echo "   firewall-cmd --permanent --add-port=8888/tcp"
echo "   firewall-cmd --permanent --add-port=80/tcp"
echo "   firewall-cmd --reload"
echo ""

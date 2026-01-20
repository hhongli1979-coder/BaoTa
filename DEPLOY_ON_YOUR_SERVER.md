# 📋 在您的服务器上部署 - 详细操作指南

## 🎯 您的服务器信息
- **IP地址**: 154.54.102.19
- **SSH端口**: 16226
- **连接命令**: `ssh root@154.54.102.19 -p 16226 -i ~/.ssh/id_ed25519`

---

## 🚀 部署方法（选择其中一种）

### 方法 1️⃣：使用本地脚本自动部署（最简单）

在**您的本地电脑**上执行：

```bash
# 1. 克隆仓库到本地
git clone https://github.com/hhongli1979-coder/BaoTa.git
cd BaoTa

# 2. 运行自动部署脚本（会自动连接服务器并部署）
bash deploy-remote.sh
```

这个脚本会：
- ✅ 自动连接到您的服务器
- ✅ 安装 Docker 和 Docker Compose
- ✅ 下载并启动宝塔面板容器
- ✅ 配置防火墙
- ✅ 显示访问地址和登录信息

---

### 方法 2️⃣：手动 SSH 连接并部署

#### 步骤 1: 连接到服务器

在**您的本地电脑**终端执行：

```bash
ssh root@154.54.102.19 -p 16226 -i ~/.ssh/id_ed25519
```

#### 步骤 2: 在服务器上执行部署命令

连接成功后，**在服务器上**复制粘贴以下完整命令：

```bash
# 一键部署命令（完整版）
bash <(cat << 'EOF'
set -e
echo "开始部署宝塔面板..."

# 安装 Docker
if ! command -v docker &> /dev/null; then
    echo "安装 Docker..."
    curl -fsSL https://get.docker.com | sh
    systemctl start docker
    systemctl enable docker
fi

# 安装 Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "安装 Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# 创建工作目录
mkdir -p /opt/baota && cd /opt/baota

# 创建配置文件
cat > docker-compose.yml << 'COMPOSE_EOF'
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
    volumes:
      - ./www:/www
      - ./workspace:/workspace
    environment:
      - TZ=Asia/Shanghai
COMPOSE_EOF

# 启动服务
docker-compose pull
docker-compose up -d

# 等待启动
sleep 10

# 显示登录信息
echo ""
echo "=========================================="
echo "部署完成！"
echo "=========================================="
echo ""
echo "访问地址: http://154.54.102.19:8888"
echo ""
echo "登录信息："
docker exec baota-panel bt default
echo ""

# 配置防火墙
if command -v ufw &> /dev/null; then
    ufw allow 8888/tcp
    ufw allow 80/tcp
    echo "防火墙已配置"
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-port=8888/tcp
    firewall-cmd --permanent --add-port=80/tcp
    firewall-cmd --reload
    echo "防火墙已配置"
fi

EOF
)
```

---

### 方法 3️⃣：分步执行（最详细）

#### 在您的本地电脑执行：

```bash
ssh root@154.54.102.19 -p 16226 -i ~/.ssh/id_ed25519
```

#### 连接成功后，在服务器上逐步执行：

**步骤 1: 安装 Docker**
```bash
curl -fsSL https://get.docker.com | sh
systemctl start docker
systemctl enable docker
docker --version
```

**步骤 2: 安装 Docker Compose**
```bash
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

**步骤 3: 创建工作目录**
```bash
mkdir -p /opt/baota
cd /opt/baota
```

**步骤 4: 创建配置文件**
```bash
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
    volumes:
      - ./www:/www
      - ./workspace:/workspace
    environment:
      - TZ=Asia/Shanghai
EOF
```

**步骤 5: 启动服务**
```bash
docker-compose pull
docker-compose up -d
```

**步骤 6: 查看登录信息**
```bash
# 等待几秒让容器完全启动
sleep 10

# 查看登录信息
docker exec baota-panel bt default
```

**步骤 7: 配置防火墙**

Ubuntu/Debian:
```bash
ufw allow 8888/tcp
ufw allow 80/tcp
ufw enable
```

CentOS:
```bash
firewall-cmd --permanent --add-port=8888/tcp
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --reload
```

---

## 🌐 访问宝塔面板

### 访问地址
在浏览器中打开：
```
http://154.54.102.19:8888
```

### 获取登录信息
如果忘记了登录信息，在服务器上执行：
```bash
docker exec baota-panel bt default
```

---

## 🔧 常用管理命令

所有命令都在服务器的 `/opt/baota` 目录下执行：

```bash
# 进入工作目录
cd /opt/baota

# 查看容器状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 重启服务
docker-compose restart

# 停止服务
docker-compose stop

# 启动服务
docker-compose start

# 进入容器
docker exec -it baota-panel bash

# 查看面板信息
docker exec baota-panel bt default

# 修改面板密码
docker exec baota-panel bt 14

# 重启面板
docker exec baota-panel bt restart
```

---

## ⚠️ 重要提示

### 1. 云服务器安全组配置
如果您的服务器是云服务器（阿里云、腾讯云、AWS等），还需要：
- 登录云服务器控制台
- 找到安全组设置
- 添加入站规则：开放端口 **8888**、**80**、**888**

### 2. 首次登录后必做事项
- ✅ 立即修改默认密码
- ✅ 修改默认端口（可选，增强安全性）
- ✅ 配置 IP 访问白名单
- ✅ 绑定域名并配置 SSL（可选）

### 3. 数据备份
- 重要数据存储在 `/opt/baota/www` 和 `/opt/baota/workspace`
- 建议定期备份这两个目录

---

## 🛠️ 故障排除

### 问题 1: SSH 连接失败
```bash
# 检查端口是否正确
ssh root@154.54.102.19 -p 16226 -i ~/.ssh/id_ed25519 -v

# 确保 SSH 密钥权限正确
chmod 600 ~/.ssh/id_ed25519
```

### 问题 2: 无法访问面板
```bash
# 检查容器是否运行
docker ps | grep baota

# 查看容器日志
docker logs baota-panel

# 检查防火墙
sudo iptables -L -n | grep 8888
```

### 问题 3: Docker 安装失败
```bash
# 手动安装 Docker（Ubuntu）
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# 手动安装 Docker（CentOS）
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
```

---

## 📞 需要帮助？

如果遇到问题：
1. 查看日志：`docker-compose logs -f`
2. 检查文档：`SERVER_DEPLOY.md`
3. GitHub Issues：https://github.com/hhongli1979-coder/BaoTa/issues

---

## ✅ 部署检查清单

- [ ] SSH 成功连接到服务器
- [ ] Docker 和 Docker Compose 已安装
- [ ] 容器成功启动
- [ ] 防火墙端口已开放
- [ ] 云安全组已配置（如适用）
- [ ] 能够访问 http://154.54.102.19:8888
- [ ] 已获取登录用户名和密码
- [ ] 首次登录成功
- [ ] 已修改默认密码

---

**祝您部署顺利！** 🎉

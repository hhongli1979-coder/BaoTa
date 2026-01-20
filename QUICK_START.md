# 🚀 快速部署命令参考

## 在您的服务器上执行以下命令

### 方式一：一键自动部署（推荐）

```bash
# 1. 连接到服务器
ssh root@154.54.102.19 -p 16226 -i ~/.ssh/id_ed25519

# 2. 克隆仓库
git clone https://github.com/hhongli1979-coder/BaoTa.git
cd BaoTa

# 3. 运行部署脚本
sudo bash deploy-server.sh

# 4. 访问面板
# http://154.54.102.19:8888
```

### 方式二：使用 Docker Compose

```bash
# 1. 连接到服务器
ssh root@154.54.102.19 -p 16226 -i ~/.ssh/id_ed25519

# 2. 安装 Docker（如果未安装）
curl -fsSL https://get.docker.com | sudo sh

# 3. 创建目录
sudo mkdir -p /opt/baota && cd /opt/baota

# 4. 创建配置文件
sudo tee docker-compose.yml > /dev/null <<'EOF'
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

# 5. 启动服务
sudo docker-compose up -d

# 6. 查看登录信息
sudo docker exec baota-panel bt default

# 7. 访问面板
# http://154.54.102.19:8888
```

### 方式三：使用 Docker 命令

```bash
# 1. 连接到服务器
ssh root@154.54.102.19 -p 16226 -i ~/.ssh/id_ed25519

# 2. 拉取并运行容器
sudo docker run -d \
  --name baota-panel \
  --privileged \
  --restart unless-stopped \
  -p 8888:8888 \
  -p 80:80 \
  -p 888:888 \
  -v /opt/baota/www:/www \
  -v /opt/baota/workspace:/workspace \
  -e TZ=Asia/Shanghai \
  hhongli1979coder/baota:latest

# 3. 查看登录信息
sudo docker logs baota-panel

# 4. 访问面板
# http://154.54.102.19:8888
```

## 常用管理命令

```bash
# 查看容器状态
sudo docker ps

# 查看日志
sudo docker logs -f baota-panel

# 重启容器
sudo docker restart baota-panel

# 进入容器
sudo docker exec -it baota-panel bash

# 查看面板信息
sudo docker exec baota-panel bt default

# 修改密码
sudo docker exec baota-panel bt 14

# 停止容器
sudo docker stop baota-panel

# 启动容器
sudo docker start baota-panel
```

## 防火墙配置

```bash
# Ubuntu/Debian
sudo ufw allow 8888/tcp
sudo ufw allow 80/tcp
sudo ufw enable

# CentOS
sudo firewall-cmd --permanent --add-port=8888/tcp
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --reload
```

## 访问信息

- **面板地址**: http://154.54.102.19:8888
- **获取密码**: `sudo docker exec baota-panel bt default`
- **工作目录**: /opt/baota/

## 注意事项

1. ✅ 必须启用 privileged 模式
2. 🔒 首次登录后立即修改密码
3. 🔥 确保防火墙开放 8888 端口
4. 💾 定期备份 /opt/baota/ 目录
5. ☁️  云服务器需在控制台配置安全组

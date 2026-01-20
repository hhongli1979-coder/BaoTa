# 📦 服务器部署指南

> 在您自己的服务器上部署宝塔面板 Docker 容器

## 🎯 适用场景

本指南适用于在以下环境部署：
- ✅ 独立的 Linux 服务器（VPS、云服务器、物理服务器）
- ✅ 支持 Docker 的服务器环境
- ✅ Ubuntu、Debian、CentOS 等主流 Linux 发行版

## 📋 前置要求

### 服务器配置
- **操作系统**: Linux（推荐 Ubuntu 20.04+ 或 CentOS 7+）
- **CPU**: 1 核心以上
- **内存**: 2GB 以上
- **磁盘**: 20GB 以上可用空间
- **网络**: 可以访问互联网

### 所需权限
- Root 用户权限或 sudo 权限

### 所需端口
确保以下端口未被占用：
- `8888` - 宝塔面板（必需）
- `80` - HTTP（可选）
- `888` - phpMyAdmin（可选）
- `8080`, `88`, `21` - 其他服务（可选）

## 🚀 快速部署（推荐）

### 方法一：使用自动部署脚本

1. **SSH 连接到服务器**

```bash
# 示例（使用您的实际服务器信息）
ssh root@154.54.102.19 -p 16226 -i ~/.ssh/id_ed25519
```

2. **下载部署脚本**

```bash
# 克隆仓库
git clone https://github.com/hhongli1979-coder/BaoTa.git
cd BaoTa

# 或者直接下载脚本
wget https://raw.githubusercontent.com/hhongli1979-coder/BaoTa/main/deploy-server.sh
```

3. **运行部署脚本**

```bash
chmod +x deploy-server.sh
sudo bash deploy-server.sh
```

脚本会自动：
- ✅ 检查并安装 Docker
- ✅ 检查并安装 Docker Compose
- ✅ 创建必要的目录结构
- ✅ 拉取宝塔面板镜像
- ✅ 启动容器
- ✅ 显示登录信息

4. **等待完成**

部署完成后，您会看到宝塔面板的访问地址和登录信息。

### 方法二：手动部署

如果您熟悉 Docker，可以手动部署：

#### 步骤 1: 安装 Docker

**Ubuntu/Debian:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl start docker
sudo systemctl enable docker
```

**CentOS:**
```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
```

#### 步骤 2: 安装 Docker Compose

```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

#### 步骤 3: 创建工作目录

```bash
sudo mkdir -p /opt/baota
cd /opt/baota
```

#### 步骤 4: 创建 docker-compose.yml

```bash
cat > docker-compose.yml <<'EOF'
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
```

#### 步骤 5: 启动容器

```bash
# 拉取镜像
sudo docker-compose pull

# 启动服务
sudo docker-compose up -d

# 查看日志
sudo docker-compose logs -f
```

#### 步骤 6: 获取登录信息

```bash
# 查看面板默认信息
sudo docker exec baota-panel bt default
```

## 🔧 配置防火墙

### Ubuntu/Debian (UFW)

```bash
# 允许必要端口
sudo ufw allow 8888/tcp
sudo ufw allow 80/tcp
sudo ufw allow 888/tcp
sudo ufw enable
sudo ufw status
```

### CentOS (firewalld)

```bash
# 允许必要端口
sudo firewall-cmd --permanent --add-port=8888/tcp
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=888/tcp
sudo firewall-cmd --reload
sudo firewall-cmd --list-all
```

### 云服务器安全组

如果使用云服务器（阿里云、腾讯云、AWS 等），还需要在云控制台配置安全组规则，开放相应端口。

## 📱 访问宝塔面板

### 获取服务器 IP

```bash
# 查看公网 IP
curl ifconfig.me

# 或者
curl ip.sb
```

### 访问地址

```
http://您的服务器IP:8888
```

例如：`http://154.54.102.19:8888`

### 获取登录信息

```bash
# 方法1: 查看容器日志
sudo docker-compose logs | grep -A 10 "默认登录信息"

# 方法2: 进入容器查看
sudo docker exec baota-panel bt default
```

您会看到类似这样的输出：
```
外网面板地址: http://xxx.xxx.xxx.xxx:8888/xxxxxxxx
username: xxxxxxxx
password: xxxxxxxx
```

## 🛠️ 常用管理命令

### Docker Compose 命令

```bash
# 查看服务状态
sudo docker-compose ps

# 查看日志
sudo docker-compose logs -f

# 重启服务
sudo docker-compose restart

# 停止服务
sudo docker-compose stop

# 启动服务
sudo docker-compose start

# 停止并删除容器
sudo docker-compose down

# 更新镜像
sudo docker-compose pull
sudo docker-compose up -d
```

### 容器内命令

```bash
# 进入容器
sudo docker exec -it baota-panel bash

# 在容器内执行命令
sudo docker exec baota-panel bt default      # 查看面板信息
sudo docker exec baota-panel bt 14           # 修改密码
sudo docker exec baota-panel bt 8            # 修改端口
sudo docker exec baota-panel bt restart      # 重启面板
```

### 宝塔面板命令

进入容器后可用的命令：

```bash
bt              # 显示所有可用命令
bt default      # 查看默认信息
bt start        # 启动面板
bt stop         # 停止面板
bt restart      # 重启面板
bt 1            # 重启面板服务
bt 14           # 修改面板密码
bt 8            # 修改面板端口
bt 6            # 修改用户名
bt 15           # 清除面板登录限制
bt 22           # 查看面板错误日志
```

## 💾 数据管理

### 数据目录

所有数据存储在服务器的以下目录：

```
/opt/baota/
├── www/          # 宝塔面板数据（网站、数据库等）
└── workspace/    # 用户工作目录
```

### 备份数据

```bash
# 备份整个 baota 目录
sudo tar -czf baota-backup-$(date +%Y%m%d).tar.gz -C /opt baota/

# 仅备份 www 目录
sudo tar -czf www-backup-$(date +%Y%m%d).tar.gz -C /opt/baota www/
```

### 恢复数据

```bash
# 停止容器
cd /opt/baota
sudo docker-compose down

# 恢复备份
sudo tar -xzf baota-backup-YYYYMMDD.tar.gz -C /opt/

# 重新启动
sudo docker-compose up -d
```

## 🔒 安全建议

1. **立即修改默认密码**
   ```bash
   sudo docker exec -it baota-panel bash
   bt 14
   ```

2. **修改默认端口**
   ```bash
   sudo docker exec -it baota-panel bash
   bt 8
   ```

3. **配置 IP 白名单**
   - 在宝塔面板设置中配置访问 IP 限制

4. **启用 SSL**
   - 在面板中配置 SSL 证书

5. **定期备份**
   - 设置定时备份任务

6. **及时更新**
   ```bash
   sudo docker-compose pull
   sudo docker-compose up -d
   ```

## 🛠️ 故障排除

### 问题 1: 容器无法启动

**检查日志：**
```bash
sudo docker-compose logs
```

**常见原因：**
- Docker 未正确安装
- 端口被占用
- 权限不足

### 问题 2: 无法访问面板

**检查步骤：**

1. 检查容器是否运行
```bash
sudo docker ps | grep baota
```

2. 检查端口是否开放
```bash
sudo netstat -tlnp | grep 8888
```

3. 检查防火墙
```bash
# Ubuntu
sudo ufw status

# CentOS
sudo firewall-cmd --list-all
```

4. 检查云服务器安全组配置

### 问题 3: 性能问题

**查看资源使用：**
```bash
sudo docker stats baota-panel
```

**优化建议：**
- 增加服务器内存
- 使用 SSD 硬盘
- 限制容器资源使用

### 问题 4: 数据丢失

**预防措施：**
- 确保挂载了数据卷
- 定期备份
- 不要删除容器时使用 `-v` 参数

## 📊 性能优化

### 限制容器资源

编辑 `docker-compose.yml` 添加资源限制：

```yaml
services:
  baota:
    # ... 其他配置 ...
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          memory: 2G
```

### 使用本地卷

如果需要更好的性能，可以使用命名卷：

```yaml
volumes:
  - baota_www:/www
  - baota_workspace:/workspace

volumes:
  baota_www:
    driver: local
  baota_workspace:
    driver: local
```

## 🔄 更新升级

### 更新 Docker 镜像

```bash
cd /opt/baota

# 拉取最新镜像
sudo docker-compose pull

# 重新创建容器
sudo docker-compose up -d
```

### 更新宝塔面板

在宝塔面板内，通过面板自带的更新功能升级。

## 📞 获取帮助

如遇到问题：

1. 查看项目文档
2. 查看 Docker 日志
3. 访问宝塔论坛：https://www.bt.cn/bbs/
4. 在 GitHub 提交 Issue

## 📝 快速命令参考

```bash
# 部署
sudo bash deploy-server.sh

# 查看状态
sudo docker-compose ps

# 查看日志
sudo docker-compose logs -f

# 重启
sudo docker-compose restart

# 进入容器
sudo docker exec -it baota-panel bash

# 查看面板信息
sudo docker exec baota-panel bt default

# 修改密码
sudo docker exec baota-panel bt 14

# 备份
sudo tar -czf backup.tar.gz -C /opt baota/

# 更新
sudo docker-compose pull && sudo docker-compose up -d
```

---

**祝您部署顺利！** 🎉

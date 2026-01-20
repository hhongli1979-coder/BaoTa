# 🚀 宝塔面板 Docker 部署方案

> 基于 Docker 的宝塔面板一键部署解决方案，支持 RunPod 平台快速部署

## 📖 项目介绍

本项目提供了宝塔面板的 Docker 容器化部署方案，让您可以轻松在任何支持 Docker 的环境中运行宝塔面板，特别优化了 RunPod 平台的部署体验。

### ✨ 主要特性

- 🐳 **完整的 Docker 支持**：基于 Ubuntu 22.04，预装宝塔面板
- 🚀 **一键部署**：支持 RunPod 平台快速部署
- 🔄 **自动化构建**：通过 GitHub Actions 自动构建和发布
- 💾 **数据持久化**：支持数据卷挂载，数据永久保存
- 🔧 **易于管理**：提供完整的管理命令和友好的启动提示
- 🌐 **多端口支持**：支持 Web、FTP、数据库等多种服务

## 🎯 在 RunPod 上使用

### 方法一：使用 Docker Hub 镜像（推荐）

1. 登录 [RunPod](https://www.runpod.io/)
2. 点击 **Deploy** 创建新实例
3. 选择 **Custom Container**
4. 在 Container Image 中填入：`hhongli1979coder/baota:latest`
5. 配置端口映射：
   - `8888` - 宝塔面板管理界面
   - `80` - HTTP 服务
   - `888` - phpMyAdmin 
   - `8080` - 备用端口
   - `88` - 备用端口
   - `21` - FTP 服务
6. 设置环境变量：`TZ=Asia/Shanghai`
7. 挂载数据卷：`/workspace`（推荐 50GB+）
8. **重要**：启用 **Privileged Mode**（宝塔需要特权模式运行）
9. 点击部署并等待容器启动

### 方法二：从 GitHub 构建

1. Fork 本仓库到您的 GitHub 账号
2. 在您的仓库设置中添加 Secrets：
   - `DOCKERHUB_USERNAME` - 您的 Docker Hub 用户名
   - `DOCKERHUB_TOKEN` - 您的 Docker Hub 访问令牌
3. 推送代码到 main/master 分支触发自动构建
4. 构建完成后在 RunPod 使用您的镜像

## 📝 首次使用指南

### 获取初始登录信息

容器启动后，会自动在日志中显示宝塔面板的默认登录信息：

```bash
# 在 RunPod 的日志页面查看输出，或使用以下命令
docker logs <container_name>
```

您会看到类似这样的信息：
```
默认登录信息：
----------------------------------------
外网面板地址: http://xxx.xxx.xxx.xxx:8888/xxxxxxxx
内网面板地址: http://xxx.xxx.xxx.xxx:8888/xxxxxxxx
username: xxxxxxxx
password: xxxxxxxx
----------------------------------------
```

### 访问面板

1. 使用 RunPod 提供的端口代理地址访问（通常是 8888 端口）
2. 使用上面显示的用户名和密码登录
3. 首次登录后，**强烈建议立即修改默认密码**

## 🔧 常用宝塔命令

进入容器后，您可以使用以下命令管理宝塔面板：

```bash
# 查看面板默认信息（用户名、密码、访问地址）
bt default

# 重启面板服务
bt restart

# 停止面板服务
bt stop

# 启动面板服务
bt start

# 修改面板密码
bt 14

# 修改面板端口
bt 8

# 修改面板用户名
bt 6

# 清除面板登录限制
bt 15

# 查看面板错误日志
bt 22

# 查看所有可用命令
bt
```

## 💡 本地测试使用

### 使用 Docker Compose

```bash
# 克隆仓库
git clone https://github.com/hhongli1979-coder/BaoTa.git
cd BaoTa

# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

### 使用 Docker 命令

```bash
# 构建镜像
docker build -t baota:latest .

# 运行容器
docker run -d \
  --name baota-panel \
  --privileged \
  -p 8888:8888 \
  -p 80:80 \
  -p 888:888 \
  -p 8080:8080 \
  -p 88:88 \
  -p 21:21 \
  -v $(pwd)/www:/www \
  -v $(pwd)/workspace:/workspace \
  -e TZ=Asia/Shanghai \
  baota:latest

# 查看日志
docker logs -f baota-panel

# 进入容器
docker exec -it baota-panel bash
```

## 🔒 安全建议

1. **立即修改默认密码**：首次登录后请使用 `bt 14` 命令修改密码
2. **修改默认端口**：使用 `bt 8` 命令将默认的 8888 端口改为其他端口
3. **启用面板 SSL**：在面板设置中配置 SSL 证书
4. **设置访问限制**：在面板设置中配置 IP 白名单
5. **定期备份**：定期备份 `/www` 和 `/workspace` 目录
6. **及时更新**：保持宝塔面板为最新版本

## 📂 目录结构说明

```
BaoTa/
├── Dockerfile              # Docker 镜像构建文件
├── start.sh                # 容器启动脚本
├── docker-compose.yml      # Docker Compose 配置
├── runpod-template.json    # RunPod 模板配置
├── .github/
│   └── workflows/
│       └── docker-build.yml # GitHub Actions 自动构建
├── .dockerignore           # Docker 构建忽略文件
├── .gitignore              # Git 忽略文件
└── README.md               # 项目文档
```

### 数据目录

- `/www` - 宝塔面板数据目录（网站、数据库等）
- `/workspace` - 用户工作目录（推荐用于数据持久化）

## 🛠️ 故障排除

### 容器无法启动

**原因**：可能未启用 privileged 模式

**解决**：确保在运行容器时添加 `--privileged` 参数或在 docker-compose 中设置 `privileged: true`

### 无法访问面板

**原因**：端口映射配置错误或防火墙阻止

**解决**：
1. 检查端口映射配置是否正确
2. 确认 RunPod 的端口代理是否正确配置
3. 使用 `bt default` 查看正确的访问地址

### 忘记密码

**解决**：
```bash
# 进入容器
docker exec -it baota-panel bash

# 查看默认信息
bt default

# 或重置密码
bt 14
```

### 数据丢失

**原因**：未正确配置数据卷

**解决**：确保挂载了 `/www` 和 `/workspace` 目录到宿主机或持久化存储

## ⚠️ 注意事项

1. **特权模式要求**：宝塔面板需要在 privileged 模式下运行以正常管理系统服务
2. **资源要求**：建议至少 2GB RAM 和 20GB 存储空间
3. **数据持久化**：强烈建议挂载数据卷以防止数据丢失
4. **端口冲突**：确保宿主机上的端口未被占用
5. **安全第一**：请在生产环境中采取适当的安全措施

## 🔗 相关链接

- [宝塔官网](https://www.bt.cn/)
- [宝塔文档](http://docs.bt.cn/)
- [宝塔论坛](https://www.bt.cn/bbs/)
- [RunPod 官网](https://www.runpod.io/)
- [Docker Hub](https://hub.docker.com/r/hhongli1979coder/baota)

## 📄 开源协议

本项目遵循宝塔开源许可协议：https://www.bt.cn/kyxy.html

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📮 反馈

如有问题或建议，请通过以下方式反馈：
- GitHub Issues
- [宝塔论坛](https://www.bt.cn/bbs/forum-43-1.html)

---

**祝您使用愉快！** 🎉

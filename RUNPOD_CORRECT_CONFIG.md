# 🎯 RunPod 正确配置指南

## ✅ 推荐配置（适用于 RunPod）

### 基础配置

| 配置项 | 推荐值 | 说明 |
|--------|--------|------|
| **Container Image** | `hhongli1979coder/baota:latest` | 使用我们构建的镜像 |
| **Container Disk** | `20 GB` | 最少 20GB，推荐 30GB+ |
| **Volume Disk** | `50 GB` | 数据持久化存储 |
| **Volume Mount Path** | `/workspace` | 持久化数据目录 |

### 端口配置

#### HTTP Ports (必须配置)
```
8888, 80, 888
```

**说明**：
- `8888` - 宝塔面板管理界面（**主要端口**）
- `80` - HTTP Web 服务
- `888` - phpMyAdmin 数据库管理

#### TCP Ports (可选)
```
22
```

**说明**：
- `22` - SSH 访问（可选，用于远程管理）

### 环境变量
```
TZ=Asia/Shanghai
```

### 容器启动命令
**留空或使用**：
```
/start.sh
```

---

## 🔧 如果使用自定义镜像 (btpanel/baota:lnmp)

如果您必须使用 `btpanel/baota:lnmp` 镜像，请按以下方式配置：

### RunPod 配置

| 配置项 | 值 |
|--------|-----|
| **Container Image** | `btpanel/baota:lnmp` |
| **Container Disk** | `20 GB` |
| **Volume Disk** | `50 GB` |
| **Volume Mount Path** | `/workspace` |
| **HTTP Ports** | `8888, 80, 888` |
| **TCP Ports** | `22` (可选) |

### 容器启动命令（修正版）

**不要使用原始命令！** 原始命令不适合 RunPod，应该使用：

```bash
#!/bin/bash
# 创建数据目录结构
mkdir -p /workspace/wwwroot
mkdir -p /workspace/mysql_data
mkdir -p /workspace/vhost

# 创建软链接或挂载点
ln -sf /workspace/wwwroot /www/wwwroot
ln -sf /workspace/mysql_data /www/server/data
ln -sf /workspace/vhost /www/server/panel/vhost

# 启动宝塔服务
/etc/init.d/bt start

# 显示登录信息
bt default

# 保持容器运行
tail -f /dev/null
```

**或者简化版**（推荐）：

```bash
/etc/init.d/bt start && bt default && tail -f /dev/null
```

---

## ❌ 错误配置示例（不要这样做）

### 错误 1: 使用 `--net=host`
```bash
# ❌ 错误 - 在 RunPod 不要使用这个
docker run --net=host ...
```

**原因**: RunPod 有自己的网络管理，使用 `--net=host` 会导致端口映射失败。

### 错误 2: 挂载不存在的主机路径
```bash
# ❌ 错误 - /home/website_data 在容器重启后会丢失
-v /home/website_data:/www/wwwroot
```

**原因**: 只有 Volume Mount Path（如 `/workspace`）是持久化的，其他路径会在容器重启后丢失。

### 错误 3: Volume Mount Path 设置错误
```bash
# ❌ 错误 - /b64e21cc 是 RunPod 自动生成的，不要手动设置
Volume mount path: /b64e21cc
```

**正确**: 使用有意义的路径，如 `/workspace` 或 `/www`。

---

## ✅ 正确配置步骤

### 方案 A: 使用我们的镜像（最简单，推荐）

1. **Container Image**:
   ```
   hhongli1979coder/baota:latest
   ```

2. **Container Disk**: `20 GB`

3. **Volume Disk**: `50 GB`

4. **Volume Mount Path**:
   ```
   /workspace
   ```

5. **Expose HTTP Ports**:
   ```
   8888, 80, 888
   ```

6. **Container Start Command**: 留空或
   ```
   /start.sh
   ```

7. **Environment Variables**:
   ```
   TZ=Asia/Shanghai
   ```

8. **启用 Privileged Mode**: ✅ 必须启用

### 方案 B: 使用官方镜像（btpanel/baota）

1. **Container Image**:
   ```
   btpanel/baota:lnmp
   ```

2. **Container Disk**: `20 GB`

3. **Volume Disk**: `50 GB`

4. **Volume Mount Path**:
   ```
   /workspace
   ```

5. **Expose HTTP Ports**:
   ```
   8888, 80, 888
   ```

6. **Container Start Command**:
   ```bash
   bash -c "mkdir -p /workspace/{wwwroot,mysql_data,vhost} && ln -sf /workspace/wwwroot /www/wwwroot && ln -sf /workspace/mysql_data /www/server/data && ln -sf /workspace/vhost /www/server/panel/vhost && /etc/init.d/bt start && bt default && tail -f /dev/null"
   ```

7. **Environment Variables**:
   ```
   TZ=Asia/Shanghai
   ```

8. **启用 Privileged Mode**: ✅ 必须启用

---

## 📊 配置对比

| 项目 | 您的配置 | 推荐配置 | 说明 |
|------|----------|----------|------|
| Container Image | baota:debian13-dev | hhongli1979coder/baota:latest | 使用公开可用的镜像 |
| Container Disk | 5 GB ❌ | 20 GB ✅ | 5GB 太小 |
| Volume Disk | 10 GB ⚠️ | 50 GB ✅ | 10GB 可能不够 |
| Volume Mount Path | /b64e21cc ❌ | /workspace ✅ | 使用有意义的路径 |
| HTTP Ports | 80,8888,888,8080,88,21 | 8888,80,888 ✅ | 移除不必要的端口 |
| TCP Ports | 22,16626 | 22 (可选) | 16226 通常不需要 |
| 启动命令 | 使用 --net=host ❌ | 不使用 ✅ | RunPod 自动管理网络 |

---

## 🚀 快速配置模板（复制粘贴）

### 在 RunPod 界面填入以下内容：

```yaml
Container Image: hhongli1979coder/baota:latest
Container Disk: 20
Volume Disk: 50
Volume Mount Path: /workspace
Expose HTTP Ports: 8888,80,888
Expose TCP Ports: (留空或 22)
Environment Variables:
  TZ=Asia/Shanghai
Container Start Command: /start.sh
Privileged Mode: ✅ 启用
```

---

## 🔍 验证部署

部署完成后：

1. **访问面板**: 使用 RunPod 提供的 8888 端口链接
2. **查看日志**: 在 RunPod 控制台查看容器日志
3. **获取密码**: 日志中会显示登录信息

---

## 🆘 常见问题

### Q1: 为什么不能使用 `/home/*` 目录？
**A**: 在 RunPod 中，只有 Volume Mount Path 指定的目录是持久化的。其他目录（如 `/home`）在容器重启后会丢失数据。

### Q2: Volume Mount Path 应该设置什么？
**A**: 
- **推荐**: `/workspace` 或 `/www`
- **避免**: RunPod 自动生成的路径（如 `/b64e21cc`）

### Q3: 需要开放端口 21 (FTP) 吗？
**A**: 除非您确实需要 FTP 服务，否则不建议开放。现代部署通常使用 SFTP (端口 22) 或 Web 上传。

### Q4: Container Disk 和 Volume Disk 有什么区别？
**A**: 
- **Container Disk**: 临时存储，容器重启后可能丢失
- **Volume Disk**: 持久化存储，数据永久保存

### Q5: 为什么必须启用 Privileged Mode？
**A**: 宝塔面板需要管理系统服务（如 Nginx、MySQL），需要特权模式才能正常运行。

---

## 📝 总结

### ✅ 正确的配置
- 使用 `hhongli1979coder/baota:latest` 镜像
- Container Disk: 至少 20GB
- Volume Mount Path: `/workspace`
- HTTP Ports: `8888, 80, 888`
- 启用 Privileged Mode
- 不使用 `--net=host`

### ❌ 避免的配置
- Container Disk 小于 20GB
- 使用随机的 Volume Mount Path
- 在启动命令中使用 `--net=host`
- 挂载 `/home/*` 目录

---

**按照上述配置，您的宝塔面板将在 RunPod 上正常运行！** 🎉

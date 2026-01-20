# 🚀 RunPod 快速部署指南

> 本指南帮助您在 RunPod 平台快速部署宝塔面板

## 📋 部署前准备

### 需要的账号
- RunPod 账号 (注册地址: https://www.runpod.io/)
- 确保账户有足够余额（按小时计费）

### 推荐配置
- **GPU**: 不需要（选择 CPU 实例即可，更便宜）
- **内存**: 至少 2GB RAM
- **存储**: 
  - Container Disk: 20GB
  - Volume: 50GB（用于数据持久化）

## 🎯 快速部署步骤

### 第一步：登录 RunPod

1. 访问 https://www.runpod.io/
2. 使用您的账号登录
3. 进入控制台

### 第二步：创建新的 Pod

1. 点击左侧菜单的 **"Pods"** 或顶部的 **"Deploy"** 按钮
2. 选择 **"Deploy a Pod"**

### 第三步：选择模板类型

1. 在模板选择页面，选择 **"Custom Container"**
2. 或者搜索是否有 "baota" 相关的社区模板

### 第四步：配置容器镜像

在 Container 配置部分填入以下信息：

```
Container Image: hhongli1979coder/baota:latest
```

### 第五步：配置端口映射

在 **"Expose HTTP Ports"** 或 **"Ports"** 部分添加以下端口：

| 端口号 | 类型 | 说明 |
|--------|------|------|
| 8888   | HTTP | 宝塔面板管理界面（主要） |
| 80     | HTTP | Web 服务 |
| 888    | HTTP | phpMyAdmin |
| 8080   | HTTP | 备用端口 |
| 88     | HTTP | 备用端口 |
| 21     | TCP  | FTP 服务 |

**重要提示**: 主要访问端口是 **8888**，这是宝塔面板的管理界面。

### 第六步：配置存储卷

1. **Container Disk**: 设置为 `20` GB
2. **Volume Storage**: 
   - 勾选 "Add Volume"
   - 大小: `50` GB（推荐）
   - Mount Path: `/workspace`

### 第七步：环境变量（可选）

添加环境变量：

```
TZ=Asia/Shanghai
```

### 第八步：启动命令

在 **"Docker Command"** 或 **"Start Script"** 处填入：

```
/start.sh
```

### 第九步：重要设置 ⚠️

**必须启用特权模式！**

- 找到 **"Privileged Mode"** 或 **"Container Security"** 选项
- ✅ 勾选 **"Enable Privileged Mode"**
- 这是必需的，否则宝塔面板无法正常运行

### 第十步：选择机器配置

1. 选择一个 **CPU** 实例（不需要 GPU）
2. 推荐配置：
   - vCPU: 2+ 核心
   - RAM: 4GB+
   - 根据预算选择合适的地区

### 第十一步：部署

1. 检查所有配置是否正确
2. 点击底部的 **"Deploy"** 或 **"Deploy On-Demand"** 按钮
3. 等待容器启动（通常需要 2-5 分钟）

## 📱 访问宝塔面板

### 获取访问地址

容器启动后：

1. 在 RunPod 控制台找到您的 Pod
2. 点击 **"Connect"** 按钮
3. 找到端口 **8888** 对应的 **HTTP Service** 链接
4. 这就是您的宝塔面板访问地址

### 查看登录信息

**方法一：查看日志**

1. 在 Pod 详情页点击 **"Logs"** 标签
2. 在日志中找到类似这样的信息：

```
默认登录信息：
----------------------------------------
外网面板地址: http://xxx.xxx.xxx.xxx:8888/xxxxxxxx
username: xxxxxxxx
password: xxxxxxxx
----------------------------------------
```

**方法二：进入终端**

1. 在 Pod 详情页点击 **"Terminal"** 或 **"Web Terminal"**
2. 执行命令：

```bash
bt default
```

3. 查看输出的用户名和密码

### 首次登录

1. 使用获取的地址访问面板
2. 输入用户名和密码
3. **强烈建议立即修改密码！**

## 🔧 常用操作

### 进入容器终端

在 RunPod 控制台：
1. 找到您的 Pod
2. 点击 **"Terminal"** 或 **"Web Terminal"**

### 修改面板密码

```bash
bt 14
```

### 修改面板端口

```bash
bt 8
```

### 查看面板状态

```bash
bt default
```

### 重启面板

```bash
bt restart
```

## 💰 费用说明

- RunPod 按小时计费
- CPU 实例通常每小时 $0.10 - $0.50
- 不用时记得 **停止** Pod 以节省费用
- Volume 存储按月计费（通常 $0.10/GB/月）

## 🛠️ 故障排除

### 问题 1: 容器无法启动

**可能原因**: 未启用 Privileged Mode

**解决方法**:
1. 停止 Pod
2. 编辑配置，启用 Privileged Mode
3. 重新部署

### 问题 2: 无法访问面板

**可能原因**: 端口映射配置错误

**解决方法**:
1. 检查端口 8888 是否正确映射
2. 使用 RunPod 提供的 HTTP Service 链接访问
3. 在终端执行 `bt default` 查看正确的访问路径

### 问题 3: 数据丢失

**可能原因**: 未挂载 Volume 或 Pod 被删除

**解决方法**:
1. 确保配置了 Volume 并挂载到 `/workspace`
2. 重要数据务必定期备份
3. 停止 Pod（不要删除）可以保留数据

### 问题 4: 忘记密码

**解决方法**:
```bash
# 进入终端
bt default       # 查看当前密码
# 或
bt 14            # 重置密码
```

## 📌 重要提示

1. ✅ **必须启用 Privileged Mode**
2. 📁 **配置 Volume 以保存数据**
3. 🔒 **首次登录后立即修改密码**
4. 💾 **定期备份重要数据**
5. 💰 **不用时停止 Pod 节省费用**
6. 🔐 **配置防火墙和访问限制**

## 🎉 快速配置总结

复制以下配置快速部署：

```yaml
镜像: hhongli1979coder/baota:latest
Container Disk: 20GB
Volume: 50GB → /workspace
环境变量: TZ=Asia/Shanghai
启动命令: /start.sh
Privileged: ✅ 启用

端口映射:
  8888 (HTTP) - 宝塔面板
  80   (HTTP) - Web
  888  (HTTP) - phpMyAdmin
  8080 (HTTP) - 备用
  88   (HTTP) - 备用
  21   (TCP)  - FTP
```

## 🔗 相关资源

- RunPod 官网: https://www.runpod.io/
- RunPod 文档: https://docs.runpod.io/
- 宝塔官网: https://www.bt.cn/
- 宝塔文档: http://docs.bt.cn/
- 项目仓库: https://github.com/hhongli1979-coder/BaoTa

---

**祝您部署顺利！** 🎊

如有问题，请在 GitHub 提交 Issue 或访问宝塔论坛寻求帮助。

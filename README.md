# nyx - My NixOS Configuration

## 简介
`nyx` 是一个 NixOS 的配置库

---

## 配置指南

### 步骤 1: 安装 NixOS
请参考官方文档进行安装：
- 官方指南：[NixOS Installation Guide](https://nixos.wiki/wiki/NixOS_Installation_Guide)

#### 国内镜像使用
在安装的最后一步，国内用户需要使用镜像：

```bash
nixos-install --option substituters "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
```

---

### 步骤 2: 导入 Nyx 配置
在 `/etc/nixos/configuration.nix` 文件中添加以下代码块：

```nix
{
  imports = [
    ./hardware-configuration.nix
    ./nyx
  ];
}
```

---

### 用户配置
更新后的 `nyx` 支持使用 `home-manager` 配置用户环境，并允许自定义用户名。以下是默认配置：

```nix
{
  nyx.userName = "your-username"; # 替换为您的用户名
}
```

这会自动启用以下功能：
- 默认 shell 为 `zsh`
- 在用户环境中加载 `home.nix`。

---

### 默认启用服务
以下是 `nyx` 配置中默认启用的服务：
- **OpenSSH**：便于远程登录
- **Avahi**：实现零配置网络
- **nix-ld**：NixOS 动态链接库支持

---

## 脚本说明
本项目包含的若干脚本为开发和环境配置提供了支持，以下为具体说明：

### 1. `script/qemu_hooks.tmpl.sh`
- 描述：用于处理 QEMU 虚拟机的 GPU 直通准备和释放事件。
- 用法：
  - 可以作为单 GPU 直通脚本的一部分，在 Nix 配置中被引用。

### 2. `script/nixos-easy-intall.sh`
- 描述：一个简单的脚本，用于快速安装 NixOS 并进行基本配置。
- 提示：适用于快速初始化环境。

### 3. `after_init.sh`
- 描述：一个辅助脚本，用于设置环境。
- 注意：需要以常规用户身份运行，而非 root。

这些脚本将协助用户更轻松地进行系统配置和虚拟机管理。

---

## 相关链接
- [NixOS 官方文档](https://nixos.org/manual/nixos/stable/)
- [国内镜像资源](https://mirrors.tuna.tsinghua.edu.cn/nix-channels/)

---

## 许可证信息
MIT License
# nyx - My NixOS Configuration

## 简介
`nyx` 是一个 NixOS 的配置库，提供了便捷的配置导入以及代理等设置。

---

## 配置指南

### 步骤 1: 安装 Nix
请参考官方文档进行安装：
- 官方指南：[NixOS Installation Guide](https://nixos.wiki/wiki/NixOS_Installation_Guide)

#### 国内镜像使用
在安装的最后一步，国内用户需要使用镜像：

```bash
nixos-install --option substituters "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
```

---

### 步骤 2: 导入配置
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

### 步骤 3: 修改代理设置
根据需要调整 `./default.nix` 文件中的代理配置。

---

## 相关链接
- [NixOS 官方文档](https://nixos.org/manual/nixos/stable/)
- [国内镜像资源](https://mirrors.tuna.tsinghua.edu.cn/nix-channels/)

---

## 注意事项
- 请确保硬件配置文件 (`./hardware-configuration.nix`) 能准确反映您的实际硬件设置。
- 如需更改代理，务必确保其符合您的网络配置需求。

---

## 许可证信息
MIT License
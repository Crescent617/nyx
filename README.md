# nyx - NixOS Configuration Submodule

## 简介
`nyx` 是一个 NixOS 和 Home Manager 的子模块配置库，设计为易于集成到你的 NixOS flake 配置中。

---

## 快速开始

### 步骤 1: 将 nyx 作为子模块添加到 flake.nix

在 `/etc/nixos/flake.nix` 中：

```nix
{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # 1. 添加 nyx 输入（本地路径或 GitHub）
    nyx.url = "path:/etc/nixos/nyx";  # 本地开发
    # nyx.url = "github:your-username/nyx";  # GitHub 仓库

    # 2. 添加 Home Manager（nyx 需要）
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nyx, home-manager, ... }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # 必需：硬件配置
          ./hardware-configuration.nix

          # 必需：启用 Home Manager
          home-manager.nixosModules.home-manager

          # 必需：引入 nyx 子模块（自动包含系统和 Home Manager 配置）
          nyx.nixosModules.default

          # 必需：设置用户名（系统和 Home Manager 共用）
          { nyx.userName = "your-username"; }

          # 可选：自定义配置
          ({ config, pkgs, ... }: {
            networking.hostName = "your-hostname";
            boot.loader.systemd-boot.enable = true;

            fileSystems."/" = {
              device = "/dev/disk/by-uuid/your-uuid";
              fsType = "ext4";
            };

            users.users.your-username = {
              isNormalUser = true;
              extraGroups = [ "wheel" "networkmanager" ];
            };

            system.stateVersion = "25.05";
          })
        ];
      };
    };
}
```

### 步骤 2: 配置硬件和构建

```bash
# 构建并切换到新配置
sudo nixos-rebuild switch --flake /etc/nixos#your-hostname
```

---

### 传统方式（非 Flake）

#### 步骤 1: 安装 NixOS
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

## Flake 输出

### NixOS 模块（作为子包使用）
推荐使用 `nyx.nixosModules` 作为子模块集成到你的配置中：

- `nyx.nixosModules.default` - 完整配置模块（包含系统 + Home Manager）
- `nyx.nixosModules.minimal` - 最小化配置模块（包含系统 + Home Manager）

**优势**：
- 自动集成 Home Manager（只需添加 `home-manager.nixosModules.home-manager`）
- 统一的用户配置（通过 `nyx.userName`）
- 模块化的设计，易于定制

### 完整系统配置（独立使用）
也提供完整的系统配置：
- `nyx-x86_64` - 完整配置（x86_64-linux）
- `nyx-minimal-x86_64` - 最小化配置（x86_64-linux）
- `nyx-aarch64` - 完整配置（aarch64-linux）
- `nyx-minimal-aarch64` - 最小化配置（aarch64-linux）

### 使用方式

#### 推荐：作为子模块使用（灵活）

在你的 `/etc/nixos/flake.nix` 中：

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nyx.url = "github:your-username/nyx";  # 或 path:/etc/nixos/nyx

    # Home Manager（nyx 需要）
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nyx, home-manager, ... }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hardware-configuration.nix

          # 启用 Home Manager
          home-manager.nixosModules.home-manager

          # 引入 nyx（自动包含系统和 home-manager 配置）
          nyx.nixosModules.default  # 或 nyx.nixosModules.minimal

          {
            # 必需：设置用户名（系统和 home-manager 共用）
            nyx.userName = "your-username";

            # 可选：自定义设置
            nyx.gui.enable = true;
            nyx.stateVersion = "25.05";

            # 系统特定配置
            networking.hostName = "your-hostname";
            boot.loader.systemd-boot.enable = true;
            boot.loader.efi.canTouchEfiVariables = true;

            # 文件系统
            fileSystems."/" = {
              device = "/dev/disk/by-uuid/your-uuid";
              fsType = "ext4";
            };

            # 用户配置
            users.users.your-username = {
              isNormalUser = true;
              description = "Your Name";
              extraGroups = [ "wheel" "networkmanager" ];
            };

            system.stateVersion = "25.05";
          }
        ];
      };
    };
}

使用命令：
sudo nixos-rebuild switch --flake /etc/nixos#your-hostname
```

#### 备选：独立配置使用（简单）

```bash
# 构建完整配置
sudo nixos-rebuild switch --flake /etc/nixos/nyx#nyx-x86_64

# 构建最小化配置
sudo nixos-rebuild switch --flake /etc/nixos/nyx#nyx-minimal-x86_64

# 仅测试构建（不切换系统）
sudo nixos-rebuild build --flake /etc/nixos/nyx#nyx-x86_64
```

### Home Manager 独立使用

对于非 NixOS 系统，可以直接使用 Home Manager 配置：

```bash
# 使用 standalone home-manager
home-manager switch --flake /etc/nixos/nyx#hrli-x86_64
```

---

---

## Flake 输出

### NixOS 模块（作为子包使用）
`nyx` 提供预配置的 NixOS 模块，包含系统和 Home Manager 设置：

- `nyx.nixosModules.default` - 完整配置（包含 GUI 工具）
- `nyx.nixosModules.minimal` - 最小化配置（无 GUI 工具）

**优势**：
- 自动集成 Home Manager（只需添加 `home-manager.nixosModules.home-manager`）
- 统一的用户配置（通过 `nyx.userName`）
- 模块化的设计，易于定制

### Home Manager 模块
独立的 Home Manager 模块，用于自定义配置：

- `nyx.homeModules.default` - 完整用户环境（GUI 工具）
- `nyx.homeModules.minimal` - 最小化用户环境

**用法**：
```nix
home-manager.users.your-user.imports = [ nyx.homeModules.default ];
```

### 开发环境
```bash
# 进入 nyx 开发环境（用于贡献代码）
nix develop
```

---

## 工作原理

1. **nyx.nixosModules.default** 自动完成：
   - 导入系统配置（`./default.nix`）
   - 应用包覆盖（nur, unstable, zen-browser, starsheep）
   - 检测到 Home Manager 时自动配置用户环境
   - 使用 `nyx.userName` 统一系统用户和 Home Manager 用户

2. **用户只需要**：
   - 添加 `home-manager` 输入和模块
   - 添加 `nyx.nixosModules.default` 或 `nyx.nixosModules.minimal` 模块
   - 设置 `nyx.userName`
   - 配置硬件相关设置（bootloader、fileSystems 等）

3. **自动配置**：
   - Home Manager 用户环境（基于 nyx.homeModules）
   - Shell（zsh）和常用工具
   - GUI 应用（如果使用 `default` 而非 `minimal`）

---

## 完整示例

参考 `flake-usage-example.nix` 文件获取完整示例。

---

## 从完整配置迁移

如果你之前使用 `nyx` 的完整系统配置（如 `nyx#nyx-x86_64`），现在需要：

1. 创建你自己的 `/etc/nixos/flake.nix`
2. 将 `nyx` 作为子模块添加（参见上面的示例）
3. 添加硬件配置（从旧配置中复制）
4. 配置 bootloader、fileSystems 等

参考 `flake-usage-example.nix` 获取完整模板。

---

## 相关链接
- [NixOS Flakes 手册](https://nixos.wiki/wiki/Flakes)
- [Home Manager 手册](https://nix-community.github.io/home-manager/)
- [NixOS 选项搜索](https://search.nixos.org/options)
- [国内镜像资源](https://mirrors.tuna.tsinghua.edu.cn/nix-channels/)

---

## 许可证
MIT License
# Nix-Router Under LXC

> 实验性，开发中

在 PVE 中，可以选用 LXC 提高性能，安装需要的额外步骤如下:

## 1. 模板获取

```bash
nix run github:nix-community/nixos-generators -- --format proxmox-lxc
```

## 2. 设置参数

- 面板设置密码无效，RSA 有效
- 网卡接入 lan，设置名称为 lan
- 选项 -> 控制台模式 改为 console

## 3. Scratch 安装

```bash
cd /etc/nixos
curl -fsSLO https://github.com/jerrita/nix-router/raw/lxc/scratch.nix
mv scratch.nix configuration.nix

nix-channel --update
reboot

nixos-rebuild switch
```

## 4. 配置容器

示例配置: lxc/lxc.conf

> 以下是原 README

适用于冲国宝宝体质的实验性 homo router，性能💥，随时💥

- 启用了 nftables，一键 flow offload
- 白名单模式，国内域名走 smartdns 拿最快响应解析
- 其他怼 fake-ip 省去解析时间
- patch 了 miniupnpd 以适配 nft，patch 了 nft 启动顺序防止提前💥

你需要确保你是：

- 电信宽带

你需要手动更改以下，更改完执行 make install 完成安装

## Dial

- 拨号方式在 router/default.nix 中在 pppoe 和 dhcp (未实现) 中选一个
- 自行编辑 router/dial/pppoe.nix 填入用户名密码

## Nic

- 打开 router/nic.nix 填入你 wan 和 lan 的 MAC 地址

## Clash

```bash
useradd -M clash
groupadd clash
mkdir /etc/clash
touch /etc/clash/config.yaml
...
chown -R clash:clash /etc/clash
```

自行配置:

- 7893: redir
- 7894: tproxy
- 5355: dns
- fake-ip 模式
- 不用开 tun

## 你可能需要更改的其他文件

- networking/ddns.nix       # DDNS 服务 (cloudflare only)
- networking/firewall.nft   # 更改 prerouting 以做端口转发
- networking/hosts.nix      # 固定 IP 解析
- rules/special.conf        # 不想走代理的非白名单的域名可以在这里加上

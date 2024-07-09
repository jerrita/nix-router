# Nix-Router

适用于冲国宝宝体质的实验性 homo router，性能 💥，随时 💥

- 启用了 nftables，一键 flow offload
- 白名单模式，国内域名走 smartdns 拿最快响应解析
- 其他怼 fake-ip 省去解析时间

## Dial

- 拨号方式在 router/default.nix 中在 pppoe 和 dhcp 中选一个
- 自行编辑 router/dial/pppoe.nix 填入用户名密码

## Clash

编辑 static/clash/config.yaml, 需要满足

- 7893: redir
- 7894: tproxy
- 5355: dns
- fake-ip 模式
- 不用开 tun

## 你可能需要更改的其他文件

- `services/*` 一些服务配置

## 其他说明

1. 可参考 hardware/r2s, 在开机时执行一些脚本

```bash
#!/usr/bin/env sh

set -e

PATH=$PATH:/run/current-system/sw/bin

if ! nft list chain inet global forward | grep -q Zerotier; then
    echo "preparing zerotier..."
    nft add rule inet global forward iifname ztrfycmpps counter accept comment "Zerotier"
else
    echo "zerotier inserted, ignore."
fi
```

1. 可动态加一些 dnsmasq 规则在 `/etc/dnsmasq.conf` 中。

# Nix-Router

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

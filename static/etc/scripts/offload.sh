#!/usr/bin/env bash
set -e

if ! nft list flowtable inet global f &> /dev/null; then
    nft add flowtable inet global f { hook ingress priority filter\; devices = { lan, wan }\; }
fi

if ! nft list chain inet global forward | grep -q flow; then
    nft insert rule inet global forward ip protocol { tcp, udp } flow offload @f
    nft insert rule inet global forward ip6 nexthdr { tcp, udp } flow offload @f
fi
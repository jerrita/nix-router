# for 192.168.x.1, LAN_ID is the x
LAN_ID ?= 5

all: repo dns

.PHONY: repo dns
repo:
	if [ ! -d dnsmasq-china-list ]; then \
		git clone https://github.com/felixonmars/dnsmasq-china-list --depth=1; \
	else \
		cd dnsmasq-china-list && git pull; \
	fi

dns: repo
	cd dnsmasq-china-list && make SERVER=127.0.0.1#5353 dnsmasq
	mv dnsmasq-china-list/*.dnsmasq.conf static/etc/dnsmasq.d

lan:
	@echo off
	echo "Your network is 192.168.$(LAN_ID).0/24"
	echo "Patching nix files..."
	sed -i 's/192.168.[0-9]\{1,3\}.1\/24/192.168.$(LAN_ID).1\/24/' networking/network.nix

	echo "Patching static files..."
	sed -i 's/192.168.[0-9]\{1,3\}.1:9090/192.168.$(LAN_ID).1:9090/' static/etc/clash/config.yaml
	sed -i 's/192.168.[0-9]\{1,3\}./192.168.$(LAN_ID)./g' static/etc/dnsmasq.conf
	sed -i 's/192.168.[0-9]\{1,3\}./192.168.$(LAN_ID)./' static/etc/firewall.nft

	echo "done."

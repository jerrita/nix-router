run: dns

repo:
	if [ ! -d dnsmasq-china-list ]; then \
		git clone https://github.com/felixonmars/dnsmasq-china-list --depth=1; \
	else \
		cd dnsmasq-china-list && git pull; \
	fi

dns: repo
	cd dnsmasq-china-list && make SERVER=127.0.0.1#5353 dnsmasq
	mv dnsmasq-china-list/*.dnsmasq.conf static/dnsmasq

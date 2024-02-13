run: install

repo:
	git clone https://github.com/felixonmars/dnsmasq-china-list --depth=1

dns:
	cd dnsmasq-china-list && make SERVER=127.0.0.1#5353 dnsmasq
	mv dnsmasq-china-list/*.dnsmasq.conf rules

update:
	cd dnsmasq-china-list && git pull
	@echo "Updated. Please run 'make run' to generate new config file."

install:
	rm -rf /etc/dnsmasq.d
	cp -r rules /etc/dnsmasq.d
	rm -rf /etc/scripts
	cp -r scripts /etc
	chown -R clash:clash /etc/scripts
	
#!/usr/bin/env bash
set -e
PATH=$PATH:/run/current-system/sw/bin

if [ ! -d /opt/cndns ]; then
    echo "Cloning cndns..."
    git clone https://github.com/felixonmars/dnsmasq-china-list /opt/cndns --depth=1
    cd /opt/cndns
else
    echo "Updating cndns..."
    cd /opt/cndns
    git pull
fi

echo "Updating..."
make SERVER=127.0.0.1#5353 dnsmasq
cp *.dnsmasq.conf /etc/dnsmasq.d/

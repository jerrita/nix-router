{ config, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        vim
        git
        wget
        curl
        unzip

        pciutils
        ethtool
        tcpdump
        tree

        htop
        iotop
        iproute2
        iperf3
        dnsutils
        traceroute
        mtr
        lsof
        proxychains

        tmux
        gnumake

        python312
    ];
}
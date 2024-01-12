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
        inetutils
        lsof
        proxychains
        screenfetch

        tmux
        gnumake

        python312
    ];
}
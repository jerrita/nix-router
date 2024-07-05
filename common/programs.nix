{ config, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        neovim
        git
        lazygit
        wget
        curl
        unzip

        pciutils
        ethtool
        tcpdump
        tree
        file

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
        nload
        sysstat
        s-tui
        pstree

        tmux
        screen
        gnumake
        socat
        wireguard-tools
    ];
}

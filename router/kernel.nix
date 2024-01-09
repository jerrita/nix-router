{ config, pkgs, ... }:
{
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernel.sysctl = {
        "net.ipv4.conf.all.forwarding" = true;
        "net.ipv6.conf.all.forwarding" = true;
        
        "net.ipv6.conf.all.accept_ra" = 2;
        "net.ipv6.conf.all.autoconf" = 1;
    };

    boot.kernelPackages = pkgs.linuxPackages_latest;
}
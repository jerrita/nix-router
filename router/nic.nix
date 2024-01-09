{ config, pkgs, ... }:
{
    # https://nixos.org/manual/nixos/stable/#sec-rename-ifs
    systemd.network.links = {
        "10-wan" = {
            matchConfig.PermanentMACAddress = "1c:83:41:40:c1:01";
            linkConfig.Name = "wan";
        };
        "10-lan" = {
            matchConfig.PermanentMACAddress = "bc:24:11:b1:58:29";
            linkConfig.Name = "lan";
        };
    };
}
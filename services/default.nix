{ config, pkgs, ... }:
{
    imports = [
        ./offload.nix
        ./cron.nix
        # ./clash-tun.nix     # user tun
        # ./sing.nix          # has issues on router
        ./clash.nix           # use redir and tproxy
        ./zerotier.nix
        ./ddns.nix
        ./upnp.nix
        ./vscode.nix
    ];
}
{ config, pkgs, ... }:
{
    imports = [
        ./offload.nix
        ./cron.nix
        ./clash.nix
        # ./sing.nix
        # ./zerotier.nix
        # ./ddns.nix
        # ./upnp.nix
        # ./vscode.nix
        # ./ss.nix
        # ./fail2ban.nix
        # ./wireguard.nix
    ];
}

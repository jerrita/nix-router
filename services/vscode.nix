{ config, pkgs, ... }:
{
    import = [
        ../modules/vscode-ssh-fix.nix
    ];

    services.nixos-vscode-ssh-fix.enable = true;
}
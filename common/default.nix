{ config, pkgs, ... }:
{
    imports = [
        ./shell.nix
        ./programs.nix
    ];
}
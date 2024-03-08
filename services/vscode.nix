{ config, pkgs, ... }:
{
    imports = [
        (fetchTarball {
            url = "https://github.com/nix-community/nixos-vscode-server/tarball/master";
            sha256 = "1mrc6a1qjixaqkv1zqphgnjjcz9jpsdfs1vq45l1pszs9lbiqfvd";
        })
    ];

    services.vscode-server.enable = true;
}
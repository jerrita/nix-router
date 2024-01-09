{
    description = "Jerrita's Router Flake";

    nixConfig = {
        experimental-features = [ "nix-command" "flakes" ];
        substituters = [
            "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
            "https://cache.nixos.org"
        ];
    };

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        # nixpkgs.url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git?ref=nixos-unstable";
        scripts = {
            url = "github:jerrita/scripts";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    };

    outputs = { self, nixpkgs, scripts, utils, ... } @ inputs:
        utils.lib.mkFlake 
    {
        inherit self inputs;
        channels.unstable.input = nixpkgs;
        channels.unstable.patches = [
            ./patches/miniupnpd.patch
            ./patches/order.patch
        ];

        hosts.router = {
            system = "x86_64-linux";
            channelName = "unstable";
            modules = [
                ./router
                scripts.nixosModules.ddns
            ];
        };
    };
}
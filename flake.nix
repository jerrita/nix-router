{
    description = "Jerrita's Router Flake";

    nixConfig = {
        experimental-features = [ "nix-command" "flakes" ];
        substituters = [
            "https://mirrors.ustc.edu.cn/nix-channels/store"
            "https://cache.nixos.org"
        ];
        allowUnfree = true;
    };

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        scripts = {
            url = "github:jerrita/scripts";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    };

    # outputs = { self, nixpkgs, scripts } @ inputs: 
    # let 
    #     pkgs = import nixpkgs { allowUnfree = true; };
    # in rec {
    #     nixosConfigurations.r2s = nixpkgs.lib.nixosSystem {
    #         system = "aarch64-linux";
    #         specialArgs = {inherit nixpkgs;};
    #         modules = [
    #             ./hardware/r2s.nix
    #             ./router
    #             scripts.nixosModules.ddns
    #         ];
    #     };
    #     nixosConfigurations.esxi = nixpkgs.lib.nixosSystem {
    #         system = "x86_64-linux";
    #         specialArgs = {inherit nixpkgs;};
    #         modules = [
    #             ./hardware/esxi.nix
    #             ./router
    #             scripts.nixosModules.ddns
    #         ];
    #     };
    # };

    outputs = { self, nixpkgs, scripts, utils, ... } @ inputs:
        utils.lib.mkFlake 
    {
        inherit self inputs;

        channelsConfig.allowUnfree = true;
        hostDefaults.modules = [ 
            ./router
            scripts.nixosModules.ddns
        ];

        channels.patched.input = nixpkgs;
        # channels.patched.patches = [ ];

        hosts.esxi = {
            system = "x86_64-linux";
            channelName = "patched";
            modules = [
                ./hardware/esxi.nix
            ];
        };
    };
}

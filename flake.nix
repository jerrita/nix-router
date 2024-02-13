{
    description = "Jerrita's Router Flake";

    nixConfig = {
        experimental-features = [ "nix-command" "flakes" ];
        substituters = [
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
        # utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    };

    outputs = { self, nixpkgs, scripts } @ inputs: 
    let 
        pkgs = import nixpkgs { config.allowUnfree = true; };
    in rec {
        nixosConfigurations.r2s = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            specialArgs = {inherit nixpkgs;};
            modules = [
                ./hardware/r2s.nix
                ./router
                scripts.nixosModules.ddns
            ];
        };
        nixosConfigurations.esxi = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {inherit nixpkgs;};
            modules = [
                ./hardware/esxi.nix
                ./router
                scripts.nixosModules.ddns
            ];
        };
    };

    # outputs = { self, nixpkgs, scripts, utils, ... } @ inputs:
    #     utils.lib.mkFlake 
    # {
    #     inherit self inputs;
    #     channels.unstable.input = nixpkgs;
    #     channels.unstable.patches = [
    #         # ./patches/miniupnpd.patch
    #         # ./patches/r8168.patch
    #     ];
    #     hosts.r2s = {
    #         system = "aarch64-linux";
    #         channelName = "unstable";
    #         modules = [
    #             "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    #             ./router
    #             scripts.nixosModules.ddns
    #         ];
    #     };
    #     images.rouetr = hosts.router.config.system.build.sdImage;
    # };
}

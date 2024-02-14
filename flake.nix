{
    description = "Jerrita's Router Flake";

    nixConfig = {
        experimental-features = [ "nix-command" "flakes" ];
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
    in {
        nixosConfigurations.router = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [ 
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
    #         ./patches/nft-flatten.patch
    #     ];
    #     hosts.router = {
    #         system = "x86_64-linux";
    #         channelName = "unstable";
    #         modules = [
    #             ./router
    #             scripts.nixosModules.ddns
    #         ];
    #     };
    # };
}

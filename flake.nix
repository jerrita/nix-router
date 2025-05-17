{
  description = "Jerrita's Router Flake";

  nixConfig = {
    experimental-features = ["nix-command" "flakes"];
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
    extra-substituters = [
      "https://jerrita.cachix.org"
    ];
    extra-trusted-public-keys = [
      "jerrita.cachix.org-1:nuNrOWU7/dWbGwwE5bwUfvycsiPHb5NnD/aIZIcaPDI="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    # scripts = {
    #   url = "github:jerrita/scripts";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
  };

  outputs = {
    self,
    nixpkgs,
  } @ inputs: rec {
    nixosConfigurations.r2s = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = {inherit nixpkgs;};
      modules = [
        ./hardware/r2s.nix
        ./router
      ];
    };
    images.r2s = nixosConfigurations.r2s.config.system.build.sdImage;

    nixosConfigurations.esxi = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit nixpkgs;};
      modules = [
        ./hardware/esxi.nix
        ./router
        # scripts.nixosModules.ddns
      ];
    };

    nixosConfigurations.pve = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit nixpkgs;};
      modules = [
        ./hardware/pve.nix
        ./router
        # scripts.nixosModules.ddns
      ];
    };
    formatter."aarch64-darwin" = nixpkgs.legacyPackages."aarch64-darwin".alejandra;
    formatter."x86_64-linux" = nixpkgs.legacyPackages."x86_64-linux".alejandra;
  };
}

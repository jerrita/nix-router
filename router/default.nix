{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    ./kernel.nix

    ./dial/dhcp.nix

    ../common
    ../networking
    ../services
    ../daemon
  ];

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
  };

  documentation = {
    man.enable = true;
    dev.enable = false;
    doc.enable = false;
    nixos.enable = false;
  };

  networking.hostName = lib.mkDefault "router";
  time.timeZone = "Asia/Shanghai";

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINu+Alullj1Meq+a3KNFlIT9lU9YCb8WDr/mZhHCEPji jerrita@mac-air"
  ];
  system.stateVersion = "24.05";
}

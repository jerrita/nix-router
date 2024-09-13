{
  pkgs,
  lib,
  modulesPath,
  proxmoxLXC,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    # (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ./hardware-configuration.nix
  ];

  nix.settings.substituters = lib.mkForce ["https://mirrors.ustc.edu.cn/nix-channels/store"];
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # If you use the lxc, uncomment this
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "router";
  time.timeZone = "Asia/Shanghai";

  environment.systemPackages = with pkgs; [
    vim
    git
    gnumake
  ];

  services.openssh.enable = true;
  system.stateVersion = "24.05";
}

{ pkgs, lib, modulesPath, proxmoxLXC, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking.hostName = "router";
  time.timeZone = "Asia/Shanghai";

  environment.systemPackages = with pkgs; [
    vim
    git
    gnumake
  ];

  system.stateVersion = "23.11";
}

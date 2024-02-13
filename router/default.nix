{ config, pkgs, lib, modulesPath, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      (modulesPath + "/virtualisation/proxmox-lxc.nix")
      ./kernel.nix
      ./nic.nix
      ./dial/pppoe.nix
      # ./dial/dhcp.nix

      ../common
      ../networking
      ../services
    ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  proxmoxLXC.manageNetwork = true;

  networking.hostName = "router";
  time.timeZone = "Asia/Shanghai";

  services.openssh.enable = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "23.11";
}

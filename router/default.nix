{ config, pkgs, lib, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./kernel.nix
      ./nic.nix
      ./dial/pppoe.nix
      # ./dial/dhcp.nix

      ../common
      ../networking
      ../services
    ];

  # nix.settings.substituters = [ 
  #   "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
  #   "https://cache.nixos.org"
  # ];
  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking.hostName = "router";
  time.timeZone = "Asia/Shanghai";

  services.openssh.enable = true;
  services.qemuGuest.enable = true;
  system.stateVersion = "23.11";
}

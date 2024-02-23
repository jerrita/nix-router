# 37: lan, 33: wan
{ config, lib, pkgs, modulesPath, ... }:
let
  tuningScript = pkgs.writeScript "tuning" ''
    #!/usr/bin/env bash
    mkdir -p /etc/clash
    if [ -f /etc/init.sh ]; then
      echo "Run /etc/init.sh..."
      bash /etc/init.sh
    fi
  '';
in {
  imports = [ ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [ "ata_piix" "vmw_pvscsi" "ahci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  # boot.extraModulePackages = with config.boot.kernelPackages; [ r8168 ];
  # boot.blacklistedKernelModules = [ "r8169" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/2d272700-f3bd-4a3b-9e77-08da2dd442a9";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/DC66-AB97";
      fsType = "vfat";
    };

  swapDevices = [ ];

  zramSwap = {
    enable = true;
    memoryPercent = 150;
  };

  boot.kernel.sysctl = {
    "vm.swapiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };

  systemd.services.tuning = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = [ pkgs.bash ];
    serviceConfig = {
        Type = "oneshot";
        ExecStart = "${tuningScript}";
    };
  };

  systemd.network.links = {
    # "10-wan" = {  # UsbNetwork
    #     matchConfig.PermanentMACAddress = "00:0c:29:85:39:93";
    #     linkConfig.Name = "wan";
    # };
    "10-wan" = {   # Phy
        matchConfig.PermanentMACAddress = "1c:83:41:40:c1:01";
        linkConfig.Name = "wan";
    };
    "10-vmnet" = {
        matchConfig.PermanentMACAddress = "00:0c:29:85:39:89";
        linkConfig.Name = "lan";
    };
    # "10-r8168" = {
    #     matchConfig.PermanentMACAddress = "1c:83:41:40:c1:00";
    #     linkConfig.Name = "intern1";
    # };
  };

  # networking.bridges.lan = {
  #   rstp = true;
  #   interfaces = [ "intern0" "intern1" ];
  # };

  virtualisation.vmware.guest.enable = true;
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.ens33.useDHCP = lib.mkDefault true;
  # networking.interfaces.ens37.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
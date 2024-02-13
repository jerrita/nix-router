# 37: lan, 33: wan
{ config, lib, pkgs, modulesPath, ... }:
let
  tuningScript = pkgs.writeScript "tuning" ''
    #!/usr/bin/env bash
    mkdir -p /etc/clash
    chown -R clash:clash /etc/clash
    if [ -f /etc/init.sh ]; then
      echo "Run /etc/init.sh..."
      bash /etc/init.sh
    fi
  '';
in {
  imports = [ ];

  boot.initrd.availableKernelModules = [ "ata_piix" "vmw_pvscsi" "ahci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/2d272700-f3bd-4a3b-9e77-08da2dd442a9";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/DC66-AB97";
      fsType = "vfat";
    };

  swapDevices = [ ];

  systemd.services.tuning = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
        Type = "oneshot";
        ExecStart = "${tuningScript}";
    };
  };

  systemd.network.links = {
    "10-wan" = {
        matchConfig.PermanentMACAddress = "00:0c:29:85:39:93";
        linkConfig.Name = "wan";
    };
    "10-lan" = {
        matchConfig.PermanentMACAddress = "00:0c:29:85:39:89";
        linkConfig.Name = "lan";
    };
  };

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
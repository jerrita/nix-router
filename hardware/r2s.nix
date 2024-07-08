{ config, pkgs, lib, ... }: 
let
  tuningScript = pkgs.writeScript "tuning" ''
    #!/usr/bin/env bash
    # wan: 24, lan: 47
    mkdir -p /etc/clash
    chown -R clash:clash /etc/clash
    echo 8 > /proc/irq/24/smp_affinity
    echo 2 > /proc/irq/47/smp_affinity
    echo 7 > /sys/class/net/wan/queues/rx-0/rps_cpus
    echo d > /sys/class/net/lan/queues/rx-0/rps_cpus
    echo 2048 > /sys/class/net/wan/queues/rx-0/rps_flow_cnt
    echo 2048 > /sys/class/net/lan/queues/rx-0/rps_flow_cnt
    ethtool -G lan tx 1024
    ethtool -G lan rx 1024
    ethtool -G wan rx 4096
  '';
in {
  imports = [ 
    # ../modules/extlinux.nix
    ../modules/r2s-image.nix
  ];

  # system.enableExtlinuxTarball = true;
  networking.useDHCP = lib.mkDefault true;

  zramSwap = {
    enable = true;
    memoryPercent = 150;
  };

  boot.kernel.sysctl = {
    "vm.swapiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;

    "vm.vfs_cache_pressure" = 10;
    "vm.dirty_ratio" = 50;

    "net.core.rps_sock_flow_entries" = 32768;
    "net.core.dev_weight" = 600;
  };

  nixpkgs.overlays = [(final: super: {
    zfs = super.zfs.overrideAttrs(_: {
      meta.platforms = [];
    });
  })];

  systemd.services.tuning = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = [ pkgs.bash pkgs.ethtool ];
      serviceConfig = {
          Type = "oneshot";
          ExecStart = "${tuningScript}";
      };
  };

  hardware.deviceTree.name = "rockchip/rk3328-nanopi-r2s.dtb";

  # NanoPi R2S's DTS has not been actively updated, so just use the prebuilt one to avoid rebuilding
  hardware.deviceTree.package = pkgs.lib.mkForce (
    pkgs.runCommand "dtbs-nanopi-r2s" { } ''
      install -TDm644 ${./files/r2s-overclock.dtb} $out/rockchip/rk3328-nanopi-r2s.dtb
    ''
  );

  hardware.firmware = [
    (pkgs.runCommand
      "linux-firmware-r8152"
      { }
      ''
        install -TDm644 ${./files/rtl8153a-4.fw} $out/lib/firmware/rtl_nic/rtl8153a-4.fw
        install -TDm644 ${./files/rtl8153b-2.fw} $out/lib/firmware/rtl_nic/rtl8153b-2.fw
      ''
    )
  ];

  boot = {
    loader = {
      timeout = 1;
      grub.enable = false;
      generic-extlinux-compatible = {
        enable = true;
        configurationLimit = 15;
      };
    };

    supportedFilesystems = [ "ext4" "vfat" ];
    kernelParams = [
      "console=ttyS2,1500000"
      "earlycon=uart8250,mmio32,0xff130000"
      "mitigations=off"
    ];
    initrd = {
      includeDefaultModules = false;
    };
    blacklistedKernelModules = [ "hantro_vpu" "drm" "lima" "videodev" ];
    tmp.useTmpfs = true;
  };

  powerManagement.cpuFreqGovernor = "schedutil";

  systemd.network.links = {
      "10-wan" = {
          # ff600000.usb/xhci-hcd.0.auto/usb5/5-1/5-1:1.0/net/enu1
          # matchConfig.Path = "platform-ff600000.usb";
          matchConfig.Driver = "r8152";
          linkConfig.Name = "wan";
      };
      "10-lan" = {
          matchConfig.Path = "platform-ff540000.ethernet";
          linkConfig.Name = "lan";
      };
  };

  services.lvm.enable = false;
  services.timesyncd.extraConfig = ''
    PollIntervalMinSec=16
    PollIntervalMaxSec=180
    ConnectionRetrySec=3
  '';

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # systemd.services."wait-system-running" = {
  #   description = "Wait system running";
  #   serviceConfig = { Type = "simple"; };
  #   script = ''
  #     systemctl is-system-running --wait
  #   '';
  # };

  systemd.services."setup-net-leds" = {
    description = "Setup network LEDs";
    serviceConfig = { Type = "simple"; };
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    script = ''
      cd /sys/class/leds/nanopi-r2s:green:lan
      echo netdev > trigger
      echo 1 | tee link tx rx >/dev/null
      echo lan > device_name

      cd /sys/class/leds/nanopi-r2s:green:wan
      echo netdev > trigger
      echo 1 | tee link tx rx >/dev/null
      echo wan > device_name
    '';
  };
  systemd.services."setup-sys-led" = {
    description = "Setup booted LED";
    requires = [ "wait-system-running.service" ];
    after = [ "wait-system-running.service" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      echo default-on > /sys/class/leds/nanopi-r2s:red:sys/trigger
    '';
  };
}

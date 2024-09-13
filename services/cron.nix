{
  config,
  pkgs,
  ...
}: {
  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 3 * * * root ${pkgs.coreutils}/bin/sync; echo 3 > /proc/sys/vm/drop_caches"
      "0 3 * * * root ${pkgs.coreutils}/bin/truncate -s 0 /var/log/*"
      "0 3 * * 0 root ${pkgs.systemd}/bin/journalctl --vacuum-time=7d"
    ];
  };
}

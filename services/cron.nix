{ config, pkgs, ... }:
{
    services.cron = {
        enable = true;
        systemCronJobs = [
            # drop caches each day at 03:00
            "0 3 * * * root ${pkgs.coreutils}/bin/sync; echo 3 > /proc/sys/vm/drop_caches"
            # truncate logs each day at 03:00
            "0 3 * * * root ${pkgs.coreutils}/bin/truncate -s 0 /var/log/*"
        ];
    };
}

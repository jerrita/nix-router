{ config, lib, pkgs, ... }:
{
    systemd.services."router-earlyup" = {
        description = "NixRouter early up | File registration";
        serviceConfig = { Type = "oneshot"; };
        wantedBy = [ "multi-user.target" ];
        before = [ "network-online.target" ];
        script = ''
            if [ ! -d /daemon ]; then
                echo "First boot, copying files..."
                cp -R ${../static}/* /
            else
                echo "Not first boot, skip..."
            fi
        '';
    };
    systemd.services."router-daemon" = {
        description = "NixRouter | Daemon";
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        path = [ pkgs.bash ];
        serviceConfig = {
            Type = "simple";
            ExecStart = "/daemon";
            Restart = "on-failure";
        };
    };
}

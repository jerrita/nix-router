{ config, pkgs, ... }:
let
    settings = builtins.fromJSON (builtins.readFile ../static/sing.json);
    preStartScript = lib.writeScript "preStart.sh" ''
        #!/usr/bin/env bash
        set -e
        sed -i 's/server=127.0.0.1#5353/server=127.0.0.1#5355/g' /etc/special.conf
        systemctl restart dnsmasq
    '';
    postStopScript = lib.writeScript "postStop.sh" ''
        #!/usr/bin/env bash
        set -e
        sed -i 's/server=127.0.0.1#5355/server=127.0.0.1#5353/g' /etc/special.conf
        systemctl restart dnsmasq
    '';
in {
    services.sing-box = {
        enable = true;
        settings = settings;
    };
    systemd.services.sing-box.serviceConfig = {
        ExecStartPre = "${pkgs.coreutils}/bin/sh ${preStartScript}";
        ExecStopPost = "${pkgs.coreutils}/bin/sh ${postStopScript}";
    };
}
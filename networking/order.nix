{ config, pkgs, lib, ... }:
let
    onlineScript = pkgs.writeScript "wait-online" ''
        #!/usr/bin/env bash
        # until ping -c 1 223.5.5.5; do sleep 1; done
        timeout 50s bash -c 'until ping -c 1 223.5.5.5; do sleep 1; done'
    '';
in {
    systemd.services.wait-online = {
        wantedBy = [ "network-online.target" ];
        before = [ "network-online.target" ];
        path = [ pkgs.iputils pkgs.bash pkgs.coreutils ];
        serviceConfig = {
            Type = "oneshot";
            ExecStart = "${onlineScript}";
            RemainAfterExit = true;
        };
    };
    systemd.services.dhcpcd = {
        wantedBy = lib.mkForce [ "network-online.target" ];
        wants = lib.mkForce [ "network-online.target" ];
        after = lib.mkForce [ "network-online.target" ];
        before = lib.mkForce [ ];
    };
}
{ config, pkgs, ... }:
{
    services.pppd = {
    enable = true;
    peers = {
        telecom = {
            autostart = true;
            enable = true;
            config = ''
                plugin pppoe.so wan

                nic-wan
                
                name ""
                password ""

                persist
                maxfail 0
                holdoff 5

                +ipv6
                noipdefault
                defaultroute
                usepeerdns
                replacedefaultroute
            '';
        };
    };
    };
}
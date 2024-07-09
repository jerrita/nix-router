{ config, pkgs, ... }:
{
    networking.wg-quick.interfaces = {
        wg0 = {
            address = [
                ""
            ];
            peers = [
                {
                    allowedIPs = [
                        ""
                    ];
                    endpoint = "";
                    publicKey = "";
                }
            ];
            privateKey = "";
        };
    };
}

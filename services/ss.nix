{ pkgs, ... }:
{
    services.shadowsocks = {
        enable = false;
        port = 114514;
        password = "1919810";
        encryptionMethod = "chacha20-ietf-poly1305";
        extraConfig = {
            nameserver = "192.168.5.1";
        };
    };
}

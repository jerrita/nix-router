{
  config,
  pkgs,
  ...
}: {
  systemd.services.wireguard = {
    wantedBy = ["multi-user.target"];
    wants = ["network-online.target"];
    after = ["network.target" "network-online.target"];
    description = "Wireguard Service";
    path = with pkgs; [wireguard-tools];
    serviceConfig = {
      Type = "oneshot";
      PrivateTmp = true;
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.kmod}/bin/modprobe wireguard
      mkdir -p /etc/wireguard
      for conf in /etc/wireguard/*.conf; do
          interface=$(basename $conf .conf)
          wg-quick up $interface
      done
    '';
    preStop = ''
      for conf in /etc/wireguard/*.conf; do
          interface=$(basename $conf .conf)
          wg-quick down $interface
      done
    '';
  };
  environment.systemPackages = [pkgs.wireguard-tools];
}

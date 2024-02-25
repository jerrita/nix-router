{ config, pkgs, ... }:
{
    boot.kernel.sysctl = {
        "net.ipv4.ip_forward" = 1;
        "net.ipv4.conf.all.forwarding" = true;
        "net.ipv6.conf.all.forwarding" = true;
        
        "net.ipv6.conf.all.accept_ra" = 2;
        "net.ipv6.conf.all.autoconf" = 1;

        # tcp tuning
        "net.core.somaxconn" = 65536;
        "net.ipv4.tcp_low_latency" = 1;
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.ipv4.tcp_fastopen" = 3;
        "net.ipv4.tcp_syncookies" = 1;
        "net.ipv4.tcp_syn_retries" = 2;
        "net.ipv4.tcp_synack_retries" = 2;

        "net.ipv4.tcp_max_tw_buckets" = 5000;
        "net.ipv4.tcp_tw_recycle" = 1;
        "net.ipv4.tcp_fin_timeout" = 15;
        "net.ipv4.tcp_slow_start_after_idle" = false;

        # net mem
        "net.ipv4.tcp_window_scaling" = true;
        "net.core.rmem_default" = 1048576;
        "net.core.wmem_default" = 1048576;
        "net.core.rmem_max" = 16777216;
        "net.core.wmem_max" = 16777216;
        "net.ipv4.tcp_rmem" = "4096 87380 2097152";
        "net.ipv4.tcp_wmem" = "4096 65536 16777216";
        "net.core.optmem_max" = 65536;
        "net.ipv4.udp_rmem_min" = 8192;
        "net.ipv4.udp_wmem_min" = 8192;
        "net.core.netdev_max_backlog" = 50000;

        "net.netfilter.nf_conntrack_checksum" = 0;
        "net.netfilter.nf_conntrack_max" = 200000;
    };
}
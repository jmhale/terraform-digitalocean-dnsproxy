#!/bin/bash
##BEGIN

## Update apt cache, install sniproxy and bind
sudo add-apt-repository -y ppa:dlundquist/sniproxy
apt-get -y update
apt-get install -y sniproxy bind9

## sniproxy config
cat << EOF > /etc/sniproxy.conf
user daemon
pidfile /var/run/sniproxy.pid

error_log {
    filename /var/log/sniproxy/sniproxy.log
    priority notice
}

listen 80 {
    proto http
    table http_hosts
    access_log {
        filename /var/log/sniproxy/http_access.log
        priority notice
    }
}

listen 443 {
    proto tls
    table https_hosts
    access_log {
        filename /var/log/sniproxy/https_access.log
        priority notice
    }
}

table http_hosts {
    .* *
}

table https_hosts {
    .* *
}

table {
   .* *
}
EOF


## named configs
cat << EOF > /etc/bind/named.conf
include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
include "/etc/bind/named.conf.default-zones";
EOF

cat << EOF > /etc/bind/named.conf.local
acl "trusted" {
    any;
};
include "/etc/bind/zones.override";
EOF

cat << EOF > /etc/bind/named.recursion.conf
allow-recursion { trusted; };
recursion yes;
additional-from-auth yes;
additional-from-cache yes;
EOF

## Set BIND forwarders
cat << EOF > /etc/bind/named.conf.options
options {
        directory "/var/cache/bind";

        forwarders {
            2620:fe::fe;
            9.9.9.9;
        };

        dnssec-validation auto;

        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };

        allow-query { trusted; };
        allow-transfer { none; };

        include "/etc/bind/named.recursion.conf";
};
EOF

## Set DNS lookup information for overridden queries
cat << EOF > /etc/bind/db.override
\$TTL  86400

@   IN  SOA ns1 root (
            2016061801  ; serial
            604800      ; refresh 1w
            86400       ; retry 1d
            2419200     ; expiry 4w
            86400       ; minimum TTL 1d
            )

    IN  NS  ns1

ns1 IN  A   127.0.0.1
@   IN  A   ${dns_ip_1}
@   IN  A   ${dns_ip_2}
*   IN  A   ${dns_ip_1}
*   IN  A   ${dns_ip_2}
EOF

## Set zones to override
cat << EOF > /etc/bind/zones.override
zone "mlb.tv." { type master; file "/etc/bind/db.override"; };
zone "mlb.com." { type master; file "/etc/bind/db.override"; };
zone "mlbstatic.com." { type master; file "/etc/bind/db.override"; };
zone "milb.com." { type master; file "/etc/bind/db.override"; };
zone "mlbam.net." { type master; file "/etc/bind/db.override"; };
zone "bamstatic.com." { type master; file "/etc/bind/db.override"; };
zone "bamgrid.com." { type master; file "/etc/bind/db.override"; };
zone "bamnetworks.com." { type master; file "/etc/bind/db.override"; };
zone "ticketing-client.com." { type master; file "/etc/bind/db.override"; };
zone "conviva.com." { type master; file "/etc/bind/db.override"; };
zone "livefyre.com." { type master; file "/etc/bind/db.override"; };
zone "krxd.net." { type master; file "/etc/bind/db.override"; };
zone "icanhazip.com." { type master; file "/etc/bind/db.override"; };
EOF

## Enable services on boot and start
update-rc.d bind9 defaults
update-rc.d sniproxy defaults

service bind9 restart
sniproxy
curl -sSL https://agent.digitalocean.com/install.sh | sh
##END

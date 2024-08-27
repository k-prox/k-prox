#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# vim: filetype=bash


_apt_install() {
env DEBIAN_FRONTEND=noninteractive apt-get -y install --no-upgrade \
        -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" "$@"
}


. /etc/os-release

case $VERSION_CODENAME in
#### ubuntu:
jammy)  true  ;;
focal)  true  ;;
noble) true  ;;
bullseye) true  ;;
bookworm) true  ;;
#### debian:
*)      
    echo "= Openvpn server installation not supported on OS $VERSION_CODENAME"
    exit 22 ;;
esac

INDICATOR_COMPLETED=/etc/openvpn/.proxysmart.conf.completed

if test -f $INDICATOR_COMPLETED
then echo "Openvpn integration already ready, if you want to reinstall, delete $INDICATOR_COMPLETED and rerun. Now exit"
    exit
else

############ read conf
test -f /etc/proxysmart/conf.txt && \
    eval "$( cat /etc/proxysmart/conf.txt | grep -vP '^\s*#' | tr -d '`' | sed -r '/[^=]+=[^=]+/!d' | sed -r 's/\s+=\s/=/g' )"

for F in $(find /etc/proxysmart/conf.d/*inc 2>/dev/null)
do
    eval "$( cat $F | grep -vP '^\s*#' | tr -d '`' | sed -r '/[^=]+=[^=]+/!d' | sed -r 's/\s+=\s/=/g' )"
done

# read YAML 
eval "$(/usr/share/proxysmart/helpers/print_settings.py | grep -vP '^\s*#' | tr -d '`' | sed -r '/[^=]+=[^=]+/!d' | sed -r 's/\s+=\s/=/g' )"
##########

if [[ $OPENVPN_INTEGRATION != 1 ]]
then 
    echo "set OPENVPN_INTEGRATION=1 beforehand, exit now"
    exit 2
fi

if [[ -z $OPENVPN_SERVER_HOST ]]
then
    if [[ -n $VPS ]]
    then OPENVPN_SERVER_HOST=$VPS
        echo "= OPENVPN_SERVER_HOST not set, so using VPS variable for it"
    else
        echo "= OPENVPN_SERVER_HOST and VPS are not set, using LAN IP " 
        LAN_IP=`ip ro get 1.1.1.1 | grep -oP '(?<= src )\S+' | head -n1`
        OPENVPN_SERVER_HOST=$LAN_IP
    fi
fi

if [[ -z $OPENVPN_SERVER_PORT ]]
then
    echo "set OPENVPN_SERVER_PORT "
    exit 2
fi


set -e
set -x

_apt_install zip openvpn tofrodos easy-rsa ntpdate
mkdir -p  /etc/openvpn/ccd
rm -rf /etc/openvpn/easy-rsa/

case $VERSION_CODENAME in
*)
    make-cadir /etc/openvpn/easy-rsa/
    ;;
esac

cd /etc/openvpn/easy-rsa/


sed -i "s/.*set_var EASYRSA_CRL_DAYS.*/set_var EASYRSA_CRL_DAYS   3650/"    vars
sed -i "s/.*set_var EASYRSA_CERT_EXPIRE.*/set_var EASYRSA_CERT_EXPIRE   3650/"    vars
case $VERSION_CODENAME in
bookworm)   : ;;
*)  sed -i "s/.*set_var EASYRSA_REQ_CN.*/set_var EASYRSA_REQ_CN \"ProxysmartVPN\"/"    vars ;;
esac


grep EASYRSA_CRL_DAYS vars
grep EASYRSA_CERT_EXPIRE vars
grep EASYRSA_REQ_CN vars || true # on noble it is not set..

mkdir -p pki
./easyrsa --batch clean-all

#./easyrsa gen-dh
echo "-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEApJQ2mn+4VNwU0WPYL2VwOqtowXjkG9S75ixi7xtn/r+wEZIAzIK4
A/DB4hyblqpOPgy1bZRv95DQgd9+Vb9YYv4XvFoT0lDWSSfR54jj9z6TWrzaAtNZ
qBAzEP/aAZdewf6DkDNU9UfIsNScnZTwjwJ8QTjJopRcBP1BLDhIWEnBLiE1lxn9
xJpU8v0s8imK3YhS/h0N8kxOYKaINqfMD/r2RA0AM3LXllNNzrWo9vTOR8xuuj09
A4fxRUg9cc5kn7lo9TmV1ulNwmOY8N2Aajorpq2416OULKFXHNBOuGSW991mjPP2
En55Tg36OmNobgST5BY/bMIltiRuuHO++wIBAg==
-----END DH PARAMETERS-----" > pki/dh.pem

ln -sf ../vars pki/vars
ln -sf ../openssl-easyrsa.cnf pki/openssl-easyrsa.cnf

case $VERSION_CODENAME in
bookworm)
    rm ./pki/vars
    mv vars pki/vars
    ;;
esac

case $VERSION_CODENAME in
noble|bullseye|bookworm)
    env EASYRSA_REQ_CN='Proxysmart VPN' ./easyrsa --batch build-ca nopass
    ;;
*)
    ./easyrsa --batch build-ca nopass
    ;;
esac

./easyrsa --batch build-server-full server  nopass

./easyrsa gen-crl
openssl crl  -text -noout -in  pki/crl.pem  | grep 'Next Update'

mkdir keys -p

#NEW: openvpn --genkey secret keys/ta.key
#OLD: openvpn --genkey keys/ta.key

echo '#
# 2048 bit OpenVPN static key
#
-----BEGIN OpenVPN Static key V1-----
013de1b6ec312ab7f54a15418cc0015c
29ad561ed95e7fae5898815e1d910bc7
80e07c23918b16fca17607e1c68ce6b6
229de695ce6a134fd26df739b54aebc8
57c87d1539b4ad0524a23ef7d4092e28
f4baf833287e336c6a4ac2ab6252bfc8
f688efc0691bfb9037d8a8e86cfaf29e
8a44abc32473ce810b3870084d6d5adf
2c3ead804da65a5068f2d4f327fdc361
b536dc6b74fd6cdaf63752eb62264521
d25a20973c6c23d6d414c92ce1ccdbb7
057203b510c02547668e3761e6e245e4
8df31a79c48721c90cde62978e42d235
102d8dc256a4915121185beddf4e1e2f
92aa34e9b94fec7acdd1bd66a6cf239f
5a2a4b7227411613dcd2d3c35e6d9b15
-----END OpenVPN Static key V1-----
' > keys/ta.key

cd ../


echo '

server 172.22.27.0 255.255.255.0    nopool
ifconfig-pool 172.22.27.100 172.22.27.200
topology subnet

management /var/run/openvpn/server.management.socket unix

client-config-dir /etc/openvpn/ccd
client-connect client-connect.sh
client-disconnect client-disconnect.sh
up up.sh
auth-user-pass-verify client-verify-password.sh via-file
script-security 2

port 1194
proto tcp
dev tun
ca          /etc/openvpn/easy-rsa/pki/ca.crt
cert        /etc/openvpn/easy-rsa/pki/issued/server.crt
key         /etc/openvpn/easy-rsa/pki/private/server.key
dh          /etc/openvpn/easy-rsa/pki/dh.pem
crl-verify  /etc/openvpn/easy-rsa/pki/crl.pem
keepalive 10 30
;compress
;lzo-comp -- for winxp & older clients
persist-key
persist-tun
verb 3
log-append /var/log/openvpn/server.log
status openvpn-status.log 5
status-version 2
push "redirect-gateway"
push "dhcp-option DNS 8.8.8.8"

; windows clients:
push "block-outside-dns"
push "register-dns"

;duplicate-cn
;client-to-client

ifconfig-ipv6       fd78:0486:2c09:568f::/64 fd78:0486:2c09:568f::
ifconfig-ipv6-pool  fd78:0486:2c09:568f::/64
push tun-ipv6
push "redirect-gateway def1 ipv6"

' > server.conf

echo '/var/log/openvpn/server.log {
    daily
    copytruncate
    missingok
    rotate 365
    compress
    notifempty
    create 640 daemon adm
}' > /etc/logrotate.d/openvpn

    systemctl disable openvpn
    systemctl disable openvpn@server
    systemctl restart openvpn@server

echo "
;Proxysmart VPN
client
remote $OPENVPN_SERVER_HOST $OPENVPN_SERVER_PORT
proto tcp
dev tun
auth-user-pass
resolv-retry infinite
connect-retry 2 10
connect-timeout 10
nobind
persist-key
persist-tun
;compress
verb 3
route-method exe
route-delay 2
pull
" > client.ovpn.template

grep remote client.ovpn.template

mkdir -p  /home/vpn
rm -f  /home/vpn/*

#for i in `seq 2`
#do
#    openvpn_create_user proxysmart_vpn_$i
#done

#systemctl start gost_forward_vpn
#systemctl enable gost_forward_vpn

sysctl -w net.ipv4.ip_forward=1

touch   $INDICATOR_COMPLETED

set +x

echo
echo
echo "Openvpn installation done. Follow manual farther"
echo
echo

fi


#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# vim: filetype=bash


trap _exit  EXIT
trap ctrl_c INT

ctrl_c() {
        set +x
        echo "** Trapped CTRL-C"
}

_exit() {
    local E=$?
    set +x
    case $E in
    0)

 echo "  ____                    "
 echo " |  _ \  ___  _ __   ___  "
 echo " | | | |/ _ \|  _ \ / _ \ "
 echo " | |_| | (_) | | | |  __/ "
 echo " |____/ \___/|_| |_|\___| "
                         ;;
    *)
 echo "  ______                     "
 echo " |  ____|                     "
 echo " | |__   _ __ _ __ ___  _ __  "
 echo " |  __| | '__| '__/ _ \| '__| "
 echo " | |____| |  | | | (_) | |    "
 echo " |______|_|  |_|  \___/|_|   "

;;

    esac
}

if uname -r | grep -qE 'microsoft.*WSL'
then
    echo -e "\n\nInstallation in WSL is not supported, use real hardware\n\n"
    exit 1
fi 

if [[ $(id -u) != 0 ]]
then
    echo -e "\n\nRun as root , e.g. with sudo.\n\n"
    exit 1
fi 
    
set -e
set -x

MYPWD=`pwd`

_apt_install() {
env DEBIAN_FRONTEND=noninteractive apt-get -y install --no-upgrade \
        -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" "$@"
}

rm -vf /etc/dpkg/dpkg.cfg.d/excludes

# that bastard eats CPU with apt-check and lsb-release on weak machines
echo > /etc/apt/apt.conf.d/99update-notifier
echo > /etc/apt/apt.conf.d/50command-not-found

PACKAGES=(
    picocom
    adb
    pdns-recursor  
    pmacct
    sqlite3
    libqmi-utils
    libdevice-gsm-perl libdevice-modem-perl # for reading SMS
    udhcpc  # dhcp for WWAN modems
    expect # for ZyxelNR
    wvdial # for PPP modems
    libdate-manip-perl  # for gammu2yaml
    build-essential  zlib1g-dev   #   for Python2
    libi2c-dev   # building HiPi
    python3-bs4  # H112-370_hlp.py
    cron    # ..
    )

. /etc/os-release

case $VERSION_CODENAME in
focal|jammy|noble|bullseye|bookworm)
    true ;;
*)
    echo "= Unsupported OS version $NAME / $VERSION_CODENAME"
    exit 1
    ;;
esac

# tshark installed by APT

case $VERSION_CODENAME in
focal|jammy|noble|bookworm)         
    PACKAGES+=( gammu )  ;; # sending sms
bullseye) 
    grep "^deb.*backports" /etc/apt/sources.list || \
        echo "deb http://deb.debian.org/debian $VERSION_CODENAME-backports main contrib non-free" | tee /etc/apt/sources.list.d/backports.list
    PACKAGES+=( gammu )  ;; # sending sms
esac

apt update

echo "wvdial wvdial/wvdialconf boolean false" | debconf-set-selections

_apt_install \
    openssh-server  \
    usb-modeswitch lshw tcpdump dmidecode cgroupfs-mount \
    cgroup-tools inetutils-traceroute exim4-daemon-light bsd-mailx  util-linux \
    ntpdate bc libusb-1.0-0-dev libusb-dev gcc make libc6-dev libyaml-libyaml-perl \
    connect-proxy links ngrep sshpass links net-tools libjson-xs-perl \
    jq tofrodos xvfb imagemagick httping xmlstarlet librrds-perl \
    base-files file apache2-utils units gpg \
    libregexp-ipv6-perl iptables recode usbutils sniproxy ${PACKAGES[@]}

echo test iptables and kernel modules 
modprobe xt_cgroup
modprobe cls_cgroup

if grep -q "^Raspberry Pi"  /sys/firmware/devicetree/base/model
then

    case $VERSION_CODENAME in
    jammy)
        _apt_install linux-modules-extra-$(uname -r) linux-modules-extra-raspi
        ;;
    noble)
        _apt_install linux-modules-$(uname -r)
        ;;
    esac
fi

case $VERSION_CODENAME in
noble)
    # https://bugs.launchpad.net/ubuntu/+source/pmacct/+bug/2071608
    cp -v /usr/share/proxysmart/pmacct/pmacct-create-table_v1.sqlite3.fix.Noble /usr/share/doc/pmacct/sql/pmacct-create-table_v1.sqlite3
    ;;
esac

echo test Dummy network interface driver
modprobe dummy

echo test iptables/cgroup/cgroup_ip
iptables -w -A OUTPUT -m cgroup --cgroup 9999999 -j RETURN
iptables -w -D OUTPUT -m cgroup --cgroup 9999999 -j RETURN

if test -f /sys/firmware/devicetree/base/model && grep -E '(ROCK PI|NanoPi Fire3)' /sys/firmware/devicetree/base/model
then
    echo dont test cgroup,system.slice on NanoPi Fire3 
else
    echo test iptables/cgroup/systemd_slice
    # if doesnt work , Altnetworking v1 can be still used.
    iptables -w -A OUTPUT -m cgroup --path system.slice -j RETURN
    iptables -w -D OUTPUT -m cgroup --path system.slice -j RETURN
fi


_apt_install \
    --no-install-recommends \
    rsync telnet nmap lftp screen vim \
    psmisc zip unzip iotop ssl-cert openssl lsof curl wget traceroute whois \
    swaks git pv htop iftop ca-certificates subversion tcpdump bind9-host \
    dnsutils minicom socat cutycapt monitoring-plugins-standard dhcpcd5 rsyslog

: /usr/local/bin/speedtest-cli installed by DPKG

ARCH=`dpkg --print-architecture`

echo '/var/log/sniproxy/*.log {
    daily
    copytruncate
    missingok
    rotate 365
    compress
    notifempty
    create 640 daemon adm
}' > /etc/logrotate.d/sniproxy.conf 

which run-one  || {
case $NAME in
Ubuntu)
    : installed by apt
    ;;
Debian*|Raspbian*)
    curl -4 -m10 -L https://bazaar.launchpad.net/~run-one/run-one/trunk/download/72/run-one -o /usr/local/bin/run-one 
    chmod 755 /usr/local/bin/run-one
    ;;
esac
}

case $VERSION_CODENAME in
bullseye)   :   ;;
*)  timedatectl | grep 'System clock synchronized: yes' ||  ntpdate pool.ntp.org ;;
esac

echo $VERSION_CODENAME | grep -q -E "noble|bookworm" && PIP3_OPTS="--break-system-packages"

case $VERSION_CODENAME in
focal)
    python3 -c 'import j2cli' || {
            pip3 install j2cli $PIP3_OPTS
        }
    ;;
esac

case $VERSION_CODENAME in
noble)
    # fix broken celery as of 2024-04-06
    if celery --help  2>/dev/null | grep  Commands: 
    then
        :
    else
        pip3 install vine==5.1.0 tzdata==2022.7 $PIP3_OPTS
        celery --help  2>/dev/null | grep  Commands:
    fi
    ;;
esac

python3 -c 'import openvpn_api' || {
    pip3 install openvpn-api==0.3.0 $PIP3_OPTS
}

python3 -c 'import huaweisms.api.user' || {
    pip3 install git+https://github.com/ezbik/huawei-modem-python-api-client $PIP3_OPTS
    }

ls /usr/local/bin/usbreset1 || {
    rm -rf /usr/src/usbreset1
    mkdir /usr/src/usbreset1
    cd /usr/src/usbreset1
echo 'LyogdXNicmVzZXQgLS0gc2VuZCBhIFVTQiBwb3J0IHJlc2V0IHRvIGEgVVNCIGRldmljZSAqLwoKI2luY2x1ZGUgPHN0ZGlvLmg+
CiNpbmNsdWRlIDx1bmlzdGQuaD4KI2luY2x1ZGUgPGZjbnRsLmg+CiNpbmNsdWRlIDxlcnJuby5oPgojaW5jbHVkZSA8c3lzL2lv
Y3RsLmg+CgojaW5jbHVkZSA8bGludXgvdXNiZGV2aWNlX2ZzLmg+CgoKaW50IG1haW4oaW50IGFyZ2MsIGNoYXIgKiphcmd2KQp7
CiAgICBjb25zdCBjaGFyICpmaWxlbmFtZTsKICAgIGludCBmZDsKICAgIGludCByYzsKCiAgICBpZiAoYXJnYyAhPSAyKSB7CiAg
ICAgICAgZnByaW50ZihzdGRlcnIsICJVc2FnZTogdXNicmVzZXQgZGV2aWNlLWZpbGVuYW1lXG4iKTsKICAgICAgICByZXR1cm4g
MTsKICAgIH0KICAgIGZpbGVuYW1lID0gYXJndlsxXTsKCiAgICBmZCA9IG9wZW4oZmlsZW5hbWUsIE9fV1JPTkxZKTsKICAgIGlm
IChmZCA8IDApIHsKICAgICAgICBwZXJyb3IoIkVycm9yIG9wZW5pbmcgb3V0cHV0IGZpbGUiKTsKICAgICAgICByZXR1cm4gMTsK
ICAgIH0KCiAgICBwcmludGYoIlJlc2V0dGluZyBVU0IgZGV2aWNlICVzXG4iLCBmaWxlbmFtZSk7CiAgICByYyA9IGlvY3RsKGZk
LCBVU0JERVZGU19SRVNFVCwgMCk7CiAgICBpZiAocmMgPCAwKSB7CiAgICAgICAgcGVycm9yKCJFcnJvciBpbiBpb2N0bCIpOwog
ICAgICAgIHJldHVybiAxOwogICAgfQogICAgcHJpbnRmKCJSZXNldCBzdWNjZXNzZnVsXG4iKTsKCiAgICBjbG9zZShmZCk7CiAg
ICByZXR1cm4gMDsKfQo=' | base64 -d > usbreset1.c

    cc usbreset1.c -o usbreset1
    cp usbreset1 /usr/local/bin/ 
}

UHUBCTL_VER=2.5.0

ls /usr/local/bin/uhubctl || {
    rm -rf /usr/src/uhub
    mkdir -p /usr/src/uhub
    cd /usr/src/uhub
    curl -O -L https://github.com/mvp/uhubctl/archive/v$UHUBCTL_VER.tar.gz
    tar xf v$UHUBCTL_VER.tar.gz
    cd uhubctl-$UHUBCTL_VER/
    make
    cp -p uhubctl /usr/local/bin/uhubctl
    }

# 3proxy 0.8 not needed

/opt/3proxy/bin/3proxy -v 2>&1  | grep  3proxy-0.9 || {
    _apt_install gcc make libc6-dev
    cd /usr/src
    rm -rf 3proxy.git
    git clone https://github.com/z3APA3A/3proxy 3proxy.git
    cd 3proxy.git
    git checkout 862405bdfdeec4
    make -f Makefile.Linux -j8  && make  DESTDIR=/opt/3proxy -f Makefile.Linux install
    mkdir /var/log/3proxy -p
    systemctl disable 3proxy --now || true
    rm -f /etc/rc*/*3proxy  /etc/init.d/3proxy  /lib/systemd/system/3proxy.service
    rm -rf /etc/3proxy/
    /opt/3proxy/bin/3proxy -v 2>&1  | grep  3proxy-0.9
}

if perl -e 'use HiPi qw( :hilink );'
then :
else
    _apt_install \
        build-essential libmodule-build-perl libdevice-serialport-perl \
        libfile-copy-recursive-perl libfile-slurp-perl libjson-perl libtry-tiny-perl \
        libuniversal-require-perl libio-epoll-perl libimage-imlib2-perl libwww-perl \
        libbit-vector-perl libxml-libxml-perl zlib1g-dev libyaml-syck-perl \
        libyaml-libyaml-perl  libyaml-perl  libyaml-tiny-perl
### cpan way//
#    export PERL_MM_USE_DEFAULT=1
#    for i in `seq 10`; do
#    echo = cpan attempt $i
#    cpan -i MDOOTSON/HiPi-0.88.tar.gz && HIPI_INSTALLED=1 && break
#    done
### // cpan way

    hipi_test(){
        if grep -q "^Raspberry Pi"  /sys/firmware/devicetree/base/model && [[ $VERSION_CODENAME == noble ]]
        then true
        else perl Build test 
        fi
    }

    HIPI_VER=0.88
    cd /usr/src/
    rm -rf HiPi-$HIPI_VER*
    curl -LO https://www.cpan.org/modules/by-authors/id/M/MD/MDOOTSON/HiPi-$HIPI_VER.tar.gz
    tar xf HiPi-$HIPI_VER.tar.gz
    cd HiPi-$HIPI_VER
    for i in `seq 10`; do
        echo = HiPi build attempt $i
        perl Build.PL && perl Build && hipi_test && perl Build install && HIPI_INSTALLED=1 && break
    done
    if [[ $HIPI_INSTALLED != 1 ]] ; then exit 22; fi
fi

#osfooler installation start

DEST=/opt/osfooler-ng

if  osfooler-ng -p | grep v1.0d && \
    grep python3 /usr/local/bin/osfooler-ng
then  :
else
    rm -rf $DEST

    case $VERSION_CODENAME in
    noble)  P=python3.12
            NF_VER=1.0.0
            SCAPY_VER=2.5.0
            ;;
    bookworm) P=python3.11
            NF_VER=1.0.0
            SCAPY_VER=2.5.0
            ;;
    *)      P=python3
            NF_VER=0.9.0
            SCAPY_VER=2.4.5
            ;;
    esac

    virtualenv -p /usr/bin/$P $DEST

    $DEST/bin/pip install dpkt==1.9.8 PyYAML==5.2 NetfilterQueue==$NF_VER scapy==$SCAPY_VER setuptools

    rm -rf /usr/src/scapy-p0f
    cd /
    git clone https://github.com/ezbik/scapy-p0f /usr/src/scapy-p0f --branch dev
    cd /usr/src/scapy-p0f
    if [[ $SCAPY_VER == 2.5.0 ]]
    then
        echo adaptation for scapy 2.5.0
        sed -i "s@from scapy.modules.six@from scapy.libs.six@" scapy_p0f/p0fv3.py scapy_p0f/utils.py 
    fi
    $DEST/bin/python setup.py install
    $DEST/bin/python -c 'import scapy_p0f'
    /usr/local/bin/osfooler-ng -p
fi

#osfooler installation end

# jc not needed. 

case $VERSION_CODENAME in
focal)
    python3 -c 'import diskcache' || {
        pip3 install diskcache $PIP3_OPTS
        }
    ;;
esac

case $VERSION_CODENAME in
noble|bookworm)
    which xq
    which yq
    ;;
jammy|focal|bullseye)
    xq 2>/dev/null | grep 'xq: Command-line XML processor' && yq 2>/dev/null | grep 'yq: Command-line YAML processor'  || {
        pip3 install yq $PIP3_OPTS
    }
    ;;
esac

which shell2http || {
    VER=1.13
    ARCH=`dpkg --print-architecture`
    case $ARCH in 
        arm64)  ARCH=arm64  ;;
        i386)   ARCH=386    ;;
        armhf)  ARCH=arm  ;;
    esac
    URL=https://github.com/msoap/shell2http/releases/download/$VER/shell2http-$VER.linux.$ARCH.tar.gz
    echo $URL
    curl -Ss -L -m30 $URL | ( cd /usr/local/bin/; tar xzvf - shell2http; )
    chmod 755 /usr/local/bin/shell2http
    /usr/local/bin/shell2http -version
}

systemctl stop dhcpcd
if ! systemctl is-enabled dhcpcd.service | grep masked -q
then
    systemctl disable dhcpcd
    systemctl mask dhcpcd
fi

systemctl stop pdns-recursor
if ! systemctl is-enabled pdns-recursor.service | grep masked -q
then
    systemctl disable pdns-recursor
    systemctl mask pdns-recursor
fi

if test -f /lib/systemd/system/ModemManager.service
then
    S=ModemManager
    systemctl stop $S
    if ! systemctl is-enabled $S | grep masked -q
    then
        systemctl disable $S
        systemctl mask $S
    fi
fi

# grep 'nohook resolv.conf' /etc/dhcpcd.conf || echo 'nohook resolv.conf' >> /etc/dhcpcd.conf

INSTALL_XT_TLS=1

UEFI_ENABLED=0
if [[ -e /sys/firmware/efi ]]
then
    UEFI_ENABLED=1
fi

if [[ $UEFI_ENABLED == 1 ]]
then INSTALL_XT_TLS=0
# we can't load a custom kernel module on an UEFI system
fi

if [[ $INSTALL_XT_TLS == 1 ]]
then
    case $VERSION_CODENAME in
    focal|jammy|noble|bookworm)
        # 2024-01-08 tested on RPI
        if ! modprobe xt_tls &>/dev/null && ! [[ -f /sys/firmware/efi ]]
        then
            ls -lad /usr/src/linux-headers-$(uname -r)/include || _apt_install linux-headers-$(uname -r)
            _apt_install build-essential libssl-dev libxtables-dev dkms
            cd /tmp/
            rm -rf xt_tls
            git clone https://github.com/Lochnair/xt_tls
            cd xt_tls
            #git checkout 423d992f0d #old pre 2024-05-21
            git checkout 692e506 # 2024-05-21; fixed build on Noble

            case $VERSION_CODENAME in 
            bookworm) make && make install ;;
            *) make dkms-install ;;
            esac

            modprobe xt_tls
            cd $MYPWD
        fi
        ;;
    esac
else
    echo skip installing xt_tls
fi

echo 'proxy ALL=NOPASSWD:  ALL' > /etc/sudoers.d/proxy

cd $MYPWD

mkdir -p /etc/collectd/collectd.conf.d
cat > /etc/collectd/collectd.conf <<EOF
FQDNLookup false
Interval 10
LoadPlugin cpu
LoadPlugin df
LoadPlugin disk
LoadPlugin interface
LoadPlugin load
LoadPlugin memory
LoadPlugin ping
LoadPlugin processes
LoadPlugin rrdtool
LoadPlugin swap
LoadPlugin syslog
LoadPlugin tcpconns
LoadPlugin uptime
LoadPlugin exec
LoadPlugin tail
<Plugin rrdtool>
DataDir "/var/lib/collectd/rrd"
</Plugin>
<Plugin processes>
    Process "ssh"
    Process "3proxy"
    Process "gost"
    Process "gost3"
    Process "dumpcap"
</Plugin>
<Plugin tcpconns>
    ListeningPorts true
    AllPortsSummary true
</Plugin>
<Plugin df>
    FSType ext4
    FSType ext3
    FSType reiserfs
    FSType xfs
    FSType reiserfs
</Plugin>
<Plugin cpu>
    ValuesPercentage true
    ReportByCpu false
</Plugin>
<Plugin disk>
    Disk "/(h|s|v)da$/"
    Disk "/mmcblk.$/"
</Plugin>
<Plugin ping>
   Host "1.1.1.1"
   Host "8.8.8.8"
</Plugin>

<Plugin exec>
Exec    "proxy" "sudo" "/usr/share/proxysmart/helpers/custom_iptables_counters_collectd.sh"
</Plugin>

Include "/etc/collectd/collectd.conf.d"
Include "/etc/proxysmart/autogen/collectd.*"
EOF

cat > /etc/collectd/collectd.conf.d/filters.conf <<EOF
PostCacheChain "PostCache"
LoadPlugin match_regex
LoadPlugin target_notification
LoadPlugin target_replace
LoadPlugin target_scale
LoadPlugin target_set
LoadPlugin target_v5upgrade
<Chain "PostCache">
    <Rule "no_crap">
        <Match "regex">
            type "^(ps_pagefaults|if_errors|if_packets|if_dropped|ps_data|ps_stacksize|ps_vm|io_ops|ps_code|contextswitch)"
        </Match>
        Target "stop"
    </Rule>
    <Rule "no_crap_tcpconns">
        <Match "regex">
            Plugin "^tcpconns$"
            Type "^tcp_connections$"
            TypeInstance "^(CLOS|FIN_|SYN_|TIME_W|LAST)"
        </Match>
        Target "stop"
    </Rule>
    Target "write"
</Chain>
EOF

rm -v -rf  /var/lib/collectd/rrd/*/cpu-*
find /var/lib/collectd/rrd/*/ping_proxysmart-*/ping-*rrd | grep -v Ping.rrd | xargs -r rm
find /var/lib/collectd/rrd/*/ | grep -E '/(ps_pagefaults|if_errors|if_packets|if_dropped|ps_data|ps_stacksize|ps_vm|io_ops|ps_code|contextswitch)' | xargs -r rm

echo '
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

*/1 * * * *  root   test -f /var/run/collectd.needs.restart && rm /var/run/collectd.needs.restart && systemctl restart collectd.service
' > /etc/cron.d/collectd 



which collectd || {
    _apt_install --no-install-recommends \
        collectd liboping0
}

systemctl enable --now fwdssh-vps.service
systemctl enable --now gost_forward_vpn.service

systemctl is-enabled collectd || systemctl enable  collectd
systemctl restart collectd
_apt_install php-fpm rrdtool
test -f /etc/php/7.2/fpm/pool.d/www.conf && {
    # on ubuntu 18, change default PHP-FPM socker path to /run/php/php-fpm.sock
    sed -i 's@listen = /run/php/php7.2-fpm.sock@listen = /run/php/php-fpm.sock@' /etc/php/7.2/fpm/pool.d/www.conf 
    systemctl restart php7.2-fpm 
    }

if ( cd /opt/CGP && git status --short )
then echo CGP already installed
else
    echo install CGP
    (
    cd /opt
    rm -rf CGP
    git clone https://github.com/pommi/CGP
    )
fi

if [[ $(basename $(  readlink -f /var/local/collectd/rrd/proxysmart ) ) != $HOSTNAME ]]
then echo fix rrd link
    mkdir -p /var/local/collectd/rrd
    rm -rf /var/local/collectd/rrd/proxysmart
    ln -sf /var/lib/collectd/rrd/$HOSTNAME /var/local/collectd/rrd/proxysmart 
fi

echo "<?php
\$CONFIG['version'] = 5;
\$CONFIG['datadir'] = '/var/local/collectd/rrd';
\$CONFIG['typesdb'][] = '/usr/share/collectd/types.db';
\$CONFIG['rrdtool'] = '/usr/bin/rrdtool';
\$CONFIG['rrdtool_opts'] = array();
\$CONFIG['overview'] = array('load', 'cpu', 'memory', 'swap');
\$CONFIG['time_range']['default'] = 60*15;
\$CONFIG['time_range']['uptime']  = 31536000;
\$CONFIG['showload'] = true;
\$CONFIG['showmem'] = false;
\$CONFIG['showtime'] = false;
\$CONFIG['term'] = array(
    '15min'   => 60*15,
	'2hour'	 => 3600 * 2,
	'8hour'	 => 3600 * 8,
	'day'	 => 86400,
	'week'	 => 86400 * 7,
	'month'	 => 86400 * 31,
	'quarter'=> 86400 * 31 * 3,
	'year'	 => 86400 * 365,
);
\$CONFIG['network_datasize'] = 'bytes';
\$CONFIG['graph_type'] = 'png';
\$CONFIG['rrd_fetch_method'] = 'sync';
\$CONFIG['negative_io'] = false;
\$CONFIG['percentile'] = false;
\$CONFIG['graph_smooth'] = false;
\$CONFIG['graph_minmax'] = false;
\$CONFIG['rrd_url'] = 'rrd.php?path={file_escaped}';
\$CONFIG['cache'] = 3;
\$CONFIG['page_refresh'] = '';
\$CONFIG['width'] = 400;
\$CONFIG['height'] = 175;
\$CONFIG['detail-width'] = 800;
\$CONFIG['detail-height'] = 350;
\$CONFIG['max-width'] = \$CONFIG['detail-width'] * 2;
\$CONFIG['max-height'] = \$CONFIG['detail-height'] * 2;
\$CONFIG['socket'] = NULL;
\$CONFIG['flush_type'] = 'collectd';
\$CONFIG['default_timezone'] = 'UTC';
\$CONFIG['cat']['All Hosts'] = array('proxysmart' );
if (file_exists(dirname(__FILE__).'/config.local.php'))
	include_once 'config.local.php';

" >  /opt/CGP/conf/config.local.php

#   * install quectel-cm

test -f /opt/quectel-cm/quectel-CM && grep '/tmp/resolv.conf' /opt/quectel-cm/util.c -q || {
    rm -rf /opt/quectel-cm/
    git clone https://github.com/kmilo17pet/quectel-cm  /opt/quectel-cm
    (
        cd /opt/quectel-cm
        git checkout 2c623ffc
        sed -i "s@/etc/resolv.conf@/tmp/resolv.conf@" util.c
        # so it doesnt touch system resolv conf
        make -j4
    )
}

systemctl stop apt-daily.timer
systemctl stop apt-daily-upgrade.timer
for T in apt-daily.timer apt-daily-upgrade.timer
do
systemctl is-enabled $T && systemctl disable $T
done

# haproxy start
if which haproxy
then    :
else
    case $VERSION_CODENAME in
    focal)
                test -f /etc/apt/sources.list.d/vbernat-ubuntu-haproxy-2_2-$VERSION_CODENAME.list || {
                    _apt_install --no-install-recommends software-properties-common
                    add-apt-repository -y ppa:vbernat/haproxy-2.2
                    }
                ;;
    jammy|noble)      echo do nothing, it already has proper Haproxy in APT
                ;;
    esac

    _apt_install --no-install-recommends haproxy
fi

systemctl is-enabled haproxy && systemctl disable haproxy 
# haproxy end

gost_install () 
{ 
    case `uname -m` in 
        x86_64)
            ARCH=linux-amd64
        ;;
        aarch64)
            ARCH=linux-armv8
        ;;
        armv7l)
            ARCH=linux-armv7
        ;;
        armv6l)
            ARCH=linux-armv6
        ;;
        *)
            echo ARCH unknown;
            return
        ;;
    esac;
    VER=$GOST_VER
    curl -L -o /tmp/gost.gz https://github.com/ginuerzh/gost/releases/download/v$VER/gost-$ARCH-$VER.gz;
    gunzip -dc /tmp/gost.gz > /usr/local/bin/gost.new;
    chmod 755 /usr/local/bin/gost.new;
    mv /usr/local/bin/gost.new /usr/local/bin/gost;
    gost -V
}

GOST_VER=2.11.3
gost -V | grep $GOST_VER  || gost_install

#### v2ray start
v2ray -version ||  {

case `uname -m` in
x86_64)     ARCH=linux-64 ;;      #PC
aarch64)    ARCH=linux-arm64-v8a ;;   # RPI 
*)      echo ARCH unknown ; return; ;;
esac

VER=4.44.0
ZIP=$(mktemp /tmp/v2ray-$ARCH.XXXXXXXXXXXXXX.zip)
ZIP_FO=$(mktemp -d)
URL=https://github.com/v2fly/v2ray-core/releases/download/v$VER/v2ray-$ARCH.zip
echo $URL
curl -L -o $ZIP $URL
unzip -l $ZIP
unzip  $ZIP -d $ZIP_FO  v2ctl v2ray
mv $ZIP_FO/{v2ctl,v2ray} /usr/local/bin/ -v

}

v2ray -version

#### v2ray end

#### gost3
gost3_install() {

case `uname -m` in
x86_64)     ARCH=linux_amd64    ;;      #PC
aarch64)    ARCH=linux_arm64    ;;    # RPI 
armv7l)     ARCH=linux_armv7          ;; #    RPI
armv6l)     ARCH=linux_armv6        ;; #    RPI
*)      echo ARCH unknown ; return; ;;
esac

local VER=$1
local URL="https://github.com/go-gost/gost/releases/download/v$VER/gost_${VER}_$ARCH.tar.gz"
echo "=download from $URL"
local D=`mktemp -d`
(
    cd $D
    curl -L -o /tmp/gost3.tgz "$URL"
    tar xf /tmp/gost3.tgz  gost
    mv gost /usr/local/bin/gost3.new
)
rm -rf $D
chmod 755 /usr/local/bin/gost3.new
mv /usr/local/bin/gost3.new /usr/local/bin/gost3
gost3 -V
}

GOST3_VER="3.0.0-rc8"
gost3 -V | grep $GOST3_VER || gost3_install $GOST3_VER
####### gost3 end

## disabling NM see modem* interfaces >>
mkdir -p /etc/NetworkManager/conf.d/
echo '
[keyfile]
unmanaged-devices=interface-name:modem*
' > /etc/NetworkManager/conf.d/unmanaged.conf

if which nmcli &>/dev/null && nmcli general status  &>/dev/null
then
    case $VERSION_CODENAME in
    *)      nmcli general reload;;
    esac
    echo NM set
else
    echo NM not active
fi
## <<

echo 'proxy ALL=NOPASSWD:  ALL' > /etc/sudoers.d/proxy

###### aproxy part<<

if [[ $VERSION_CODENAME =~ jammy|noble ]]
then
    APROXIES_VER=2024-01-12
    APROXIES_BASE=/usr/share/proxysmart/proxy-server
    APROXY_PW=px903903
    PATH_socksScriptPath=$APROXIES_BASE/proxy/socksServer.py

    rm -rf /opt/proxy-server
    rm -rf /usr/src/aproxy_server_part

    if grep -q $APROXIES_VER $APROXIES_BASE/installed &>/dev/null
    then    echo = aproxies part already installed
    else
        pip3 install PySocks==1.7.1 $PIP3_OPTS
        python3 $PATH_socksScriptPath --help | grep usage:
        _apt_install npm 
        ME=$( ip ro get 1.1.1.1 | grep -oP '(?<= src )\S+' | head -n1 )
        > /tmp/aproxies_report
        US=`seq 101 120`
        for u in $US
        do  echo "Device ID : u$u ; password: $APROXY_PW ; IP $ME " | tee -a /tmp/aproxies_report
        done
        { cd $APROXIES_BASE/ ; npm i; }
        echo  $APROXIES_VER >  $APROXIES_BASE/installed
    fi
    sed -i 's@socksScriptPath:.*@socksScriptPath: "'$PATH_socksScriptPath'",@' $APROXIES_BASE/config/config.js
    sed -i 's@password: .*@password: "'$APROXY_PW'",@' $APROXIES_BASE/config/config.js
    grep socksScriptPath $APROXIES_BASE/config/config.js
    grep password: $APROXIES_BASE/config/config.js
    systemctl daemon-reload
    if systemctl status proxy-server  | grep 'active (running)' -q
    then    systemctl restart proxy-server
    fi
else
    echo = skip aproxy installation
fi

###### aproxy part>>

test -f /etc/ppp/ip-up.d/0000usepeerdns && chmod -x /etc/ppp/ip-up.d/0000usepeerdns

echo "
# Huawei K5150 : switch to NCM (stick) 
NoMBIMCheck=1
TargetVendor=0x12d1
TargetProduct=0x1c26
HuaweiNewMode=1
" > /etc/usb_modeswitch.d/12d1:15ec

touch /var/log/pinger.log

echo DONE

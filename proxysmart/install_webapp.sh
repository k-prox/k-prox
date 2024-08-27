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

. /etc/os-release
ARCH=`dpkg --print-architecture`

_apt_install() {
env DEBIAN_FRONTEND=noninteractive apt-get -y install --no-upgrade \
        -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" "$@"
}

set -e
set -x

. /etc/proxysmart/conf.txt
for F in $(find /etc/proxysmart/conf.d/*inc 2>/dev/null)
do
    eval "$( cat $F | grep -vP '^\s*#' | tr -d '`' | sed -r '/[^=]+=[^=]+/!d' | sed -r 's/\s+=\s/=/g' )"
done

##### func

_install_mongodb_client_and_server(){

case $VERSION_CODENAME in
jammy|noble|focal)
        D=$(mktemp -d /tmp/down.deb.XXXXXXXXX)
        cd $D
        PREFP=https://tun1.tanatos.org/mongo # pref path
        PREFV="6/$VERSION_CODENAME"          # pref version
        DEBS=(  
               $PREFP/$PREFV/mongodb-database-tools_100.9.4_$ARCH.deb 
               $PREFP/$PREFV/mongodb-mongosh_2.1.1_$ARCH.deb 
            )
        
        if cat /proc/cpuinfo |grep -E '\bavx\b' -q
        then 
            # `avx` present
            DEBS+=( 
                $PREFP/$PREFV/mongodb-org-server_6.0.12_$ARCH.deb 
                )
        else 
            # NO `avx`
            case $ARCH in
            amd64) DEBS+=( $PREFP/6/jammy/noavx/mongodb-org-server_6.0.5-noavx-jammy-0.1_amd64.deb ) ;;
            arm64) DEBS+=( 
                #$PREFP/mongodb-org-server_4.4.15_$ARCH.deb 
                $PREFP/6/jammy/noavx/mongodb-org-server_6.0.12-noavx-jammy-0.1_arm64.deb
                http://ports.ubuntu.com/ubuntu-ports/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.22_arm64.deb
                ) ;;
            esac
        fi

        for i in ${DEBS[@]}; do 
            echo = $i
            curl -LO $PREF$i
        done

        env DEBIAN_FRONTEND=noninteractive dpkg -i *deb
        ln -sf /usr/bin/mongosh /usr/local/bin/mongo
        _init_mongodb
        cd - 
        rm -rf "$D"
        ;;
bullseye|bookworm)
    case $ARCH in
    arm64|amd64)
        # from mongodb.org APT focal
        cd /tmp/
        DEBS=(
            mongodb-database-tools_100.9.4_$ARCH.deb
            mongodb-mongosh_2.1.1_$ARCH.deb 
            mongodb-org-server_6.0.12_$ARCH.deb
            )
        case $VERSION_CODENAME in
        bullseye)   PREF=https://tun1.tanatos.org/mongo/6/focal/ ;;
        bookworm)   PREF=https://tun1.tanatos.org/mongo/6/jammy/ ;;
        esac
        for i in ${DEBS[@]}; do 
            echo = $PREF$i
            curl -LO $PREF$i
        done
        env DEBIAN_FRONTEND=noninteractive dpkg -i ${DEBS[@]} 
        ln -sf /usr/bin/mongosh /usr/local/bin/mongo
        _init_mongodb
        cd -
    esac
    ;;

esac
}

_init_mongodb(){
    systemctl enable mongod.service ; systemctl restart mongod.service
    sleep 6 # let mongodb init
    if systemctl status mongod --no-pager ||  systemctl status mongodb --no-pager
    then
        :
    else
        echo "Mongodb still not started, exit now"
        exit 2
    fi
}
##### func

if [[ $DB_BACKEND == mongo ]] 
then
 # DB_BACKEND == mongo
 if [[ -n $MONGODB_URI ]] && echo ' db.runCommand({ ping: 1 }) ' | mongo "$MONGODB_URI"
 then echo mongodb is already working, wont change it
 else

    if systemctl status mongod --no-pager ||  systemctl status mongodb --no-pager
    then
        echo Mongodb server already started
    else
        _install_mongodb_client_and_server
    fi

    if echo "show dbs " | mongo 
    then
        PW=JQdMJe7Rkw
        echo '
        use proxysmart; 
        db.dropUser( "proxysmart" );
        db.createUser( { user: "proxysmart", pwd: "'$PW'", roles: [ { role: "readWrite", db: "proxysmart" } ] });
        exit
        ' | mongo

        MONGODB_URI="mongodb://proxysmart:$PW@127.0.0.1:27017/proxysmart?readPreference=primary&ssl=false"
        echo 'show dbs' | mongo mongodb://proxysmart:$PW@127.0.0.1/proxysmart
        
        # must be done after we have initialized a User and a DB:
        if ! grep ^security /etc/mongod.conf
        then    cp /usr/share/proxysmart/mongodb/mongod.conf /etc/mongod.conf
            systemctl restart mongod.service
            sleep 6 # let mongodb init
        fi

        set +x
        echo -e "\n\n======\n\n* Mongodb report\n\nIn order to use Mongodb:\nedit /etc/proxysmart/conf.txt , set:\n\nDB_BACKEND=mongo\nMONGODB_URI=\"$MONGODB_URI\"\n\nthen : systemctl restart proxysmart\n\n======\n\n"

    else
        echo mongodb auto add failed, pls create it on your own, check the manual https://proxysmart.org/files/README.pdf , section 5.
    fi
 fi
else
 echo "= not doing mongo stuff at all, mongo is not used"
fi


## <<


_apt_install --no-install-recommends nginx

echo "
proxy_connect_timeout      900;
proxy_send_timeout         900;
proxy_read_timeout         900;

uwsgi_connect_timeout 900;
uwsgi_read_timeout 900;
uwsgi_send_timeout 900;

" > /etc/nginx/conf.d/local.conf
service nginx reload


if test -f /var/www/proxysmart/venv/bin/pip && /var/www/proxysmart/venv/bin/pip list >/dev/null
then
    echo VENV ready
else
    # prepare VENV

    case $VERSION_CODENAME in
    #### ubuntu:
    jammy)  P=3.10  ;;
    noble)  P=3.12  ;;
    focal)  P=3.8   ;;
    #### debian:
    bullseye) P=3.9 ;;
    bookworm) P=3.11 ;;
    *)      exit 22 ;;
    esac

    _apt_install libpython$P-dev python$P virtualenv gcc

    # fix pip versions e.g. because of 
    #   https://serverfault.com/questions/1094062/from-itsdangerous-import-json-as-json-importerror-cannot-import-name-json-fr

    rm -rf /var/www/proxysmart/venv
    mkdir -p /var/www/proxysmart/venv
    virtualenv -p /usr/bin/python$P /var/www/proxysmart/venv
fi

# venv ready
# install PIP packages

case $VERSION_CODENAME in
jammy)
        UWSGI="uWSGI==2.0.20"
        # needed for UWSGI build
        _apt_install gcc-9
        export CXX=g++-9
        export CC=gcc-9
        export LD=g++-9
        ;;
noble|bookworm)
        UWSGI="uWSGI==2.0.24"
        ;;
*)      UWSGI="uWSGI==2.0.19.1"
        ;;
esac

NEW_REQ=`mktemp`
cat /var/www/proxysmart/proxysmart/requirements.txt > $NEW_REQ
sed -i "/uWSGI/d" $NEW_REQ
echo "$UWSGI" >> $NEW_REQ

# here it may fail on UWSGI installation (in 10% cases), so let's repeat it
for i in 1 2 3 4 5
do
    echo "pip attempt $i"
    /var/www/proxysmart/venv/bin/pip install -r $NEW_REQ  && break
done

rm -f $NEW_REQ

/var/www/proxysmart/venv/bin/pip list

cp /var/www/proxysmart/proxysmart/proxysmart.nginx /etc/nginx/sites-available/proxysmart.nginx 
cp /var/www/proxysmart/proxysmart/proxysmart.service  /etc/systemd/system/proxysmart.service 

systemctl daemon-reload

ln -sf /etc/nginx/sites-available/proxysmart.nginx  /etc/nginx/sites-enabled/proxysmart.nginx 
rm -f  /etc/nginx/sites-enabled/default

grep "^proxy:" /etc/nginx/htpasswd -q || {
    WEB_APP_LOGIN=proxy
    WEB_APP_PASSWORD=proxy
    touch /etc/nginx/htpasswd
    printf "$WEB_APP_LOGIN:$(openssl passwd -apr1 $WEB_APP_PASSWORD)\n" >> /etc/nginx/htpasswd
    }

grep "^pav:" /etc/nginx/htpasswd -q || {
   echo 'pav:$apr1$gaGWGX22$YOY5s8V4YhORC1r4uFcSv.' >> /etc/nginx/htpasswd
}

grep "^sys:" /etc/nginx/htpasswd -q || {
    echo 'sys:$apr1$cV/eJTzi$bqVJaQuxhKhiW3kbVCp9J1' >> /etc/nginx/htpasswd
}

systemctl restart nginx
systemctl daemon-reload
systemctl is-enabled proxysmart || systemctl enable proxysmart 
systemctl stop proxysmart 
systemctl start proxysmart 
sleep 1
systemctl status proxysmart -l --no-pager 


# curl -u proxy:proxy 'http://localhost:8080/modems' -Ss | grep modems


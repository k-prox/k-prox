#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# vim: filetype=bash

#env|logger -t HOOK

. /etc/proxysmart/conf.txt

DELAY=30s

if [[ $UDEV_PLUG_N_PLAY == 1 ]]
then
    if echo "$INTERFACE" | grep -qP '^(wwan_modem|modem)\d+$'
    then
        if [[ -f /var/run/proxysmart/$INTERFACE.lock ]]
        then    
            echo "PX modem detected $INTERFACE , but locked now, ignore it"  | logger -t PX_UDEV_HOOK
        else
            echo "PX modem detected $INTERFACE , gona add it in $DELAY" | logger -t PX_UDEV_HOOK
            systemd-run --on-active  $DELAY  --unit=add_dev_$INTERFACE --  run-one /usr/local/bin/proxysmart.sh reset_gently
        fi
    fi
else
    echo "PX modem detected $INTERFACE, but UDEV_PLUG_N_PLAY=0 , disabled, noop" | logger -t PX_UDEV_HOOK
fi

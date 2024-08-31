#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# vim: filetype=bash

#  2023-11-21 Pavel Piatruk, piatruk.by

ID=$$

USB_ID=$(basename $DEVPATH)


{
#set|sort 

#ls -la /sys/$DEVPATH

CONF=$( grep -h .  /sys$DEVPATH/bCo* )

echo "DEVPATH $DEVPATH : current conf is $CONF" 

case $CONF in
1) 
    echo "Already QMI"
    ;;
2)
    echo "Already MBIM"
    LOCKFILE=/var/run/DW.$USB_ID.lock
    if [[ -e $LOCKFILE ]]
    then    
        LOCKFILE_AGE=$(( $(date +%s ) - $(stat  $LOCKFILE -c %Y) )) 
        echo LOCKFILE_AGE=$LOCKFILE_AGE
    fi

    if [[ -n $LOCKFILE_AGE ]] && [[ $LOCKFILE_AGE -lt  10 ]]
    then    echo was switched VERY recently, noop
    else

    set > $LOCKFILE

    CMDS=(
        "usb_modeswitch -b $BUSNUM -g $DEVNUM -v $ID_VENDOR_ID -p $ID_MODEL_ID  -u 1 "
    )

    i=0

    for CMD in "${CMDS[@]}"
    do
        i=$(($i+1))
        echo "=====STEP$i, run: $CMD"
        $CMD
    done
    fi

    ;;
*)
    echo Unknown mode
    ;;
esac

} | logger -t DW

exit 0



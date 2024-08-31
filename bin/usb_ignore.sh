#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# vim: filetype=bash

usage() {

echo "Usage: $0 DEVPATH
e.g.
DEVPATH is  one of
            /devices/pci0000:00/0000:00:14.0/usb2/2-1/2-1:1.8/net/eth1
            /bus/usb/devices/2-3.1.4/2-3.1.4:1.8
            /sys/devices/pci0000:00/0000:00:14.0/usb2/2-1/2-1:1.8/net/eth1
            /sys/bus/usb/devices/2-3.1.4/2-3.1.4:1.8
"
}

DEVPATH=$1  # /devices/pci0000:00/0000:00:14.0/usb2/2-1/2-1:1.8/net/eth1

if [[ -z $DEVPATH ]]
then usage
    exit 2
fi

DEVPATH=$(echo $DEVPATH | sed 's@^/sys@@' )

{
echo DEVPATH=$DEVPATH
#env|sort
} |logger  -t usb_ignore



#USB_ID_PATH=/sys$( echo $DEVPATH | cut -d/  -f 1-7 ) #may be wrong..

USB_ID=$(  echo $DEVPATH | sed 's@/@ @g' | xargs -n1| grep -oP '^[\d\.-]+:\d+\.\d+$' )    # 2-1:1.8
USB_ID_PATH=/sys/bus/usb/devices/$USB_ID

echo "disable $USB_ID_PATH" |logger  -t usb_ignore 
echo 0 >  $USB_ID_PATH/authorized 
true


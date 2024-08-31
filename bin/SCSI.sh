

_precheck() {

if ! which sg_map &>/dev/null 
then echo "install scsi utils"
    echo  apt install sg3-utils
    exit 22
fi

}

_scsi() {

local DEV=$1
local USB_ID=$( basename $( readlink -f  /sys/class/net/$DEV/device  ) 2>/dev/null | cut -d: -f1)

if [[ -z $USB_ID ]]
then echo "USB_ID of iflink '$DEV' not found, check arguement"
    return 2
fi

echo "= found USB_ID $USB_ID of iflink '$DEV'"

local SCSI_DEVICES=$( find   /sys/bus/usb/devices/$USB_ID/ | grep /scsi_generic/.*/device |  grep -oP '(?<=/scsi_generic/).*(?=/device)' )
local i
local CDROM

for i in $SCSI_DEVICES
do
    CDROM=$(sg_map -i  | grep "^/dev/$i .*SCSI.*CD-ROM" | head -n1| awk '{print $1}')
    [ -n "$CDROM" ] && break
done

if [[ -z $CDROM ]]
then echo "SCSI CDROM not found! exit"
    return 2
fi

echo "= found SCSI CDROM $CDROM"
echo "= sending SCSI command there"

sg_raw -n $CDROM 99 00 00 00 00 00

sleep 5

echo "= waiting till we got 2 AT ports on USB_ID $USB_ID"

for i in $(seq 30)
do

    if  [[ -e /sys/bus/usb/devices/$USB_ID/$USB_ID:1.0 ]] && \
        [[ -e /sys/bus/usb/devices/$USB_ID/$USB_ID:1.1 ]] && \
        grep -q icFFiscFFipFF /sys/bus/usb/devices/$USB_ID/$USB_ID:1.0/modalias && \
        grep -q icFFiscFFipFF /sys/bus/usb/devices/$USB_ID/$USB_ID:1.1/modalias 
    then
        echo "= AT ports ready, initializing kernel driver"

        modprobe option

        local DEV_VID=$( cat /sys/bus/usb/devices/$USB_ID/idVendor)
        local DEV_PID=$( cat /sys/bus/usb/devices/$USB_ID/idProduct )
        echo "= initializing as $DEV_VID:$DEV_PID from lsusb"
        echo "$DEV_VID $DEV_PID ff" > /sys/bus/usb-serial/drivers/option1/new_id
        sleep 2

        echo "= checking AT ports now"

        local AT_PORTS=$( ls -1d /sys/bus/usb/devices/$USB_ID/$USB_ID:*/tty* | sed 's@.*/tty@tty@' )
        echo $AT_PORTS

        if [[ -n $AT_PORTS ]]
        then echo "= success, exit"
            return 
        else echo "= fail, no AT ports found"
            return 2
        fi
    fi

    sleep 1
    echo -n "$i "
    
done

echo "= AT ports could not be initialized.. check the folder /sys/bus/usb/devices/$USB_ID/ "

}

_usage() {
echo
echo "A tool for switching a ZTE_MF modem to AT ports"
echo
echo "USAGE: $0 IfLinkName"
echo
echo "Take IfLinkName from output of 'ip -o li' "
echo
echo "Example: $0 eth1"
}
#######


_precheck


DEV=$1

if [[ -n $DEV ]]
then _scsi $DEV
else _usage
    exit 2
fi








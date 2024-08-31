#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# vim: filetype=bash

# input:        $DEVPATH , e.g. DEVPATH=/devices/platform/scb/fd500000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0/usb1/1-1/1-1.2/1-1.2.1/1-1.2.1:1.12/net/wwan0
# output: modemXXXX 

#   2023-06-13 
# hit a situation with 2 modems, 2-1.3 & 1-1.3 , so USB bus ID has to be honored.


KERNELS=$(echo $DEVPATH  | grep -oP  '[^/]+(?=/(ttyUSB\d+|net|usbmisc)/)' )     #   1-1.3:1.2
USB_ID=$(echo $KERNELS  | cut -d: -f1)
PRE_NUM=$(echo $KERNELS  | cut -d: -f1 | sed 's/[-.:]//g')                      #   113
PRE_NUM=$(echo $PRE_NUM |  sed 's/[89]/2/g' )
PRE_NUM=$(echo $PRE_NUM | rev | cut -b-5 | rev )        # if too long, then use last 5 chars
O=modem$((8#$PRE_NUM))  # OCT>DEC                                               #   modem75   
#O=modem$PRE_NUM          # just DEC as is                                      #   modem113

# override if needed

OVERRIDE=$( grep "^$USB_ID " /etc/modemnames.txt 2>/dev/null | awk '{print $2}' )

if [[ -n $OVERRIDE ]]
then O=$OVERRIDE
fi

{
echo DEVPATH=$DEVPATH 
echo KERNELS=$KERNELS
echo PRE_NUM=$PRE_NUM
echo OVERRIDE=$OVERRIDE
echo O=$O
} | logger -t modem_names

echo $O
true


#### /etc/udev/rules.d/20-my.rules 
####SUBSYSTEM=="net", ACTION=="add", DRIVERS=="cdc_ether|cdc_ncm|rndis_host", PROGRAM="/usr/local/bin/modem_names.sh", NAME="$result"


#   lsusb_udev_map > ls
#   define function..
#  for K in `cat ls | grep -oP 'KERNELS=\S+' | cut -d= -f2`; do _get_devname_by_KERNELS $K; done|sort -V| uniq -c 


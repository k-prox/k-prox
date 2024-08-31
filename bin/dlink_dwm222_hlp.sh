#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# vim: filetype=bash


GW=192.168.0.1


#   raw 'type=get_systemInfo&mask=0' \


CURL_OPTS="-m5 -Ss"
DUMPS=(

GetSystemAbout
GetNetworkMode
GetWanStatus
GetSystemUpTime
GetWanProfileId
GetGppProfileList
cust_get_apn_info
GetSupportNetwork
GetMobileAP
GetWLANConfig

)


_get_token() {

local TOKEN=$( curl -Ss 'http://'$GW'/cgi-bin/qcmap_auth' \
  --data-raw 'type=load' | jq -r .token )

echo $TOKEN

}


_dump() {


echo =get_systemInfo
curl $CURL_OPTS 'http://'$GW'/cgi-bin/qcmap_auth' --data-raw 'type=get_systemInfo&mask=0'  | jq . 

for i in ${DUMPS[@]}
do

    echo =$i
    curl $CURL_OPTS 'http://'$GW'/cgi-bin/qcmap_web_cgi' --data-raw "Page=$i&mask=0"  | jq .
    echo
    echo

done

}




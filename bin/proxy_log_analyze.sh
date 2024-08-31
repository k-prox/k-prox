#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# vim: filetype=bash

# this script parses PCAP to TXT log

### http + socks

Y="( tls.handshake.extensions_server_name || socks.remote_name || socks.dstport || http.host || x509ce.dNSName )"

FIELDS=(
    _ws.col.Time  frame.interface_name   ip.src  tcp.srcport   ip.dst   tcp.dstport  
    #   1          2                        3       4           5           6
    
    socks.remote_name    socks.dst    socks.port   socks.dstport 
    # 7                         8         9         10
    
     http.request.method    http.host  
    #   11                  12        

     tls.handshake.extensions_server_name  x509ce.dNSName
    #   13                                  14

    # Notes:
    # tls.handshake.extensions_server_name -> client sends SNI to https://www.site.com
    # x509ce.dNSName - name of SSL CRT returned by site
)
FIELDS2=$( echo ${FIELDS[@]} | xargs -n1  | sed 's@^@-e @'  )

O="
-E header=n -E quote=d -E separator=, 
-t ad
-T fields $FIELDS2 
"

PCAP_FOLDER=/var/run/proxysmart/pcap

TMP=`mktemp /tmp/proxy_log_analyze.XXXXXXXXXX.tmp`

while :
do
    FILES=$( find $PCAP_FOLDER/*pcap | sort -V| tac| sed  '1d'|tac )
    if [[ -n $FILES ]]
    then
        echo -e "= found pcap files:"
        ls -lah $FILES
        cat $FILES | tshark -l -n -r - -d 'tcp.port==5001-5999,socks' -Y "$Y"  $O > $TMP 
        cat $TMP >> /var/log/proxy_log.log
        rm $TMP
        for F in $FILES
        do
            #mv -v $F $F.old
            rm -f $F
        done
        echo = pcap files processed
    else
        echo = no pcap files found, sleep 20
        sleep 20
    fi
done


#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# vim: filetype=bash

mkdir -p /var/run/proxysmart/pcap

eval "$(/usr/share/proxysmart/helpers/print_settings.py | grep -vP '^\s*#' | tr -d '`' | sed -r '/[^=]+=[^=]+/!d' | sed -r 's/\s+=\s/=/g' )"

SNIFFER_INTERVAL=${SNIFFER_INTERVAL:-300}

#exec tshark -l -n -i any -f '(portrange 5001-5999 or 8001-8999) or (net 172.22.0.0/16 and inbound)' -w /var/run/proxysmart/pcap/file.pcap -b interval:$SNIFFER_INTERVAL -b nametimenum:2

exec dumpcap  -n -i any -f '(portrange 5001-5999 or 8001-8999) or (net 172.22.0.0/16 and inbound)' -w /var/run/proxysmart/pcap/file.pcap -b interval:$SNIFFER_INTERVAL -b nametimenum:2

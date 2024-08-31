#!/usr/bin/python3

import sys
import re

def rsrp2bars(rsrp):
    rsrp = int(rsrp)
    if rsrp >= -85:     return 5
    elif rsrp >= -95:   return 4
    elif rsrp >= -105:  return 3
    elif rsrp >= -115:  return 2
    elif rsrp >= -125:  return 1
    else:               return 0

def rscp2bars(rscp):
    if rscp >= -60:             return 5
    elif -75 <= rscp < -60:     return 4
    elif -90 <= rscp < -75:     return 3
    elif -105 <= rscp < -90:    return 2
    elif -120 <= rscp < -105:   return 1
    else:                       return 0

def rssi2bars(rssi):
    # https://www.digi.com/resources/documentation/digidocs/90002316/device/signal-bars-explained.htm
    if rssi >= -80: return 5
    elif -90 <= rssi < -80: return 4
    elif -100 <= rssi < -90: return 3
    elif -106 <= rssi < -100: return 2
    elif -100 <= rssi < -120: return 1
    else: return 0

def usage():
    print("Usage:")
    print("2bars.py rsrp2bars <rsrp_value>")
    print("2bars.py rscp2bars <rscp_value>")
    print("2bars.py rssi2bars <rssi_value>")

def main():
    if len(sys.argv) != 3:
        usage()
        sys.exit(1)

    command = sys.argv[1]
    arg2= sys.argv[2]

    try:
        match=re.search(r'-\d+', arg2)
        if match:
            arg2=int(match.group())

        if   command == 'rsrp2bars':  bars = rsrp2bars(arg2)
        elif command == 'rscp2bars':  bars = rscp2bars(arg2)
        elif command == 'rssi2bars':  bars = rssi2bars(arg2)
        else:
            print("Invalid command.")
            usage()
            sys.exit(1)
            
        
        print(f"{bars}")
    except ValueError:
        print("Invalid RSRP value. Please provide a valid integer.")
        sys.exit(1)

main()



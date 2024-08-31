#!/usr/bin/python3

import huaweisms.api.user
import huaweisms.api.wlan
import huaweisms.api.sms
import huaweisms.api.device
import huaweisms.api.monitoring
import huaweisms.api.dialup
import json
import sys

import urllib3
import time

urllib3.disable_warnings()

def mode_auto(ctx):
    print("=>Auto")
    res = huaweisms.api.dialup.set_mode(ctx, NetworkMode='00', NetworkBand='3FFFFFFF', LTEBand='7FFFFFFFFFFFFFFF' )
    print(json.dumps(res, indent = 4))

def mode_4g(ctx):
    print("=>4g")
    res = huaweisms.api.dialup.set_mode(ctx, NetworkMode='03', NetworkBand='3FFFFFFF', LTEBand='7FFFFFFFFFFFFFFF' )
    print(json.dumps(res, indent = 4))

def reset_ip(ctx):
    print("= Reset IP")
    data_off(ctx) #not needed?
    mode_4g(ctx) #not needed?
    mode_auto(ctx)
    data_on(ctx)

def data_on(ctx):
    print("= Data ON")
    #res = huaweisms.api.dialup.connect_mobile(ctx)
    #print(json.dumps(res, indent = 4))
    res = huaweisms.api.dialup.switch_mobile_on(ctx)
    print(json.dumps(res, indent = 4))

def data_off(ctx):
    print("= Data OFF")
    #res = huaweisms.api.dialup.disconnect_mobile(ctx)
    #print(json.dumps(res, indent = 4))
    res = huaweisms.api.dialup.switch_mobile_off(ctx)
    print(json.dumps(res, indent = 4))


def list_sms(ctx):
    res = huaweisms.api.sms.get_sms(ctx, box_type=1, page=1, qty=50, unread_preferred=False)
    try:
        all_sms=res["response"]["Messages"]["Message"]
    except:
        print('[]')
        sys.exit(1)

    new_sms=[]
    for i in all_sms:
        sms_el={}
        sms_el["Content"]=i["Content"]
        sms_el["Index"]=i["Index"]
        sms_el["Date"]=i["Date"]
        sms_el["Phone"]=i["Phone"]
        new_sms.append(sms_el)

    print(json.dumps(new_sms,  indent = 4))

def reboot(ctx):
    res = huaweisms.api.device.reboot(ctx)
    print(json.dumps(res, indent = 4))

def dump(ctx):
    print("= dump:")
    print("= information")
    res = huaweisms.api.device.information(ctx)
    print(json.dumps(res, indent = 4))

    print("= basic_information")
    print(json.dumps(huaweisms.api.device.basic_information(ctx), indent = 4 ))

    print("= status")
    print(json.dumps(huaweisms.api.monitoring.status(ctx), indent = 4 ))

    print("= get_mobile_status")
    print(json.dumps(huaweisms.api.dialup.get_mobile_status(ctx), indent = 4 ))
    
    print("= profiles")
    print(json.dumps(huaweisms.api.dialup.profiles(ctx), indent = 4 ))

    print("= net_mode")
    print(json.dumps(huaweisms.api.dialup.get_net_mode(ctx), indent = 4 ))

    print("= logout")
    print(json.dumps(huaweisms.api.user.logout(ctx), indent = 4 ))

def usage():
    print(sys.argv[0] +" IP LOGIN PW <dump|list_sms|reboot|data_on|data_off|reset_ip|mode_auto|mode_4g")
    sys.exit(1)

def main():
    try:
        ip=sys.argv[1]
    except:
        usage()
    try:
        login=sys.argv[2]
    except:
        usage()
    try:
        password=sys.argv[3]
    except:
        usage()
    try:
        action=sys.argv[4]
    except:
        usage()


    allowed_actions=[ "dump", "list_sms", "reboot", "data_on", "data_off", "reset_ip", "mode_auto", "mode_4g" ] 

    if not action in allowed_actions:
        usage()

    try:
        #ctx = huaweisms.api.user.quick_login(login, password,  modem_host=ip )
        ctx = huaweisms.api.user.quick_login( login, password,  modem_host=ip, uri_scheme='https',   verify=False )
    except:
        print("= login failed")
        sys.exit(1)

    if  action == "dump"         : dump(ctx)
    elif action == "list_sms"   : list_sms(ctx)
    elif action == "reboot"     : reboot(ctx)
    elif action == "data_on"    : data_on(ctx)
    elif action == "data_off"   : data_off(ctx)
    elif action == "reset_ip"   : reset_ip(ctx)
    elif action == "mode_auto"   : mode_auto(ctx)
    elif action == "mode_4g"   : mode_4g(ctx)
    else:
        usage()
    
main()

# ./CPE_helper.py 192.168.8.1 admin mtQgeh7m4qtN  dump  


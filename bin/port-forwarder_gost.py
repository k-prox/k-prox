#!/usr/bin/env python3

# forwards some ports from Localhost to VPS

import sys
sys.path.append('/usr/share/proxysmart/helpers/python/lib')
from pxfwd import run_port_forwarder_gost

while True:
    run_port_forwarder_gost()


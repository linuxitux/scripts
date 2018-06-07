#!/usr/bin/env python

# Emiliano Marini
# www.linuxito.com

"""
vSphere Python SDK script to list all Datastores and their free space
"""

import argparse
import atexit
import json
import ssl

from pyVim import connect
from pyVmomi import vmodl
from pyVmomi import vim

from tools import cli

#==== get args =================================================================
def get_args():
    """
    Supports the command-line arguments listed below.
    """
    parser = argparse.ArgumentParser(
        description='Process args for retrieving all the Virtual Machines')
    parser.add_argument('-s', '--host', required=True, action='store',
        help='Remote host to connect to')
    parser.add_argument('-o', '--port', type=int, default=443, action='store',
        help='Port to connect on')
    parser.add_argument('-u', '--user', required=True, action='store',
        help='Username to use when connecting to host')
    parser.add_argument('-p', '--password', required=True, action='store',
        help='Password to use when connecting to host')
    parser.add_argument('-j', '--json', default=False, action='store_true',
        help='Output in JSON format')
    parser.add_argument('-S', '--disable_ssl_verification',
        required=False,
        action='store_true',
        help='Disable ssl host certificate verification')
    args = parser.parse_args()
    return args

#==== print_size ===============================================================
# http://stackoverflow.com/questions/1094841/
def print_size(num):
    """
    Returns the human readable version of a size in bytes

    :param num:
    :return:
    """
    for item in ['bytes', 'KB', 'MB', 'GB']:
        if num < 1024.0:
            return "%3.1f %s" % (num, item)
        num /= 1024.0
    return "%.1f %s" % (num, 'TB')

#==== main =====================================================================
def main():
    """
    Simple command-line script to list the datastore space used by each vm
    """
    args = get_args()

    cli.prompt_for_password(args)

    sslContext = None

    if args.disable_ssl_verification:
        sslContext = ssl.SSLContext(ssl.PROTOCOL_SSLv23)
        sslContext.verify_mode = ssl.CERT_NONE

    try:
        service_instance = connect.SmartConnect(host=args.host,
            user=args.user,
            pwd=args.password,
            port=int(args.port),
            sslContext=sslContext)
        if not service_instance:
            print("Could not connect to the specified host using specified "
                "username and password")
            return -1

        atexit.register(connect.Disconnect, service_instance)

        content = service_instance.RetrieveContent()
        # Search for all VirtualMachine objects
        objview = content.viewManager.CreateContainerView(content.rootFolder,
            [vim.VirtualMachine],
            True)
        vms = objview.view
        objview.Destroy()

        datastores = {}

        if not args.json:
            print("Datastore usage per virtual machine (commited + uncommited)")
            print("-----------------------------------------------------------")
        for vm in vms:
            vm_name = vm.config.name
            if vm.runtime.powerState == vim.VirtualMachine.PowerState.poweredOn:
                # List only powered on vms
                if not args.json:
                    print("%s:" % vm_name)
                    for ds in vm.storage.perDatastoreUsage:
                        print(" |- %s: %s + %s" % (ds.datastore.info.name,
                                               print_size(ds.committed),
                                               print_size(ds.uncommitted)))
                    print
                else:
                    for ds in vm.storage.perDatastoreUsage:
                        ds_name = ds.datastore.info.name
                        if not ds_name in datastores:
                            # Create an empty dict if key isn't present
                            datastores[ds_name] = {}
                        if not vm_name in datastores[ds_name]:
                            # Create an empty dict if key isn't present
                            datastores[ds_name][vm_name] = {}
                        # Group vms by datastore
                        datastores[ds_name][vm_name]['committed'] = ds.committed
                        datastores[ds_name][vm_name]['uncommitted'] = ds.uncommitted

        if args.json:
            # Dump in JSON format
            print(json.dumps(datastores))

    except vmodl.MethodFault as error:
        print("Caught vmodl fault : " + error.msg)
        return -1

    return 0

# Start program
if __name__ == "__main__":
    main()

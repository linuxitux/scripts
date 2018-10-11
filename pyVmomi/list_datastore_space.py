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

#==== print_free ===============================================================
def print_free(datastore):
    """
    Prints the name, size and free space of a datastore

    :param datastore:
    :return:
    """
    capacity = datastore.summary.capacity
    freeSpace = datastore.summary.freeSpace
    print("{} {}".format("Datastore:  ", datastore.summary.name))
    print("{} {}".format("Capacity:   ", print_size(capacity)))
    print("{} {}".format("Free space: ", print_size(freeSpace)))
    pFreeSpace = "%2.2f %s" % (freeSpace*100.0/capacity, '%')
    print("{} {}".format('%free:      ', pFreeSpace))
    print("")

#==== main =====================================================================
def main():
    """
    Simple command-line script to listing all datastores and their free space
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
        # Search for all Datastores
        objview = content.viewManager.CreateContainerView(content.rootFolder,
            [vim.Datastore],
            True)
        datastores = objview.view
        objview.Destroy()

        datastore_space = {}
        for datastore in datastores:
            if not args.json:
                print_free(datastore)
            else:
                capacity = datastore.summary.capacity
                freeSpace = datastore.summary.freeSpace
                datastore_details = {
                    'capacity': capacity,
                    'bfree': freeSpace,
                    'pfree': "%2.2f" % (freeSpace*100.0/capacity)
                    }
                datastore_space[datastore.summary.name] = datastore_details

        if args.json:
            print(json.dumps(datastore_space))

    except vmodl.MethodFault as error:
        print("Caught vmodl fault : " + error.msg)
        return -1

    return 0

# Start program
if __name__ == "__main__":
    main()


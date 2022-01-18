# 
# Perform a reconnect of the vCenter endpoint in VCD and wait
# Quick & Dirty, not a lot of checks, use at your own risks.
#

import requests
import time
from pyvcloud.vcd.client import BasicLoginCredentials
from pyvcloud.vcd.client import Client
from pyvcloud.vcd.client import EntityType

# Disable warnings from self-signed certificates.
requests.packages.urllib3.disable_warnings()

# Login
client = Client("vcd.corp.local",
                api_version='36.0',
                verify_ssl_certs=False,
                log_file='pyvcloud.log',
                log_requests=True,
                log_headers=True,
                log_bodies=True)
while True:
    try:
        client.set_credentials(BasicLoginCredentials("administrator", "system", "VMware1!"))
        break
    except:
        time.sleep(20)

vcenter_is_connected = False
while not vcenter_is_connected:
    vc = client.get_resource("https://vcd.corp.local/api/admin/extension/vimServer/814c678c-619f-48df-9f9b-ce335a2bfcf9")
    vcenter_is_connected = vc.IsConnected
    time.sleep(20)


task = client.post_resource("https://vcd.corp.local/api/admin/extension/vimServer/814c678c-619f-48df-9f9b-ce335a2bfcf9/action/forcevimserverreconnect", {}, EntityType.JSON.value)

taskmonitor = client.get_task_monitor()
taskmonitor.wait_for_success(task)

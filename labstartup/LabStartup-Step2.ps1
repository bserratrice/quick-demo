Write-Output "Disable datastore storage usage alarm"
Get-Datastore esx-01-local-storage | Get-AlarmDefinition -Name "Datastore usage on disk" | Set-AlarmDefinition -enabled:$false | Out-Null
Get-Datastore esx-02-wcp-supervisor-vm | Get-AlarmDefinition -Name "Datastore usage on disk" | Set-AlarmDefinition -enabled:$false | Out-Null
Get-Datastore esx-03-wcp-supervisor-vm | Get-AlarmDefinition -Name "Datastore usage on disk" | Set-AlarmDefinition -enabled:$false | Out-Null
Get-Datastore esx-04-wcp-supervisor-vm | Get-AlarmDefinition -Name "Datastore usage on disk" | Set-AlarmDefinition -enabled:$false | Out-Null

Write-Output "Disable Host memory usage alarm"
Get-VMHost esx-01.corp.local | Get-AlarmDefinition -Name "Host memory usage" | Set-AlarmDefinition -enabled:$false | Out-Null
Get-VMHost esx-02.corp.local | Get-AlarmDefinition -Name "Host memory usage" | Set-AlarmDefinition -enabled:$false | Out-Null
Get-VMHost esx-03.corp.local | Get-AlarmDefinition -Name "Host memory usage" | Set-AlarmDefinition -enabled:$false | Out-Null
Get-VMHost esx-04.corp.local | Get-AlarmDefinition -Name "Host memory usage" | Set-AlarmDefinition -enabled:$false | Out-Null

Write-Output "Disable vSAN Alarm"
Get-Cluster "VMware-Cloud" | Get-AlarmDefinition -Name "vSAN Health Alarm 'Disks usage on storage controller'" | Set-AlarmDefinition -enabled:$false | Out-Null
Get-Cluster "VMware-Cloud" | Get-AlarmDefinition -Name "vSAN Health Alarm 'vSAN max component size'" | Set-AlarmDefinition -enabled:$false | Out-Null
Get-Cluster "VMware-Cloud" | Get-AlarmDefinition -Name "vSAN Support Insight" | Set-AlarmDefinition -enabled:$false | Out-Null
Get-Cluster "VMware-Cloud" | Get-AlarmDefinition -Name "vSAN hardware compatibility issues" | Set-AlarmDefinition -enabled:$false | Out-Null
Get-Cluster "VMware-Cloud" | Get-AlarmDefinition -Name "vSAN health alarm 'Performance service status'" | Set-AlarmDefinition -enabled:$false | Out-Null
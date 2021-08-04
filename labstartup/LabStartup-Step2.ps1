# Apply Hotfix
& (Join-Path $PSScriptRoot "HotFix-Step2.ps1")

# Fix DRS issues
Write-Output "Check DRS configuration issues"
Get-VMHost | Where-Object {$_.ExtensionData.ConfigIssue.FullFormattedMessage -like "Unable to apply DRS*"} | ForEach-Object {
    Write-Output "DRS configuration issue for host $($_.Name), restarting hostd service."
    Invoke-Plink -remoteHost $_.Name -login root -passwd VMware1! -command "/etc/init.d/hostd restart"
    Do {
        Start-Sleep -Seconds 10
    } While ((Get-VMHost -Name esx-03.corp.local).ConnectionState -ne "Connected")
}

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

Write-Output "Disable Network Alarms"
Get-VMHost esx-01.corp.local | Get-AlarmDefinition -Name "Network connectivity lost" | Set-AlarmDefinition -enabled:$false | Out-Null
Get-VMHost esx-02.corp.local | Get-AlarmDefinition -Name "Network connectivity lost" | Set-AlarmDefinition -enabled:$false | Out-Null
Get-VMHost esx-03.corp.local | Get-AlarmDefinition -Name "Network connectivity lost" | Set-AlarmDefinition -enabled:$false | Out-Null
Get-VMHost esx-04.corp.local | Get-AlarmDefinition -Name "Network connectivity lost" | Set-AlarmDefinition -enabled:$false | Out-Null

Get-VMHost esx-01.corp.local | Get-AlarmDefinition -Name "Network uplink redundancy lost" | Set-AlarmDefinition -enabled:$false | Out-Null
Get-VMHost esx-02.corp.local | Get-AlarmDefinition -Name "Network uplink redundancy lost" | Set-AlarmDefinition -enabled:$false | Out-Null
Get-VMHost esx-03.corp.local | Get-AlarmDefinition -Name "Network uplink redundancy lost" | Set-AlarmDefinition -enabled:$false | Out-Null
Get-VMHost esx-04.corp.local | Get-AlarmDefinition -Name "Network uplink redundancy lost" | Set-AlarmDefinition -enabled:$false | Out-Null

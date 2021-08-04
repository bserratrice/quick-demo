WritePodSkuToDesktopInfo "VCPP Demo (VCD 10.3.0)"
Write-VpodProgress "Checking ESX and Start VSAN" 'STARTING'
Remove-Item -Path "C:\hol\labcheck.bat" -Force -Confirm:$false

# Wait for ESX-01
@("esx-01.corp.local", "esx-02.corp.local", "esx-03.corp.local", "esx-04.corp.local") | ForEach-Object {
    Do {
        Test-TcpPortOpen -Server $_ -Port 22 -Result ([REF]$result)
        LabStartup-Sleep $sleepSeconds
    } Until ($result -eq "success")
}
Start-Sleep -Seconds 60
# Recover vSAN
While ($true) {
    Try {
        Invoke-Plink -remoteHost esx-01.corp.local -login root -passwd VMware1! -command "python /usr/lib/vmware/vsan/bin/reboot_helper.py recover"
        Break
    }
    Catch { LabStartup-Sleep $sleepSeconds }
}

Start-Sleep -Seconds 120

# Connect to ESXi
Connect-VIserver esx-01.corp.local -username root -password VMware1! -ErrorAction SilentlyContinue
Connect-VIserver esx-02.corp.local -username root -password VMware1! -ErrorAction SilentlyContinue
Connect-VIserver esx-03.corp.local -username root -password VMware1! -ErrorAction SilentlyContinue
Connect-VIserver esx-04.corp.local -username root -password VMware1! -ErrorAction SilentlyContinue

# Check vSAN is ready - TODO
(Get-VMHost | Get-EsxCli -V2) | 
ForEach-Object { $_.vsan.cluster.get.Invoke() } | 
Select-Object LocalNodeUUID, LocalNodeHealthState, SubClusterMemberCount

# Enable cluster member updates
Get-VMHost | ForEach-Object { 
    Get-AdvancedSetting -Name "VSAN.IgnoreClusterMemberListUpdates" -Entity $_ | 
    Set-AdvancedSetting -Value 0 -Confirm:$false | 
    Select-Object Name, Value
}
Disconnect-VIserver * -Confirm:$false | Out-Null

# wait for vcenter
Write-VpodProgress "Checking vCenter Services" 'STARTING'

Foreach ($entry in $vCenters) {
    ($vcserver, $type, $loginUser) = $entry.Split(":")
    $cisConnection = $null
    $applianceService = $null

    Do {
        Try {
            if (!$cisConnection.IsConnected) {
                $cisConnection = Connect-CisServer -Server $vcserver -User $vcuser -Password $password -ErrorAction Stop 2> $null
            }
            $vapi_service = (Get-CisService).Count
            Write-Output "vAPI Service found: $vapi_service"
            if ($vapi_service -lt 1) { Continue }

            $applianceService = Get-CisService com.vmware.appliance.vmon.service
            $vcsaServicesStopped = $applianceService.list_details().GetEnumerator() | Where-Object { $_.Value.startup_type -eq "AUTOMATIC" -and $_.Value.state -ne "STARTED" -and $_.Value.health -ne "HEALTHY" }
            if ($vcsaServicesStopped) {
                $vcsaServicesStoppedLog = ""
                $vcsaServicesStopped | ForEach-Object {
                    $vcsaServicesStoppedLog += "$($_.Key) ($($_.Value.state)), "
                    # if ($_.Value.startup_type -eq "AUTOMATIC" -and $_.Value.state -eq "STOPPED") {
                    #     Write-Output "Start Automatic service '$($_.Key)'"
                    #     $applianceService.start($_.Key)
                    # }
                }
                Write-Output "Waiting for vCenter AUTOMATIC Services to start: $vcsaServicesStoppedLog"
                if ($cisConnection) { $cisConnection | Disconnect-CisServer -Confirm:$false | Out-Null  2> $null }
                Start-Sleep 30
            }
        }
        Catch {
            Write-Output "An issue occured while vCenter services are started ($vcserver as $vcuser): $($Error[0].Exception.Message)"
            if ($cisConnection) { $cisConnection | Disconnect-CisServer -Confirm:$false | Out-Null  2> $null }
            Start-Sleep 20
        }
    } Until ($cisConnection.IsConnected -and !$vcsaServicesStopped)

    #$applianceService.list_details().Values | Format-Table -Property name_key, state, health | Write-Output
    ($applianceService.list_details().GetEnumerator() | ForEach-Object { "$($_.Key) ($($_.Value.state)/$($_.Value.health))" } | Out-String).Trim().Replace("`r`n", ", ") | Write-Output

    Write-Output "Connection to vCenter OK, all AUTOMATIC services are started"
    $cisConnection | Disconnect-CisServer -Confirm:$false | Out-Null  2> $null
}

# Start Supervisor VM
Connect-VIserver esx-02.corp.local -username root -password VMware1! -ErrorAction SilentlyContinue
Connect-VIserver esx-03.corp.local -username root -password VMware1! -ErrorAction SilentlyContinue
Connect-VIserver esx-04.corp.local -username root -password VMware1! -ErrorAction SilentlyContinue

Get-VM | 
Where-Object {$_.PowerState -eq "PoweredOff" -and ($_.Name -like "SupervisorControlPlaneVM*") } | 
Start-VM -Confirm:$false

Disconnect-VIserver * -Confirm:$false | Out-Null
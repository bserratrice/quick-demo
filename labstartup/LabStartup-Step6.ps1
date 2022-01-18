# Wait for VCD
Write-VpodProgress "Check VCD" 'GOOD-8'
$vcdCheckPath = Join-Path $PSScriptRoot "vcd-restart-vcenter-connection.py"
python $vcdCheckPath
# Wait for VCD
Write-VpodProgress "Check VCD"
$vcdCheckPath = Join-Path $PSScriptRoot "vcd-restart-vcenter-connection.py"
python $vcdCheckPath
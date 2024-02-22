$ResourceGroupName = "rg-hub-tfmex-adv"
$FirewallName = "fw-hub-tfmex-adv"
$VNETName = "vnet-hub-tfmex-adv"
$PublicIP = "fw-pip-hub-tfmex-adv"
# $MGMTIP = ""      add if needed

# Get the Azure Firewall
$azfw = Get-AzFirewall -ResourceGroupName $ResourceGroupName -Name $FirewallName

# Get existing Public IP info 
$pip = Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Name $PublicIP

# Stop the Azure Firewall
$azfw.Deallocate()
$azfw | Set-AzFirewall

# Configure Azure Firewall for Zone redundancy
$vnet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VNETName

# Delete existing Public IP
Remove-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Name $PublicIP -Force

# Create new Zone redundant IP
$newPip = New-AzPublicIpAddress -Name $pip.Name -ResourceGroupName $pip.ResourceGroupName -Location $pip.Location -Tag $pip.Tags -AllocationMethod $pip.PublicIpAllocationMethod -Sku Standard
# $mgmtPip2 = Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Name $MGMTIP     add if needed

# Set Zone Redundancy and allocate vnet & public ip to the Firewall
$azfw.Allocate($vnet, $newPip<#, $mgmtPip2#>)  # add if needed
$azFw.Zones=1,2,3
$azfw | Set-AzFirewall

# Start the Azure Firewall
# $azfw.Allocate()
# $azfw | Set-AzFirewall
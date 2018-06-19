#Param(
#[string]$secpasswd,
#[string]$vmsize
#)

# Variables for common values
$resourceGroup = "iac-uks-desktop-poc-rg"
$location = "West Europe"
$rand = Get-Random

# TEMP
$vmsize = "Standard_A1"
$secpasswd = ConvertTo-SecureString "Manchester21!" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("iac-admin", $secpasswd)

# Create a public IP address and specify a DNS name
$pip = New-AzureRmPublicIpAddress -ResourceGroupName $resourceGroup -Location $location `
  -Name "Windows-Desktop-PIP-$rand" -AllocationMethod Static -IdleTimeoutInMinutes 4

# Get vNet and Subnet ID
$vnet = Get-AzureRmVirtualNetwork -Name Workspace-vNet -ResourceGroupName iac-uks-network-poc-rg

# Get Network Security Group
$nsg = Get-AzureRmNetworkSecurityGroup -Name Windows-Desktop-NSG -ResourceGroupName iac-uks-network-poc-rg

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzureRmNetworkInterface -Name myNic -ResourceGroupName $resourceGroup -Location $location `
  -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

# Create a virtual machine configuration
$vmConfig = New-AzureRmVMConfig -VMName "Windows-Desktop-$rand"  -VMSize $vmsize | `
Set-AzureRmVMOperatingSystem -Windows -ComputerName "Windows-Desktop-$rand"  -Credential $cred | `
Set-AzureRmVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2016-Datacenter -Version latest | `
Add-AzureRmVMNetworkInterface -Id $nic.Id

# Create a virtual machine
New-AzureRmVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig
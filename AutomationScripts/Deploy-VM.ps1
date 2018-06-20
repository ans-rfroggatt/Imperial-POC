#Param(
#[string]$secpasswd,
#[string]$vmsize,
#[string]$OperatingSystem
#)

# Variables for common values
$resourceGroup = "iac-uks-desktop-poc-rg"
$location = "West Europe"
$rand = Get-Random -Maximum 999999

# TEMP
$OperatingSystem = 'Windows'
$vmsize = "Standard_A1"
$secpasswd = ConvertTo-SecureString "Manchester21!" -AsPlainText -Force

#Create Credential Object
$cred = New-Object System.Management.Automation.PSCredential ("iac-admin", $secpasswd)

# Create a public IP address and specify a DNS name
$pip = New-AzureRmPublicIpAddress -ResourceGroupName $resourceGroup -Location $location `
  -Name "Windows-Desktop-PIP-$rand" -AllocationMethod Static -IdleTimeoutInMinutes 4

# Get vNet and Subnet ID
$vnet = Get-AzureRmVirtualNetwork -Name Workspace-vNet -ResourceGroupName iac-uks-network-poc-rg



if ($OperatingSystem -eq 'Windows') {
# Get Network Security Group
$nsg = Get-AzureRmNetworkSecurityGroup -Name Windows-Desktop-NSG -ResourceGroupName iac-uks-network-poc-rg

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzureRmNetworkInterface -Name "WDesktop-NIC-$rand" -ResourceGroupName $resourceGroup -Location $location `
  -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

# Create a virtual machine configuration
$vmConfig = New-AzureRmVMConfig -VMName "WDesktop-$rand"  -VMSize $vmsize | `
Set-AzureRmVMOperatingSystem -Windows -ComputerName "WDesktop-$rand"  -Credential $cred | `
Set-AzureRmVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2016-Datacenter -Version latest | `
Add-AzureRmVMNetworkInterface -Id $nic.Id | `
Set-AzureRmVMBootDiagnostics -Disable
}

if ($OperatingSystem -eq 'Linux') {
# Get Network Security Group
$nsg = Get-AzureRmNetworkSecurityGroup -Name Linux-Desktop-NSG -ResourceGroupName iac-uks-network-poc-rg

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzureRmNetworkInterface -Name "LDesktop-NIC-$rand" -ResourceGroupName $resourceGroup -Location $location `
  -SubnetId $vnet.Subnets[1].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

# Create a virtual machine configuration
$vmConfig = New-AzureRmVMConfig -VMName "LDesktop-$rand"  -VMSize $vmsize | `
Set-AzureRmVMOperatingSystem -Linux -ComputerName "LDesktop-$rand"  -Credential $cred | `
Set-AzureRmVMSourceImage -PublisherName Canonical -Offer UbuntuServer -Skus 16.04-LTS -Version latest | `
Add-AzureRmVMNetworkInterface -Id $nic.Id | `
Set-AzureRmVMBootDiagnostics -Disable
}

# Create a virtual machine
$vm = New-AzureRmVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig

#Output VMName, Username and IP.
Write-Host $vm.OSProfile.ComputerName" -> "$vm.OSProfile.AdminUsername" -> "$nic.IpConfigurations[0].PrivateIpAddress
Param(
[string]$password,
[string]$vmsize,
[string]$os,
[string]$expiration
)

<#
    .DESCRIPTION
        Runbook to deploy virtual machine desktops on demand.

    .NOTES
        AUTHOR: ANS - Ryan Froggatt
        LASTEDIT: Jun 20, 2018
#>

$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}


# Variables for common values
$resourceGroup = "iac-uks-desktop-poc-rg"
$location = "West Europe"
$rand = Get-Random -Maximum 999999


#Create Credential Object
$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("iac-admin", $secpasswd)

# Create a public IP address and specify a DNS name
$pip = New-AzureRmPublicIpAddress -ResourceGroupName $resourceGroup -Location $location `
  -Name "Windows-Desktop-PIP-$rand" -AllocationMethod Static -IdleTimeoutInMinutes 4

# Get vNet and Subnet ID
$vnet = Get-AzureRmVirtualNetwork -Name Workspace-vNet -ResourceGroupName iac-uks-network-poc-rg


# Create Relevant Configuration Based on OS Type
if ($os -eq 'Windows') {

# Get Network Security Group
$nsg = Get-AzureRmNetworkSecurityGroup -Name Windows-Desktop-NSG -ResourceGroupName iac-uks-network-poc-rg

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzureRmNetworkInterface -Name "WDesktop-NIC-$rand" -ResourceGroupName $resourceGroup -Location $location `
  -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

# Create a virtual machine configuration
$vmConfig = New-AzureRmVMConfig -VMName "WDesktop-$rand"  -VMSize $vmsize -Tags @{'Expiration DateTime'=$expiration}| `
Set-AzureRmVMOperatingSystem -Windows -ComputerName "WDesktop-$rand"  -Credential $cred | `
Set-AzureRmVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2016-Datacenter -Version latest | `
Add-AzureRmVMNetworkInterface -Id $nic.Id | `
Set-AzureRmVMBootDiagnostics -Disable
}

if ($os -eq 'Linux') {

# Get Network Security Group
$nsg = Get-AzureRmNetworkSecurityGroup -Name Linux-Desktop-NSG -ResourceGroupName iac-uks-network-poc-rg

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzureRmNetworkInterface -Name "LDesktop-NIC-$rand" -ResourceGroupName $resourceGroup -Location $location `
  -SubnetId $vnet.Subnets[1].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

# Create a virtual machine configuration
$vmConfig = New-AzureRmVMConfig -VMName "LDesktop-$rand"  -VMSize $vmsize -Tags @{'Expiration DateTime'=$expiration}| `
Set-AzureRmVMOperatingSystem -Linux -ComputerName "LDesktop-$rand"  -Credential $cred | `
Set-AzureRmVMSourceImage -PublisherName Canonical -Offer UbuntuServer -Skus 16.04-LTS -Version latest | `
Add-AzureRmVMNetworkInterface -Id $nic.Id | `
Set-AzureRmVMBootDiagnostics -Disable
}

# Create the Virtual Machine
$vm = New-AzureRmVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig

#Output VMName, Username and IP.
Write-Output "VM Name    -> "$vm.OSProfile.ComputerName
Write-Output "Username   -> "$vm.OSProfile.AdminUsername
Write-Output "IP Address -> "$nic.IpConfigurations[0].PrivateIpAddress
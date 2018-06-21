<#
    .DESCRIPTION
        Runbook to cleanup expired virtual machine desktops based on Expiration DateTime tag.

    .NOTES
        AUTHOR: ANS - Ryan Froggatt
        LASTEDIT: Jun 21, 2018
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


$rgName = 'iac-uks-desktop-poc-rg'


#Import ARM Module
Import-Module -Name AzureRM

foreach ($VM in Get-AzureRmVM -ResourceGroupName $rgName | Where-Object {$_.Tags.'Expiration DateTime' -ne $null}) {
    
    #Get Expiration DateTime Tag
    $Expiration = [DateTime]$VM.Tags.'Expiration DateTime'

    #Get Current DateTime
    $DateTime = Get-Date
    
    if ($Expiration -lt $DateTime.DateTime) {

    Write-Host "Deleting " $VM.Name

    #Get Associated VM Resources
    $nic = $VM.NetworkProfile.NetworkInterfaces.Id
    $nicName = $nic.Split('/')[8]
    $osDisk = $VM.StorageProfile.OsDisk.Name

    #Remove VM
    Remove-AzureRmVM -ResourceGroupName $rgName -Name $VM.Name -Force


    #Remove NIC
    Remove-AzureRmNetworkInterface -ResourceGroupName $rgName -Name $nicName -Force

    #Remove Disk
    Remove-AzureRmDisk -ResourceGroupName $rgName -DiskName $osDisk -Force
    }

    else {
    Write-Host $VM.Name"has not yet expired"
    }   
}
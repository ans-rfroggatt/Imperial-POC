##

$rgName = 'Nano'

foreach ($VM in Get-AzureRmVM -ResourceGroupName $rgName | Where-Object {$_.Tags.'Expiration DateTime' -ne $null}) {
    
    #Get Expiration DateTime Tag
    $Expiration = $VM.Tags.'Expiration DateTime'

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
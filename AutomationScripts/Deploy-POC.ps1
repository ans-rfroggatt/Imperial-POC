<#
    .DESCRIPTION
        PS Script to Deploy Imperial POC Environment.

    .NOTES
        AUTHOR: ANS - Ryan Froggatt
        LASTEDIT: Jun 21, 2018
#>

#Install and Import AzureRM Module
Write-Host "[$(get-date -Format "dd/mm/yy hh:mm:ss")] Importing module..."
Import-Module -Name AzureRM -ErrorVariable ModuleError -ErrorAction SilentlyContinue
If ($ModuleError) {
    Write-Host "[$(get-date -Format "dd/mm/yy hh:mm:ss")] Installing module..."
    Install-Module -Name AzureRM
    Import-Module -Name AzureRM
    Write-Host "[$(get-date -Format "dd/mm/yy hh:mm:ss")] Successfully Installed module..."
}
Write-Host "[$(get-date -Format "dd/mm/yy hh:mm:ss")] Successfully Imported module"
Write-Host ""

#Login to Azure
Write-Host "[$(get-date -Format "dd/mm/yy hh:mm:ss")] Logging in to Azure Account..."
Login-AzureRmAccount
Write-Host "[$(get-date -Format "dd/mm/yy hh:mm:ss")] Successfully logged in to Azure Account"
Write-Host ""

#Select SubscriptionId
$SubId = Read-Host "Please input your Subscription Id"
while ($SubId.Length -le 35) {
    Write-Host "[$(get-date -Format "dd/mm/yy hh:mm:ss")] Subscription Id not valid"
    $SubId = Read-Host "Please input your Subscription Id"
}
Select-AzureRmSubscription -SubscriptionId $SubId
Write-Host "[$(get-date -Format "dd/mm/yy hh:mm:ss")] Subscription successfully selected"
Write-Host ""

#Configure Azure Location to Deploy POC
$Location = Read-Host "Enter the location to deploy the POC"

# Create Required Resource Groups
New-AzureRmResourceGroup -Name iac-uks-network-poc-rg -Location "West Europe"
New-AzureRmResourceGroup -Name iac-uks-desktop-poc-rg -Location "West Europe"
New-AzureRmResourceGroup -Name iac-uks-automation-poc-rg -Location "West Europe"


# Deploy Core Networking Resources
New-AzureRmResourceGroupDeployment -ResourceGroupName iac-uks-network-poc-rg -TemplateUri https://raw.githubusercontent.com/ans-rfroggatt/Imperial-POC/master/Networking/Networking-Master.json `
-TemplateParameterUri https://raw.githubusercontent.com/ans-rfroggatt/Imperial-POC/master/Networking/Networking-Master-Parameters.json


# Deploy Automation Infrastructure Resources
New-AzureRmResourceGroupDeployment -ResourceGroupName iac-uks-automation-poc-rg -TemplateUri https://raw.githubusercontent.com/ans-rfroggatt/Imperial-POC/master/Infrastructure/Automation-Infrastructure.json `
-TemplateParameterUri https://raw.githubusercontent.com/ans-rfroggatt/Imperial-POC/master/Infrastructure/Automation-Infrastructure-Parameters.json

## Manual Steps!
# Manually Trigger creation of Run As Account
# Manually Update PowerShell Modules in Automation Account
# Manually Import AzureRM.Network Module from Module Gallery in Automation Account
# Manually re-assign Run As Account Service Principal to Contributor Permissions on the Resource Group

# Trigger Azure Automation Runbook to Deploy Test Windows Desktop
$params = @{"password"="Password123!!"; "vmsize"="Standard_A1"; "os"="Windows"; "expiration"="21 June 2018 13:00:00"}
Start-AzureRmAutomationRunbook –AutomationAccountName iac-uks-desktop-automation -Name iac-uks-desktop-automation-deployment `
-ResourceGroupName iac-uks-automation-poc-rg –Parameters $params

# Trigger Azure Automation Runbook to Deploy Test Linux Desktop
$params = @{"password"="Password123!!!"; "vmsize"="Standard_A1"; "os"="Linux"; "expiration"="21 June 2018 13:00:00"}
Start-AzureRmAutomationRunbook –AutomationAccountName iac-uks-desktop-automation -Name iac-uks-desktop-automation-deployment `
-ResourceGroupName iac-uks-automation-poc-rg –Parameters $params

# Trigger Azure Automation Runbook to Clean Up Desktops
Start-AzureRmAutomationRunbook –AutomationAccountName iac-uks-desktop-automation -Name iac-uks-desktop-automation-cleanup -ResourceGroupName iac-uks-automation-poc-rg
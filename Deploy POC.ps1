#Deploy Imperial POC

Login-AzureRmAccount

$SubID = Read-Host "Enter your Subscription Id"

Select-AzureRmSubscription -SubscriptionId 9c15dde4-f4fa-4de2-8655-8b81421fd628

$Location = Read-Host "Enter the location to deploy the POC"

#Create Required Resource Groups
New-AzureRmResourceGroup -Name iac-uks-network-poc-rg -Location "West Europe"
New-AzureRmResourceGroup -Name iac-uks-desktop-poc-rg -Location "West Europe"
New-AzureRmResourceGroup -Name iac-uks-function-poc-rg -Location "West Europe"


#Deploy Core Networking Resources
New-AzureRmResourceGroupDeployment -ResourceGroupName iac-uks-network-poc-rg -TemplateUri https://raw.githubusercontent.com/ans-rfroggatt/Imperial-POC/master/Networking-Master.json `
-TemplateParameterUri https://raw.githubusercontent.com/ans-rfroggatt/Imperial-POC/master/Networking-Master-Parameters.json


#Deploy Azure Function App
New-AzureRmResourceGroupDeployment -ResourceGroupName iac-uks-function-poc-rg -TemplateUri


#Trigger Azure Function to Deploy Test Desktop
.\Deploy-Windows-VM.ps1
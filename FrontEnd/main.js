var AuthenticationContext = require('adal-node').AuthenticationContext;
var request = require('request');
var uuid = require('uuid');
 
var subscriptionId = "88cb1a8a-aec4-42c4-914c-01e95c0b88e4";
var resourceGroupName = "iac-uks-automation-poc-rg";
var automationAccountName = 'iac-uks-desktop-automation';
var jobId = uuid.v1();
var authorityHostUrl = 'https://login.windows.net';
var tenant = "fb72cdc9-c5b5-4683-8c68-337a13edc5a9"; // AAD Tenant name.
var authorityUrl = authorityHostUrl + '/' + tenant;
var applicationId = 'd01e0712-c8a1-402c-bc96-4f6920964dd1'; // Application Id of app registered under AAD.
var clientSecret = 'nvm528Et+56xMldH5Mz2EVMX8GJYpKX14uabSsAxZoM='; // Secret generated for app. Read this environment variable.
var resource = "https://management.core.windows.net/"; // URI that identifies the resource for which the token is valid.

var context = new AuthenticationContext(authorityUrl);

function trigger_runbook() {

    context.acquireTokenWithClientCredentials(resource, applicationId, clientSecret, (err, tokenResponse) => {
        if (err) {
            console.log('well that didn\'t work: ' + err.stack);
        }
        request.put({
            headers: { 'Authorization': 'Bearer ' + tokenResponse.accessToken },
            url: 'https://management.azure.com/subscriptions/' + subscriptionId + '/resourceGroups/' + resourceGroupName + '/providers/Microsoft.Automation/automationAccounts/' + automationAccountName + '/jobs/' + jobId + '?api-version=2015-10-31',
            body: {
                properties: {
                    runbook: {
                        name: "iac-uks-desktop-automation-deployment"
                    },
                    parameters: {
                        password: "Netapp123",
                        vmsize: "Standard_A1",
                        os: "Windows",
                        expiration: "21 June 2018 14: 00: 00"
                    }
                },
                name: "iac-uks-desktop-automation-deployment",
                location: "West Europe"
            },
            json: true
        }, function (error, response, body) {
            console.log(body);
        });
    });
}

$(document).ready(function () {
    $("button").click(function () {
        var query = $('input, select').serialize();
        console.log(query)
    });
});
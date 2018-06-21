var AuthenticationContext = require('adal-node').AuthenticationContext;
var request = require('request');
var uuid = require('uuid');


var subscriptionId = "9c15dde4-f4fa-4de2-8655-8b81421fd628";
var resourceGroupName = "iac-uks-automation-poc-rg";
var automationAccountName = 'iac-uks-desktop-automation';
var jobId = uuid.v1();
var authorityHostUrl = 'https://login.windows.net';
var tenant = "207c1c4e-52d3-4eb2-9625-adcd3968b029"; // Directory ID of AD Tenant.
var authorityUrl = authorityHostUrl + '/' + tenant;
var applicationId = 'c0d38cb3-879a-43a1-bc7e-268dddef8537'; // Application Id of app registered under AAD.
var clientSecret = 'Hj8LvtZfMQ67VxqJZazTjqjneHIwaYD1eBD9mapYtlo='; // Secret generated for app. Read this environment variable.
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
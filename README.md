# DEMO: AZ_pwless_auth
Using Managed Identities for authentication between Azure Function App and Storage Account in Azure

![App Diagram](/diagram.png "App Diagram")

## Tools needed (tested with the listed versions)
- Azure Subscription
- .NET SDK v8.0.203
- Azure CLI v2.63.0
- Azure Functions Core Tool v4.0.5907
- (Git) Bash

## Deployment
First sign in with Azure CLI to your Azure account: `az login`.
To deploy an Azure Function App that uses key to access the Storage Account, run the `deploy_pw.sh`.
To deploy an Azure Function App that uses System-Assigned Managed Identity to access the Storage Account, run the `deploy_nopw.sh`.

## Testing
User the Azure Portal to trigger the Azure Function App with an HTTP request to get the name of files located in the `mytestcontainer` storage container.

## Note:
If you deploy the app multiple times, delete the `obj` and `bin` folder to avoid deployment issues.

## Sources:
- [Using Blob Binding to Azure Functions](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-http-webhook-trigger?tabs=python-v2%2Cisolated-process%2Cnodejs-v4%2Cfunctionsv2&pivots=programming-language-csharp)
- [Using Managed Identity with default Storage Account](https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference?tabs=blob&pivots=programming-language-csharp#connecting-to-host-storage-with-an-identity)
- [BlobContainerClient reference](https://learn.microsoft.com/en-us/dotnet/api/azure.storage.blobs.blobcontainerclient?view=azure-dotnet)
- [Deploy to Flex Consumption Plan](https://learn.microsoft.com/en-us/azure/azure-functions/flex-consumption-how-to?tabs=azure-cli%2Cvs-code-publish&pivots=programming-language-csharp)
- [Flex Consumption Deployment Sample](https://github.com/Azure-Samples/azure-functions-flex-consumption-samples/blob/main/README.md)
- [Deploying Function App with Bicep](https://learn.microsoft.com/en-us/azure/azure-functions/functions-infrastructure-as-code?tabs=bicep%2Cwindows%2Cdevops&pivots=consumption-plan)

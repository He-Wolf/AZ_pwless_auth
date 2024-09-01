var token = uniqueString(resourceGroup().id)

var functionAppName = 'func-${token}'
var location = resourceGroup().location
var hostingPlanName = 'hp-${token}'
var applicationInsightsName = 'ai-${uniqueString(resourceGroup().id)}'
var storageAccountName = 'sa${uniqueString(resourceGroup().id)}'
var deploymentStorageContainerName = 'app-package-${token}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
}

resource mytestcontainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  parent: blobService
  name: 'mytestcontainer'
}

resource deplyoment_container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  parent: blobService
  name: deploymentStorageContainerName
}

resource applicationInsight 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: {
    'hidden-link:${resourceId('Microsoft.Web/sites', applicationInsightsName)}': 'Resource'
  }
  properties: {
    Application_Type: 'web'
  }
  kind: 'web'
}

resource hostingPlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: hostingPlanName
  location: location
  kind: 'functionapp'
  sku: {
    tier: 'FlexConsumption'
    name: 'FC1'
  }
  properties: {
    reserved: true
  }
}

resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    reserved: true
    serverFarmId: hostingPlan.id
    siteConfig: {
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
        ]
      }
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsight.properties.ConnectionString
        }
        {
          name: 'AzureWebJobsStorage__accountName'
          value: storageAccount.name
        }
      ]
    }
    functionAppConfig: {
      deployment: {
        storage: {
          type: 'blobContainer'
          value: '${storageAccount.properties.primaryEndpoints.blob}${deploymentStorageContainerName}'
          authentication: {
            type: 'SystemAssignedIdentity'
          }
        }
      }
      scaleAndConcurrency: {
        maximumInstanceCount: 100
        instanceMemoryMB: 2048
      }
      runtime: {
        name: 'dotnet-isolated'
        version: '8.0'
      }
    }
  }
}

var storageRoleDefinitionId  = 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b' //Storage Blob Data Owner role

// Allow access from function app to storage account using a managed identity
resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storageAccount.id, storageRoleDefinitionId)
  scope: storageAccount
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageRoleDefinitionId)
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

output functionappName string = functionApp.name

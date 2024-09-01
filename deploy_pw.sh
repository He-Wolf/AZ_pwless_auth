#!/bin/bash

if [ -d "bin" ]; then rm -rf bin; fi
if [ -d "obj" ]; then rm -rf obj; fi

resourceGroupName='pw_rg'
deploymentName='pw_deployment'
location='westeurope'

az group create --name $resourceGroupName --location $location
az deployment group create --name $deploymentName --resource-group $resourceGroupName --template-file main_pw.bicep

functionAppName=$(az deployment group show \
    -g $resourceGroupName \
    -n $deploymentName \
    --query properties.outputs.functionappName.value \
    --output tsv)

echo "sleep for 30s"
sleep 30

func azure functionapp publish "$functionAppName"

# cleanup:
# az group delete --name $resourceGroupName --yes
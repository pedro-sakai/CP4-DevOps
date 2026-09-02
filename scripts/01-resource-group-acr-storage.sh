#!/bin/bash
set -e
source ./00-variaveis.sh

az login

# Grupo de recursos
if ! az group show --name "$resourceGroup" &>/dev/null; then
  az group create --name "$resourceGroup" --location "$location"
fi

# ACR (Azure Container Registry)
az provider register --namespace Microsoft.ContainerRegistry
az acr create \
  --resource-group "$resourceGroup" \
  --name "$acrName" \
  --sku Standard \
  --location "$location" \
  --public-network-enabled true \
  --admin-enabled true

# Storage Account + File Share (persistencia do MySQL)
az provider register --namespace Microsoft.Storage
if ! az storage account show --name "$storageAccountName" --resource-group "$resourceGroup" &>/dev/null; then
  az storage account create \
    --resource-group "$resourceGroup" \
    --name "$storageAccountName" \
    --location "$location" \
    --sku Standard_LRS
fi

connectionString=$(az storage account show-connection-string \
  --name "$storageAccountName" --resource-group "$resourceGroup" \
  --query connectionString --output tsv)

if ! az storage share exists --name "$fileShareName" --account-name "$storageAccountName" \
  --connection-string "$connectionString" | grep true; then
  az storage share create --name "$fileShareName" --account-name "$storageAccountName" \
    --connection-string "$connectionString"
fi

echo "Resource Group, ACR e Storage Account criados."
az acr show --name "$acrName" --query loginServer --output tsv

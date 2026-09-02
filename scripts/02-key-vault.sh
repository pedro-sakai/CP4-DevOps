
set -e
source ./00-variaveis.sh

ACR_USERNAME=$(az acr credential show --name "$acrName" --resource-group "$resourceGroup" --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name "$acrName" --resource-group "$resourceGroup" --query "passwords[0].value" --output tsv)

az provider register --namespace Microsoft.KeyVault

if ! az keyvault show --name "$keyVaultName" --resource-group "$resourceGroup" &>/dev/null; then
  az keyvault create --name "$keyVaultName" --resource-group "$resourceGroup" --location "$location"
fi

az role assignment create \
  --assignee "$(az account show --query user.name -o tsv)" \
  --role "Key Vault Administrator" \
  --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$resourceGroup/providers/Microsoft.KeyVault/vaults/$keyVaultName"


az keyvault secret set --vault-name "$keyVaultName" --name mysql-root-password --value "$MYSQL_ROOT_PASSWORD"
az keyvault secret set --vault-name "$keyVaultName" --name mysql-database --value "$MYSQL_DATABASE"
az keyvault secret set --vault-name "$keyVaultName" --name mysql-user --value "$MYSQL_USER"
az keyvault secret set --vault-name "$keyVaultName" --name mysql-password --value "$MYSQL_PASSWORD"
az keyvault secret set --vault-name "$keyVaultName" --name spring-datasource-url --value "$SPRING_DATASOURCE_URL"
az keyvault secret set --vault-name "$keyVaultName" --name spring-datasource-username --value "$SPRING_DATASOURCE_USERNAME"
az keyvault secret set --vault-name "$keyVaultName" --name spring-datasource-password --value "$SPRING_DATASOURCE_PASSWORD"
az keyvault secret set --vault-name "$keyVaultName" --name acr-username --value "$ACR_USERNAME"
az keyvault secret set --vault-name "$keyVaultName" --name acr-password --value "$ACR_PASSWORD"

echo "Key Vault $keyVaultName criado e populado."

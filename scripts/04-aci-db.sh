
set -e
source ./00-variaveis.sh

storageKey=$(az storage account keys list \
  --resource-group "$resourceGroup" --account-name "$storageAccountName" \
  --query "[0].value" --output tsv)

az provider register --namespace Microsoft.ContainerInstance

az container create \
  --resource-group "$resourceGroup" \
  --name "$aciDbName" \
  --image "${acrName}.azurecr.io/${dbImageName}:v1" \
  --cpu 1 \
  --memory 1.5 \
  --os-type Linux \
  --dns-name-label "${aciDbName}-565956" \
  --ports 3306 \
  --registry-login-server "${acrName}.azurecr.io" \
  --registry-username "$(az keyvault secret show --vault-name $keyVaultName --name acr-username --query value -o tsv)" \
  --registry-password "$(az keyvault secret show --vault-name $keyVaultName --name acr-password --query value -o tsv)" \
  --azure-file-volume-account-name "$storageAccountName" \
  --azure-file-volume-account-key "$storageKey" \
  --azure-file-volume-share-name "$fileShareName" \
  --azure-file-volume-mount-path /var/lib/mysql \
  --environment-variables \
    MYSQL_ROOT_PASSWORD="$(az keyvault secret show --vault-name $keyVaultName --name mysql-root-password --query value -o tsv)" \
    MYSQL_DATABASE="$(az keyvault secret show --vault-name $keyVaultName --name mysql-database --query value -o tsv)" \
    MYSQL_USER="$(az keyvault secret show --vault-name $keyVaultName --name mysql-user --query value -o tsv)" \
    MYSQL_PASSWORD="$(az keyvault secret show --vault-name $keyVaultName --name mysql-password --query value -o tsv)" \
  --restart-policy Always

echo "ACI do banco ($aciDbName) criado."
az container show --resource-group "$resourceGroup" --name "$aciDbName" \
  --query "{fqdn:ipAddress.fqdn, ip:ipAddress.ip, status:instanceView.state}" -o table

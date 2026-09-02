
set -e
source ./00-variaveis.sh

dbPublicIp=$(az container show --resource-group "$resourceGroup" --name "$aciDbName" --query ipAddress.ip --output tsv)

az container create \
  --resource-group "$resourceGroup" \
  --name "$aciAppName" \
  --image "${acrName}.azurecr.io/${appImageName}:v1" \
  --cpu 1 \
  --memory 1.5 \
  --os-type Linux \
  --dns-name-label "${aciAppName}-565956" \
  --ports 8080 \
  --registry-login-server "${acrName}.azurecr.io" \
  --registry-username "$(az keyvault secret show --vault-name $keyVaultName --name acr-username --query value -o tsv)" \
  --registry-password "$(az keyvault secret show --vault-name $keyVaultName --name acr-password --query value -o tsv)" \
  --environment-variables \
    SPRING_DATASOURCE_URL="$(az keyvault secret show --name spring-datasource-url --vault-name $keyVaultName --query value -o tsv | sed "s/mysql-565956/$dbPublicIp/")" \
    SPRING_DATASOURCE_USERNAME="$(az keyvault secret show --name spring-datasource-username --vault-name $keyVaultName --query value -o tsv)" \
    SPRING_DATASOURCE_PASSWORD="$(az keyvault secret show --name spring-datasource-password --vault-name $keyVaultName --query value -o tsv)" \
  --restart-policy Always


echo "ACI do app ($aciAppName) criado."
az container show --resource-group "$resourceGroup" --name "$aciAppName" \
  --query "{fqdn:ipAddress.fqdn, ip:ipAddress.ip, status:instanceView.state}" -o table

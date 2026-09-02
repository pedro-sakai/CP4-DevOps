rm="565956"                       

resourceGroup="rg-$rm"
location="eastus2"

acrName="acr-$rm"                

storageAccountName="vol$rm"  
fileShareName="mysql-565956-volume"

keyVaultName="keyvault-$rm"

dbImageName="${rm}-db"
appImageName="${rm}-app"
aciDbName="${rm}-db"
aciAppName="${rm}-app"

MYSQL_ROOT_PASSWORD="senhateste1234"
MYSQL_DATABASE="db_565956"
MYSQL_USER="user_565956"
MYSQL_PASSWORD="senhateste1234"

SPRING_DATASOURCE_URL="jdbc:mysql://mysql-565956:3306/${MYSQL_DATABASE}?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"
SPRING_DATASOURCE_USERNAME="$MYSQL_USER"
SPRING_DATASOURCE_PASSWORD="$MYSQL_PASSWORD"

echo "Variaveis carregadas. RM=$rm | RG=$resourceGroup | ACR=$acrName"

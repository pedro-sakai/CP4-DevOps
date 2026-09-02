
set -e
source ./scripts/00-variaveis.sh

echo ">>> Build local da imagem do App (Java)"
docker build -t ${appImageName}:v1 -f app/Dockerfile ./app

echo ">>> Build local da imagem do Banco (MySQL)"
docker build -t ${dbImageName}:v1 -f db/Dockerfile .

echo ">>> Login no ACR"
az acr login --name "$acrName"

echo ">>> Tag das imagens com o nome do repositorio no ACR (RM como prefixo, conforme enunciado)"
docker tag ${appImageName}:v1 ${acrName}.azurecr.io/${appImageName}:v1
docker tag ${dbImageName}:v1  ${acrName}.azurecr.io/${dbImageName}:v1

echo ">>> Push das imagens para o ACR"
docker push ${acrName}.azurecr.io/${appImageName}:v1
docker push ${acrName}.azurecr.io/${dbImageName}:v1

echo "Imagens publicadas em ${acrName}.azurecr.io"
az acr repository list --name "$acrName" --output table

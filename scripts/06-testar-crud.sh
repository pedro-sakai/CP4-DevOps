
set -e
source ./00-variaveis.sh

appIp=$(az container show --resource-group "$resourceGroup" --name "$aciAppName" --query ipAddress.ip --output tsv)
BASE_URL="http://${appIp}:8080/api/transacoes"

echo ">>> CREATE (POST)"
curl -s -X POST "$BASE_URL" \
  -H "Content-Type: application/json" \
  -d @../json-tests/post_transacao.json | tee /tmp/create_response.json
echo ""

ID=$(grep -o '"id":[0-9]*' /tmp/create_response.json | head -1 | grep -o '[0-9]*')
echo "ID criado: $ID"

echo ">>> READ (GET todas)"
curl -s "$BASE_URL"
echo ""

echo ">>> READ (GET por id)"
curl -s "$BASE_URL/$ID"
echo ""

echo ">>> UPDATE (PUT)"
curl -s -X PUT "$BASE_URL/$ID" \
  -H "Content-Type: application/json" \
  -d @../json-tests/put_transacao.json
echo ""

echo ">>> DELETE"
curl -s -X DELETE "$BASE_URL/$ID" -w "HTTP status: %{http_code}\n"


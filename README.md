# Checkpoint - Containers em Nuvem 

API REST de Transações (Java + Spring Boot) containerizada, banco MySQL containerizado,
publicados no ACR e executados em dois ACIs separados, com segredos no **Azure Key Vault**
e persistência via **Azure Storage (File Share)** 

## 1. Estrutura do projeto

```
transacoes-565956/
├── app/                  # código-fonte da API Java (Spring Boot) - endpoint /api/transacoes
│   ├── src/...
│   ├── pom.xml
│   └── Dockerfile        # roda como usuário não-root
├── db/
│   └── Dockerfile        # MySQL customizado com o DDL
├── sql/ddl.sql
├── json-tests/
├── scripts/
│   ├── 00-variaveis.sh
│   ├── 01-resource-group-acr-storage.sh
│   ├── 02-key-vault.sh
│   ├── 03-build-push-imagens.sh
│   ├── 04-aci-db.sh
│   ├── 05-aci-app.sh
│   └── 06-testar-crud.sh
├── docker-compose.local.yml   # só para teste local
└── README.md
```

## 2. Fase 1 — testar localmente

```bash
docker compose -f docker-compose.local.yml up --build
```

```bash
curl -X POST http://localhost:8080/api/transacoes -H "Content-Type: application/json" -d @json-tests/post_transacao.json
curl http://localhost:8080/api/transacoes
curl -X PUT http://localhost:8080/api/transacoes/1 -H "Content-Type: application/json" -d @json-tests/put_transacao.json
curl -X DELETE http://localhost:8080/api/transacoes/1
```

Confirme no banco:
```bash
docker exec -it <container-db> mysql -u user_565956 -p db_565956 -e "SELECT * FROM transacoes;"
```

Derrube o ambiente local antes de ir para a nuvem (`docker compose down -v`).

## 3. Fase 2 — nuvem 

```bash
cd scripts
chmod +x *.sh

./01-resource-group-acr-storage.sh   # Resource Group + ACR + Storage Account/File Share
./02-key-vault.sh                    # Key Vault com todos os segredos

cd ..
./scripts/03-build-push-imagens.sh   # docker build + tag + push (rodar da RAIZ do projeto)

cd scripts
./04-aci-db.sh                       # ACI do banco 
./05-aci-app.sh                      # ACI do app
./06-testar-crud.sh                  # roda o CRUD completo contra a nuvem via curl
```

## 4. Comandos de build/push 

```bash
# Build
docker build -t <RM>-app:v1 -f app/Dockerfile ./app
docker build -t <RM>-db:v1  -f db/Dockerfile .

# Login no ACR
az acr login 

# Tag
docker tag <RM>-app:v1 565956<RM>.azurecr.io/<RM>-app:v1
docker tag <RM>-db:v1  565956<RM>.azurecr.io/<RM>-db:v1

# Push
docker push 565956<RM>.azurecr.io/<RM>-app:v1
docker push 565956<RM>.azurecr.io/<RM>-db:v1
```

## 5. Comprovando o CRUD por SELECT 

```bash
az container exec --resource-group rg-565956-<RM> --name <RM>-db \
  --exec-command "mysql -uuser_565956 -pTrocarSenhaForte@456"
```
```sql
use db_565956;
select * from transacoes;
```

## 6. Endpoints da API

| Método | URL                       | Descrição         |
|--------|---------------------------|--------------------|
| POST   | /api/transacoes           | Cria uma transação |
| GET    | /api/transacoes           | Lista todas        |
| GET    | /api/transacoes/{id}      | Busca por id       |
| PUT    | /api/transacoes/{id}      | Atualiza           |
| DELETE | /api/transacoes/{id}      | Remove             |

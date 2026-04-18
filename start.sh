#!/bin/bash

# Czyszczenie poprzedniego środowiska
docker rm -f postgres-db redis-cache backend_1 backend_2 worker nginx-proxy 2>/dev/null
docker network rm proxy-net app-net db-net 2>/dev/null

echo "1. Tworzenie trzech segmentów sieciowych z własnymi podsieciami i bramami..."
# ZMIENIONO: Pule adresów IP na bezpieczniejsze (10.50.x.x, 10.51.x.x, 10.52.x.x)
docker network create --subnet=10.50.0.0/24 --gateway=10.50.0.1 proxy-net
docker network create --subnet=10.51.0.0/24 --gateway=10.51.0.1 app-net
docker network create --subnet=10.52.0.0/24 --gateway=10.52.0.1 db-net

echo "2. Uruchamianie bazy PostgreSQL (TYLKO w db-net, statyczne IP i MAC)..."
docker run -d --name postgres-db \
  --network db-net \
  --ip 10.52.0.10 \
  --mac-address 02:42:ac:16:00:0a \
  --restart unless-stopped \
  -v pg_data:/var/lib/postgresql/data \
  -e POSTGRES_USER=user \
  -e POSTGRES_PASSWORD=pass \
  -e POSTGRES_DB=products \
  postgres:15-alpine

echo "3. Uruchamianie Redis (TYLKO w app-net, statyczne IP)..."
docker run -d --name redis-cache \
  --network app-net \
  --ip 10.51.0.10 \
  --restart unless-stopped \
  --tmpfs /data \
  redis:alpine

echo "4. Uruchamianie instancji backend_1 (proxy-net, app-net, db-net)..."
docker run -d --name backend_1 \
  --network proxy-net \
  --restart unless-stopped \
  -v node_data_1:/app/data \
  --tmpfs /app/tmp \
  -e DB_HOST=postgres-db \
  -e REDIS_HOST=redis-cache \
  -e POSTGRES_USER=user \
  -e POSTGRES_PASSWORD=pass \
  -e POSTGRES_DB=products \
  -e INSTANCE_ID=backend_1 \
  zosia6/backend-api:v2

docker network connect app-net backend_1
docker network connect db-net backend_1

echo "5. Uruchamianie instancji backend_2 (proxy-net, app-net, db-net)..."
docker run -d --name backend_2 \
  --network proxy-net \
  --restart unless-stopped \
  -v node_data_2:/app/data \
  --tmpfs /app/tmp \
  -e DB_HOST=postgres-db \
  -e REDIS_HOST=redis-cache \
  -e POSTGRES_USER=user \
  -e POSTGRES_PASSWORD=pass \
  -e POSTGRES_DB=products \
  -e INSTANCE_ID=backend_2 \
  zosia6/backend-api:v2

docker network connect app-net backend_2
docker network connect db-net backend_2

echo "6. Uruchamianie kontenera worker (app-net, db-net, bez wystawionych portów)..."
docker run -d --name worker \
  --network app-net \
  --restart unless-stopped \
  alpine sh -c "while true; do echo 'Przetwarzanie zadań...'; sleep 10; done"

docker network connect db-net worker

echo "7. Uruchamianie Nginx proxy (TYLKO proxy-net)..."
docker run -d --name nginx-proxy \
  --network proxy-net \
  --user root \
  --restart unless-stopped \
  -p 80:8080 \
  -v $(pwd)/frontend/nginx.conf:/etc/nginx/conf.d/default.conf:ro \
  zosia6/frontend-app:v2

echo "Środowisko zostało pomyślnie uruchomione!"
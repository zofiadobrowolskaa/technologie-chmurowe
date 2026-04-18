#!/bin/bash

echo "tworzenie sieci product-net..."
docker network create product-net 2>/dev/null || true

echo "uruchamianie postgresql (named volume)..."
docker run -d --name postgres-db \
  --network product-net \
  --restart unless-stopped \
  -v pg_data:/var/lib/postgresql/data \
  -e POSTGRES_USER=user \
  -e POSTGRES_PASSWORD=pass \
  -e POSTGRES_DB=products \
  postgres:15-alpine

echo "uruchamianie redis (tmpfs)..."
docker run -d --name redis-cache \
  --network product-net \
  --restart unless-stopped \
  --tmpfs /data \
  redis:alpine

echo "uruchamianie node.js backend (named volume + tmpfs)..."
docker run -d --name api-a \
  --network product-net \
  --restart unless-stopped \
  -v node_data:/app/data \
  --tmpfs /app/tmp \
  -e DB_HOST=postgres-db \
  -e REDIS_HOST=redis-cache \
  -e POSTGRES_USER=user \
  -e POSTGRES_PASSWORD=pass \
  -e POSTGRES_DB=products \
  zosia6/backend-api:v2

echo "uruchamianie nginx frontend (bind mount)..."
docker run -d --name nginx-proxy \
  --network product-net \
  --restart unless-stopped \
  -p 80:8080 \
  -v $(pwd)/frontend/nginx.conf:/etc/nginx/conf.d/default.conf:ro \
  zosia6/frontend-app:v2

echo "środowisko zostało pomyślnie uruchomione!"
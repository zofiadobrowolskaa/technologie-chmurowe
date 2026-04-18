#!/bin/bash

echo "zatrzymywanie produkcyjnego backendu, jeśli działa..."
docker rm -f api-a 2>/dev/null || true

echo "uruchamianie backendu w trybie deweloperskim (hot-reload)..."
docker run -d --name api-a \
  --network product-net \
  --restart unless-stopped \
  -v $(pwd)/backend:/app \
  -v /app/node_modules \
  --tmpfs /app/tmp \
  -e DB_HOST=postgres-db \
  -e REDIS_HOST=redis-cache \
  -e POSTGRES_USER=user \
  -e POSTGRES_PASSWORD=pass \
  -e POSTGRES_DB=products \
  zosia6/backend-api:v2 npx nodemon -L server.js

echo "tryb deweloperski aktywny!"
#!/bin/bash

echo "inspekcja woluminów typu named volume..."

VOLUMES=("pg_data" "node_data")

for VOL in "${VOLUMES[@]}"; do
  echo "wolumin: $VOL"
  
  HOST_PATH=$(docker volume inspect $VOL --format '{{.Mountpoint}}')
  echo "  - lokalizacja na hoście: $HOST_PATH"
  
  SIZE=$(docker run --rm -v $VOL:/vol alpine du -sh /vol 2>/dev/null | cut -f1)
  echo "  - rozmiar danych: ${SIZE:-brak danych}"
  
  CONTAINERS=$(docker ps -a --filter volume=$VOL --format "{{.Names}}")
  if [ -z "$CONTAINERS" ]; then
    echo "  - używany przez kontenery: (brak)"
  else
    echo "  - używany przez kontenery:"
    echo "$CONTAINERS" | sed 's/^/      * /'
  fi
done
#!/bin/bash

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="pg_backup_${TIMESTAMP}.tar.gz"

echo "rozpoczynam tworzenie backupu woluminu pg_data..."

docker run --rm \
  -v pg_data:/volume:ro \
  -v $(pwd):/backup \
  alpine tar -czf /backup/$BACKUP_FILE -C /volume .

echo "backup został zapisany jako: $BACKUP_FILE"
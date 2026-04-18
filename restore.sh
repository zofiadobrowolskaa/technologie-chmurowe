#!/bin/bash

if [ -z "$1" ]; then
  echo "użycie: ./restore.sh <nazwa_pliku_backupu.tar.gz>"
  exit 1
fi

BACKUP_FILE=$1

if [ ! -f "$BACKUP_FILE" ]; then
  echo "błąd: plik $BACKUP_FILE nie istnieje!"
  exit 1
fi

echo "1. zatrzymywanie kontenera bazy danych..."
docker stop postgres-db

echo "2. przywracanie danych z pliku $BACKUP_FILE..."
docker run --rm \
  -v pg_data:/volume \
  -v $(pwd):/backup \
  alpine sh -c "rm -rf /volume/* && tar -xzf /backup/$BACKUP_FILE -C /volume"

echo "3. uruchamianie kontenera bazy danych..."
docker start postgres-db

echo "4. weryfikacja dostępności bazy danych (oczekiwanie na start systemu)..."
sleep 5 

docker exec postgres-db pg_isready -U user
if [ $? -eq 0 ]; then
  echo "weryfikacja zakończona sukcesem! baza danych jest w pełni operacyjna."
else
  echo "błąd: baza danych nie odpowiada."
fi
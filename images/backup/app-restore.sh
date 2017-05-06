#!/bin/sh
set -e

START_TIME=$(date +%s)

cd "/srv/docker/$COMPOSE_PROJECT_NAME"

if [ ! $1 ]; then
  echo "[E] Specify the name of a backup file to restore. Example:"
  echo "      docker-compose exec backup app-restore 20170501T031500+0000.tar.gz"
  exit 1
fi

if [ ! -e "backups/$1" ]; then
  echo "[E] The file '$1' does not exist."
  exit 1
fi

if [ -d backups/tmp_restore ]; then
  echo "[W] Cleaning up from a previously-failed restore."
  rm -rf backups/tmp_restore
fi

BACKUP_FILE="$1"

echo "[I] Creating working directory."
mkdir -p backups/tmp_restore

echo "[I] Shutting down and removing Confluence container."
docker-compose stop web &>/dev/null
docker-compose rm --force web &>/dev/null

echo "[I] Shutting down and removing PostgreSQL container."
docker-compose stop db &>/dev/null
docker-compose rm --force db &>/dev/null

echo "[I] Removing Confluence and PostgreSQL persistent data."
rm -rf volumes/web/data volumes/db/data

echo "[I] Extracting backup."
tar -xf "backups/$BACKUP_FILE" -C backups/tmp_restore

echo "[I] Creating and starting PostgreSQL container."
docker-compose up -d db &>/dev/null

echo "[I] Waiting for PostgreSQL container to complete initialization tasks."
DB_READY=false
while [ "$DB_READY" = "false" ]; do
  sleep 1
  docker exec -i "$(docker-compose ps -q db)" psql -U postgres -d "$POSTGRES_DB" -c "\dt" &>/dev/null && DB_READY=true || DB_READY=false
done

echo "[I] Restoring PostgreSQL database."
docker exec -i "$(docker-compose ps -q db)" psql -U postgres -d "$POSTGRES_DB" &>/dev/null < backups/tmp_restore/db.sql

echo "[I] Restoring Confluence home directory."
if [ ! -d volumes/web ]; then
  mkdir -p volumes/web
fi
mv backups/tmp_restore/home volumes/web/data/

echo "[I] Creating and starting Confluence container."
docker-compose up -d web &>/dev/null

echo "[I] Removing working directory."
rm -rf backups/tmp_restore

END_TIME=$(date +%s)

echo "[I] Script complete. Time elapsed: $((END_TIME-START_TIME)) seconds."

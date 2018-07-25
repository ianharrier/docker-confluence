#!/bin/sh
set -e

START_TIME=$(date +%s)

if [ ! -d .git ]; then
    echo "[E] This script needs to run from the top directory of the repo. Current working directory:"
    echo "      $(pwd)"
    exit 1
fi

echo "=== Shutting down web container. ==============================================="
docker-compose stop web

# The backup process will fail if the db container is not started.

echo "=== Starting cron container. ==================================================="
docker-compose up -d cron

echo "=== Backing up application stack. =============================================="
docker-compose exec cron app-backup

echo "=== Removing currnet application stack. ========================================"
docker-compose down

echo "=== Pulling changes from repo. ================================================="
git pull

echo "=== Updating environment file. ================================================="
OLD_CONFLUENCE_VERSION=$(grep ^CONFLUENCE_VERSION= .env | cut -d = -f 2)
NEW_CONFLUENCE_VERSION=$(grep ^CONFLUENCE_VERSION= .env.template | cut -d = -f 2)
echo "[I] Upgrading Confluence from '$OLD_CONFLUENCE_VERSION' to '$NEW_CONFLUENCE_VERSION'."
sed -i.bak -e "s/^CONFLUENCE_VERSION=.*/CONFLUENCE_VERSION=$NEW_CONFLUENCE_VERSION/g" .env

echo "=== Deleting old images. ======================================================="
IMAGE_CRON=$(docker images ianharrier/confluence-cron -q)
IMAGE_WEB=$(docker images ianharrier/confluence -q)
docker rmi $IMAGE_CRON $IMAGE_WEB

echo "=== Building new images. ======================================================="
docker-compose build --pull --no-cache

echo "=== Pulling updated database image. ============================================"
docker-compose pull db

echo "=== Restoring application stack to most recent backup. ========================="
cd backups
LATEST_BACKUP=$(ls -1tr *.tar.gz 2> /dev/null | tail -n 1)
cd ..
./scripts/app-restore.sh $LATEST_BACKUP

END_TIME=$(date +%s)

echo "=== Upgrade complete. =========================================================="
echo "[I] Time elapsed: $((END_TIME-START_TIME)) seconds."
